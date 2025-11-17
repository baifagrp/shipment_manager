# 📩 LINE 訊息發送頁面使用指南

## 📄 頁面資訊

**檔案位置**: `pages/admin/liff-send.html`
**權限**: 僅限管理員（需登入）
**用途**: 向已綁定 LINE 的顧客發送通知、優惠券或取件提醒

---

## ✨ 功能特色

### 1️⃣ 顧客搜尋
- 🔍 輸入手機號碼快速搜尋
- 📱 自動顯示顧客 LINE 綁定資訊
- 🆔 確認正確的 LINE User ID

### 2️⃣ 訊息類型
- 💬 **文字訊息**: 簡單文字通知
- 📱 **Flex Message**: 精美的卡片式訊息

### 3️⃣ 範本功能
- 📦 **到店通知範本**
- 🎫 **優惠券範本**
- ⏰ **取件提醒範本**

### 4️⃣ 即時預覽
- 👀 實時顯示訊息效果
- ✅ 自動驗證 JSON 格式
- 📱 模擬 LINE 顯示樣式

---

## 🚀 使用步驟

### 步驟 1：登入系統
前往 `index.html` 登入管理員帳號

### 步驟 2：開啟發送頁面
前往 `pages/admin/liff-send.html`

### 步驟 3：搜尋顧客
1. 在搜尋框輸入手機號碼
2. 從搜尋結果選擇目標顧客
3. 確認 LINE User ID 正確

### 步驟 4：選擇訊息類型

#### A. 文字訊息
```
輸入內容，例如：
「您的包裹已到店，請盡快取件！」
```

#### B. Flex Message
```json
{
  "type": "flex",
  "altText": "訊息預覽文字",
  "contents": {
    "type": "bubble",
    ...
  }
}
```

或點擊範本按鈕快速載入

### 步驟 5：預覽訊息
查看右側預覽區，確認訊息顯示正確

### 步驟 6：發送
點擊「🚀 立即發送」按鈕

---

## 📝 Flex Message 範本

### 📦 到店通知

```json
{
  "type": "flex",
  "altText": "📦 您的包裹已到店",
  "contents": {
    "type": "bubble",
    "hero": {
      "type": "box",
      "layout": "vertical",
      "contents": [
        {
          "type": "text",
          "text": "📦 包裹到店通知",
          "weight": "bold",
          "size": "xl",
          "color": "#ffffff"
        }
      ],
      "backgroundColor": "#0a84ff",
      "paddingAll": "20px"
    },
    "body": {
      "type": "box",
      "layout": "vertical",
      "contents": [
        {
          "type": "text",
          "text": "包裹編號：20251117-XXXXX",
          "size": "md",
          "color": "#2d3748"
        },
        {
          "type": "text",
          "text": "取件門市：NPHONE-KHJG",
          "size": "sm",
          "color": "#718096",
          "margin": "md"
        },
        {
          "type": "text",
          "text": "請盡快取件，逾期可能退回",
          "size": "xs",
          "color": "#e53e3e",
          "margin": "lg"
        }
      ]
    },
    "footer": {
      "type": "box",
      "layout": "vertical",
      "contents": [
        {
          "type": "button",
          "style": "primary",
          "action": {
            "type": "uri",
            "label": "前往報到",
            "uri": "https://your-domain.com/pages/customer/checkin.html"
          }
        }
      ]
    }
  }
}
```

### 🎫 優惠券

```json
{
  "type": "flex",
  "altText": "🎫 專屬優惠券",
  "contents": {
    "type": "bubble",
    "hero": {
      "type": "box",
      "layout": "vertical",
      "contents": [
        {
          "type": "text",
          "text": "🎫 專屬優惠券",
          "weight": "bold",
          "size": "xl",
          "color": "#ffffff"
        },
        {
          "type": "text",
          "text": "限時優惠",
          "size": "md",
          "color": "#ffffff",
          "margin": "sm"
        }
      ],
      "backgroundColor": "#ff6b6b",
      "paddingAll": "20px"
    },
    "body": {
      "type": "box",
      "layout": "vertical",
      "contents": [
        {
          "type": "text",
          "text": "全館商品 9 折優惠",
          "size": "lg",
          "weight": "bold",
          "color": "#2d3748"
        },
        {
          "type": "text",
          "text": "優惠碼：SAVE10",
          "size": "xl",
          "weight": "bold",
          "color": "#ff6b6b",
          "align": "center",
          "margin": "lg"
        },
        {
          "type": "text",
          "text": "有效期限：2025/12/31",
          "size": "xs",
          "color": "#718096",
          "align": "center",
          "margin": "md"
        }
      ]
    }
  }
}
```

