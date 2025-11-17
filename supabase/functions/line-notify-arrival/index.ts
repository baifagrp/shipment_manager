// ============================================
// Supabase Edge Function: LINE 到店通知
// 用途：當貨件狀態更新為「待取件」時自動發送 LINE 通知
// ============================================

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 從環境變數取得設定
    const LINE_CHANNEL_ACCESS_TOKEN = Deno.env.get('LINE_CHANNEL_ACCESS_TOKEN')
    const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
    const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!LINE_CHANNEL_ACCESS_TOKEN) {
      throw new Error('LINE_CHANNEL_ACCESS_TOKEN not configured')
    }

    // 取得請求資料
    const { record } = await req.json()
    
    console.log('收到貨件更新事件：', record)

    // 只處理「待取件」狀態且尚未通知的貨件
    if (record.status !== '待取件' || record.line_notified) {
      console.log('跳過通知：狀態不符或已通知')
      return new Response(JSON.stringify({ message: 'Skipped' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    // 建立 Supabase 客戶端
    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_KEY!)

    // 查詢 LINE 綁定資訊
    const { data: binding, error: bindingError } = await supabase
      .from('line_bindings')
      .select('line_user_id, is_blocked')
      .eq('phone', record.receiver_phone)
      .single()

    if (bindingError || !binding) {
      console.log('手機號碼尚未綁定 LINE：', record.receiver_phone)
      return new Response(JSON.stringify({ message: 'Not bound' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    if (binding.is_blocked) {
      console.log('LINE 使用者已封鎖：', binding.line_user_id)
      return new Response(JSON.stringify({ message: 'Blocked' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    // 建立 Flex Message
    const flexMessage = {
      type: 'flex',
      altText: `📦 您的包裹 ${record.tracking_no} 已到店`,
      contents: {
        type: 'bubble',
        hero: {
          type: 'box',
          layout: 'vertical',
          contents: [
            {
              type: 'text',
              text: '📦 包裹到店通知',
              weight: 'bold',
              size: 'xl',
              color: '#ffffff'
            },
            {
              type: 'text',
              text: '您的包裹已送達門市',
              color: '#ffffff',
              size: 'sm',
              margin: 'md'
            }
          ],
          backgroundColor: '#0a84ff',
          paddingAll: '20px'
        },
        body: {
          type: 'box',
          layout: 'vertical',
          contents: [
            {
              type: 'text',
              text: record.tracking_no,
              weight: 'bold',
              size: 'lg',
              margin: 'md',
              color: '#1a202c'
            },
            {
              type: 'box',
              layout: 'vertical',
              margin: 'lg',
              spacing: 'sm',
              contents: [
                {
                  type: 'box',
                  layout: 'baseline',
                  spacing: 'sm',
                  contents: [
                    {
                      type: 'text',
                      text: '收件人',
                      color: '#aaaaaa',
                      size: 'sm',
                      flex: 1
                    },
                    {
                      type: 'text',
                      text: record.receiver_name || '-',
                      wrap: true,
                      color: '#666666',
                      size: 'sm',
                      flex: 3
                    }
                  ]
                },
                {
                  type: 'box',
                  layout: 'baseline',
                  spacing: 'sm',
                  contents: [
                    {
                      type: 'text',
                      text: '取件地址',
                      color: '#aaaaaa',
                      size: 'sm',
                      flex: 1
                    },
                    {
                      type: 'text',
                      text: record.receiver_address || '高雄市三民區',
                      wrap: true,
                      color: '#666666',
                      size: 'sm',
                      flex: 3
                    }
                  ]
                }
              ]
            }
          ]
        },
        footer: {
          type: 'box',
          layout: 'vertical',
          spacing: 'sm',
          contents: [
            {
              type: 'button',
              style: 'primary',
              height: 'sm',
              action: {
                type: 'uri',
                label: '查看詳細資訊',
                uri: `https://your-domain.com/pages/customer/shpsearch.html?tracking=${encodeURIComponent(record.tracking_no)}`
              }
            },
            {
              type: 'text',
              text: '請盡快取件，逾期可能退回',
              size: 'xs',
              color: '#aaaaaa',
              margin: 'md',
              align: 'center'
            }
          ]
        }
      }
    }

    // 如果有驗證碼，加入到訊息中
    if (record.require_code && record.verification_code) {
      flexMessage.contents.body.contents[1].contents.push({
        type: 'box',
        layout: 'vertical',
        margin: 'lg',
        spacing: 'sm',
        paddingAll: '12px',
        backgroundColor: '#f7fafc',
        cornerRadius: '8px',
        contents: [
          {
            type: 'text',
            text: '🔐 取貨驗證碼',
            weight: 'bold',
            size: 'sm',
            color: '#4a5568'
          },
          {
            type: 'text',
            text: record.verification_code,
            size: 'xxl',
            weight: 'bold',
            color: '#0a84ff',
            align: 'center',
            margin: 'md'
          },
          {
            type: 'text',
            text: '⚠️ 取件時需出示此驗證碼',
            size: 'xs',
            color: '#718096',
            align: 'center',
            margin: 'sm'
          }
        ]
      })
    }

    // 如果有代收金額，加入到訊息中
    if (record.cod_amount && record.cod_amount > 0) {
      flexMessage.contents.body.contents[1].contents.push({
        type: 'box',
        layout: 'baseline',
        spacing: 'sm',
        contents: [
          {
            type: 'text',
            text: '代收金額',
            color: '#aaaaaa',
            size: 'sm',
            flex: 1
          },
          {
            type: 'text',
            text: `NT$ ${record.cod_amount}`,
            wrap: true,
            color: '#ff3b30',
            size: 'sm',
            flex: 3,
            weight: 'bold'
          }
        ]
      })
    }

    // 發送 LINE 訊息
    const lineResponse = await fetch('https://api.line.me/v2/bot/message/push', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${LINE_CHANNEL_ACCESS_TOKEN}`
      },
      body: JSON.stringify({
        to: binding.line_user_id,
        messages: [flexMessage]
      })
    })

    if (!lineResponse.ok) {
      const errorData = await lineResponse.json()
      throw new Error(`LINE API Error: ${JSON.stringify(errorData)}`)
    }

    console.log('✅ LINE 通知已發送')

    // 記錄通知
    await supabase
      .from('line_notifications')
      .insert({
        line_user_id: binding.line_user_id,
        phone: record.receiver_phone,
        notification_type: 'arrival',
        shipment_id: record.id,
        tracking_no: record.tracking_no,
        message_content: `包裹 ${record.tracking_no} 已到店`,
        flex_message: flexMessage,
        status: 'sent'
      })

    // 更新貨件狀態
    await supabase
      .from('shipments')
      .update({
        line_notified: true,
        line_notified_time: new Date().toISOString()
      })
      .eq('id', record.id)

    return new Response(JSON.stringify({ message: 'Success' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error('❌ 發送 LINE 通知失敗：', error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})

