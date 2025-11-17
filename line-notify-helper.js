// ============================================
// LINE 通知助手模組
// 用途：提供 LINE 推播通知的輔助函數
// ============================================

/**
 * LINE Messaging API 推播通知
 * @param {string} lineUserId - LINE User ID
 * @param {object} message - 訊息內容
 * @returns {Promise<boolean>} - 是否成功
 */
async function sendLINENotification(lineUserId, message) {
  try {
    // ✅ 使用 Supabase RPC 呼叫 Database Function（不需要 Edge Function）
    console.log('🔔 透過 Supabase RPC 發送 LINE 通知...');

    const { data, error } = await supabaseClient
      .rpc('send_line_notification', {
        p_line_user_id: lineUserId,
        p_message: message
      });

    if (error) {
      console.error('❌ RPC 呼叫失敗：', error);
      return false;
    }

    if (data && data.success) {
      console.log('✅ LINE 通知已發送');
      return true;
    } else {
      console.error('❌ LINE 推播失敗：', data?.error || 'Unknown error');
      return false;
    }
  } catch (error) {
    console.error('❌ LINE 通知發送錯誤：', error);
    return false;
  }
}

/**
 * 發送包裹到店通知
 * @param {string} phone - 手機號碼
 * @param {object} shipment - 貨件資料
 * @returns {Promise<boolean>} - 是否成功
 */
async function notifyPackageArrival(phone, shipment) {
  try {
    // ✅ 統一使用 Flex Message 格式（有無驗證碼都一樣精美）
    
    // 查詢 LINE 綁定資訊
    const { data: binding, error } = await supabaseClient
      .from('line_bindings')
      .select('line_user_id, is_blocked')
      .eq('phone', phone)
      .single();

    if (error || !binding) {
      console.log('ℹ️ 手機號碼尚未綁定 LINE：', phone);
      return false;
    }

    if (binding.is_blocked) {
      console.log('⚠️ LINE 使用者已封鎖：', binding.line_user_id);
      return false;
    }

    // 建立 Flex Message
    const flexMessage = createArrivalFlexMessage(shipment);

    // 發送通知
    const success = await sendLINENotification(binding.line_user_id, flexMessage);

    if (success) {
      // 記錄通知
      await supabaseClient
        .from('line_notifications')
        .insert({
          line_user_id: binding.line_user_id,
          phone: phone,
          notification_type: 'arrival',
          shipment_id: shipment.id,
          tracking_no: shipment.tracking_no,
          message_content: `包裹 ${shipment.tracking_no} 已到店`,
          flex_message: flexMessage,
          status: 'sent'
        });

      // 更新貨件狀態
      await supabaseClient
        .from('shipments')
        .update({
          line_notified: true,
          line_notified_time: new Date().toISOString()
        })
        .eq('id', shipment.id);
    }

    return success;
  } catch (error) {
    console.error('❌ 發送包裹到店通知失敗：', error);
    return false;
  }
}

/**
 * 發送驗證碼通知（已整合至包裹到店通知，此函數保留供獨立使用）
 * @param {string} phone - 手機號碼
 * @param {string} verificationCode - 驗證碼
 * @param {string} trackingNo - 包裹編號
 * @param {string} storeName - 取件門市（可選）
 * @param {string} arrivalDate - 送達日期（可選）
 * @returns {Promise<boolean>} - 是否成功
 */
async function notifyVerificationCode(phone, verificationCode, trackingNo, storeName = '', arrivalDate = '') {
  try {
    // 查詢 LINE 綁定資訊
    const { data: binding } = await supabaseClient
      .from('line_bindings')
      .select('line_user_id, is_blocked')
      .eq('phone', phone)
      .single();

    if (!binding || binding.is_blocked) {
      return false;
    }

    // 格式化日期
    const dateStr = arrivalDate || new Date().toLocaleDateString('zh-TW', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }).replace(/\//g, '/');

    // 建立訊息（新格式）
    const message = {
      type: 'text',
      text: `📦 您有1個包裹已送達取件門市\n\n` +
            `包裹編號：${trackingNo}\n` +
            (storeName ? `取件門市：${storeName}\n` : '') +
            `送達日期：${dateStr}\n` +
            `🔐 取貨驗證碼：${verificationCode}\n\n` +
            `⚠️ 請妥善保管驗證碼，取件時需出示此碼。\n` +
            `請勿將驗證碼告知他人。`
    };

    const success = await sendLINENotification(binding.line_user_id, message);

    if (success) {
      // 記錄通知
      await supabaseClient
        .from('line_notifications')
        .insert({
          line_user_id: binding.line_user_id,
          phone: phone,
          notification_type: 'verification',
          tracking_no: trackingNo,
          message_content: `驗證碼：${verificationCode}`,
          status: 'sent'
        });
    }

    return success;
  } catch (error) {
    console.error('❌ 發送驗證碼通知失敗：', error);
    return false;
  }
}

/**
 * 建立包裹到店 Flex Message
 * @param {object} shipment - 貨件資料
 * @returns {object} - Flex Message
 */