### ⏰ 取件提醒

```json
{
  "type": "flex",
  "altText": "⏰ 取件提醒",
  "contents": {
    "type": "bubble",
    "hero": {
      "type": "box",
      "layout": "vertical",
      "contents": [
        {
          "type": "text",
          "text": "⏰ 取件提醒",
          "weight": "bold",
          "size": "xl",
          "color": "#ffffff"
        }
      ],
      "backgroundColor": "#ffa500",
      "paddingAll": "20px"
    },
    "body": {
      "type": "box",
      "layout": "vertical",
      "contents": [
        {
          "type": "text",
          "text": "您的包裹還未取件",
          "size": "md",
          "color": "#2d3748"
        },
        {
          "type": "text",
          "text": "包裹編號：20251117-XXXXX",
          "size": "sm",
          "color": "#718096",
          "margin": "md"
        },
        {
          "type": "text",
          "text": "到店日期：2025/11/15",
          "size": "sm",
          "color": "#718096",
          "margin": "sm"
        },
        {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "⚠️ 請於 3 日內完成取件",
              "size": "sm",
              "color": "#e53e3e",
              "weight": "bold"
            }
          ],
          "backgroundColor": "#fff5f5",
          "paddingAll": "12px",
          "cornerRadius": "8px",
          "margin": "lg"
        }
      ]
    }
  }
}
```

---

## 🔧 技術細節

### 前端實作
- 使用 Supabase Client 查詢顧客資訊
- 即時 JSON 驗證
- 訊息預覽渲染

### 後端整合
呼叫 Supabase RPC 函數：

```javascript
await supabaseClient.rpc('send_line_notification', {
  p_line_user_id: 'LINE_USER_ID',
  p_message: {
    type: 'text',
    text: '訊息內容'
  }
});
```

### 訊息記錄
所有發送的訊息都會記錄到 `line_notifications` 表：

```sql
INSERT INTO line_notifications (
  line_user_id,
  phone,
  notification_type,
  message_content,
  flex_message,
  status
) VALUES (...);
```

---

## 🔐 安全性

### 1. 權限檢查
- 頁面載入時自動檢查登入狀態
- 未登入用戶會被導向 `index.html`

### 2. 訊息驗證
- Flex Message 自動驗證 JSON 格式
- 防止發送錯誤格式的訊息

### 3. 發送記錄
- 所有訊息都有完整的發送記錄
- 可追溯誰在何時發送了什麼訊息

---

## 📊 使用情境

### 情境 1：包裹到店主動通知
當顧客的包裹到店後，管理員可以：
1. 搜尋顧客手機號
2. 選擇「到店通知」範本
3. 修改包裹編號等資訊
4. 發送通知

### 情境 2：促銷活動推播
1. 選擇「優惠券」範本
2. 修改優惠內容和期限
3. 逐一發送給會員

### 情境 3：逾期取件提醒
1. 篩選逾期未取件的包裹
2. 使用「取件提醒」範本
3. 批量發送提醒訊息

---

## ❓ 常見問題

### Q1: 顧客搜尋不到怎麼辦？
**A**: 確認顧客已在 `line-bind.html` 完成 LINE 綁定

### Q2: Flex Message 格式錯誤？
**A**: 使用 [LINE Flex Message Simulator](https://developers.line.biz/flex-simulator/) 驗證 JSON 格式

### Q3: 訊息發送失敗？
**A**: 檢查：
- LINE Channel Access Token 是否有效
- 顧客是否封鎖官方帳號
- Supabase RPC 函數是否正常

### Q4: 如何批量發送？
**A**: 目前僅支援單一發送，批量功能將在未來版本提供

---

## 🎯 未來功能

- [ ] 批量發送功能
- [ ] 發送歷史記錄查詢
- [ ] 更多預設範本
- [ ] 排程發送功能
- [ ] 訊息成效追蹤

---

## 📚 相關文檔

- **LINE 綁定頁面**: `pages/customer/line-bind.html`
- **LINE 設定指南**: `LINE-SETUP-GUIDE.md`
- **Flex Message 預覽**: `LINE-FLEX-MESSAGE-PREVIEW.md`
- **Supabase 設定**: `SUPABASE-SETTINGS-GUIDE.md`

---

© 2025 BaiFa.GRP
版本：1.4.0
最後更新：2025/11/17