function createArrivalFlexMessage(shipment) {
  const flexColor = CONFIG.LINE.MESSAGING.FLEX_MESSAGE_COLOR || '#0a84ff';
  const hasVerificationCode = shipment.require_code && shipment.verification_code;
  const hasCOD = shipment.cod_amount && shipment.cod_amount > 0;

  return {
    type: 'flex',
    altText: `📦 您有1個包裹已送達取件門市`,
    contents: {
      type: 'bubble',
      hero: {
        type: 'box',
        layout: 'vertical',
        contents: [
          {
            type: 'text',
            text: '📦 包裹已送達門市',
            weight: 'bold',
            size: 'xl',
            color: '#ffffff'
          },
          {
            type: 'text',
            text: '您有1個包裹已到店，請盡快取件',
            color: '#ffffff',
            size: 'sm',
            margin: 'md'
          }
        ],
        backgroundColor: flexColor,
        paddingAll: '20px'
      },
      body: {
        type: 'box',
        layout: 'vertical',
        contents: [
          {
            type: 'text',
            text: shipment.tracking_no,
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
              // 收件人
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
                    text: shipment.receiver_name || '-',
                    wrap: true,
                    color: '#666666',
                    size: 'sm',
                    flex: 3
                  }
                ]
              },
              // 取件地址
              {
                type: 'box',
                layout: 'baseline',
                spacing: 'sm',
                contents: [
                  {
                    type: 'text',
                    text: '取件門市',
                    color: '#aaaaaa',
                    size: 'sm',
                    flex: 1
                  },
                  {
                    type: 'text',
                    text: shipment.receiver_address || CONFIG.UI.PRINT.COMPANY.ADDRESS || 'NPHONE-KHJG',
                    wrap: true,
                    color: '#666666',
                    size: 'sm',
                    flex: 3
                  }
                ]
              },
              // 送達日期
              {
                type: 'box',
                layout: 'baseline',
                spacing: 'sm',
                contents: [
                  {
                    type: 'text',
                    text: '送達日期',
                    color: '#aaaaaa',
                    size: 'sm',
                    flex: 1
                  },
                  {
                    type: 'text',
                    text: new Date().toLocaleDateString('zh-TW', {
                      year: 'numeric',
                      month: '2-digit',
                      day: '2-digit'
                    }).replace(/\//g, '/'),
                    wrap: true,
                    color: '#666666',
                    size: 'sm',
                    flex: 3
                  }
                ]
              },
              // 代收金額（如果有）
              ...(hasCOD ? [{
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
                    text: `NT$ ${shipment.cod_amount}`,
                    wrap: true,
                    color: '#ff3b30',
                    size: 'sm',
                    flex: 3,
                    weight: 'bold'
                  }
                ]
              }] : []),
              // 驗證碼（如果有）
              ...(hasVerificationCode ? [{
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
                    text: shipment.verification_code,
                    size: 'xxl',
                    weight: 'bold',
                    color: flexColor,
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
              }] : [])
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
              uri: `${window.location.origin}/pages/customer/shpsearch.html?tracking=${encodeURIComponent(shipment.tracking_no)}`
            }
          },
          {
            type: 'button',
            style: 'link',
            height: 'sm',
            action: {
              type: 'uri',
              label: '前往報到',
              uri: `${window.location.origin}/pages/customer/checkin.html?tracking=${encodeURIComponent(shipment.tracking_no)}`
            }
          },
          {
            type: 'box',
            layout: 'vertical',
            contents: [
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
        ]
      }
    }
  };
}

/**
 * 測試 LINE 通知功能
 * @param {string} phone - 手機號碼
 * @returns {Promise<boolean>} - 是否成功
 */
async function testLINENotification(phone) {
  try {
    const { data: binding } = await supabaseClient
      .from('line_bindings')
      .select('line_user_id')
      .eq('phone', phone)
      .single();

    if (!binding) {
      alert('此手機號碼尚未綁定 LINE');
      return false;
    }

    const testMessage = {
      type: 'text',
      text: '🎉 LINE 通知測試\n\n' +
            '這是一則測試訊息。\n' +
            '如果您收到這則訊息，表示 LINE 通知功能運作正常！\n\n' +
            `測試時間：${new Date().toLocaleString('zh-TW')}`
    };

    const success = await sendLINENotification(binding.line_user_id, testMessage);
    
    if (success) {
      alert('✅ 測試訊息已發送！請檢查您的 LINE');
    } else {
      alert('❌ 發送失敗，請檢查設定');
    }

    return success;
  } catch (error) {
    console.error('測試失敗：', error);
    alert('❌ 測試失敗：' + error.message);
    return false;
  }
}

// 匯出函數
if (typeof window !== 'undefined') {
  window.LINENotify = {
    send: sendLINENotification,
    notifyArrival: notifyPackageArrival,
    notifyVerificationCode: notifyVerificationCode,
    test: testLINENotification
  };
}

