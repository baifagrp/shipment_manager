# 📱 LINE 官方帳號完整設定指南

本指南將帶您完成 LINE 官方帳號的申請、設定與串接，讓您的貨物管理系統能夠發送 LINE 通知給顧客。

---

## 📋 目錄

1. [申請 LINE Developers 帳號](#1-申請-line-developers-帳號)
2. [建立 LINE Login Channel](#2-建立-line-login-channel)
3. [建立 Messaging API Channel](#3-建立-messaging-api-channel已有可跳過)
4. [建立 LIFF App](#4-建立-liff-app)
5. [取得 Access Token](#5-取得-access-token)
6. [設定系統參數](#6-設定系統參數)
7. [部署 Supabase Edge Function](#7-部署-supabase-edge-function)
8. [設定 Webhook 自動推播](#8-設定-webhook-自動推播)
9. [測試功能](#9-測試功能)
10. [常見問題](#10-常見問題)

---

## 1. 申請 LINE Developers 帳號

### 步驟 1-1：前往 LINE Developers
1. 開啟瀏覽器，前往：https://developers.line.biz/
2. 點擊右上角「Console」或「登入」
3. 使用您的 LINE 帳號登入

### 步驟 1-2：建立 Provider
1. 登入後，點擊「Create」
2. 選擇「Create a new provider」
3. 輸入 Provider Name（例如：「BaiFa.GRP」或您的公司名稱）
4. 點擊「Create」

✅ 完成！您現在有了一個 Provider，可以在底下建立多個 Channel。

---

## 2. 建立 LINE Login Channel

LINE Login Channel 用於讓顧客綁定 LINE 帳號。

### 步驟 2-1：建立 Channel
1. 在 Provider 頁面，點擊「Create a LINE Login channel」
2. 填寫以下資訊：
   - **Channel type**: LINE Login
   - **Provider**: （自動選擇您剛建立的 Provider）
   - **Company or owner's country or region**: Taiwan
   - **Channel name**: 例如「BaiFa 貨物查詢」
   - **Channel description**: 例如「BaiFa 貨物管理系統 LINE 綁定」
   - **App types**: Web app
   - **Email address**: 您的聯絡 Email
3. 閱讀並同意服務條款
4. 點擊「Create」

### 步驟 2-2：設定 Callback URL
1. 進入剛建立的 LINE Login Channel
2. 點擊「LINE Login」分頁
3. 在「Callback URL」欄位輸入：
   ```
   https://your-domain.com/pages/customer/line-bind.html
   ```
   ⚠️ 將 `your-domain.com` 替換為您的實際網域
   
4. 點擊「Update」

### 步驟 2-3：取得 Channel ID
1. 在「Basic settings」分頁
2. 找到「Channel ID」，複製此 ID
3. ✅ 稍後會用於 `config.js` 的 `LOGIN_CHANNEL_ID`

---

## 3. 建立 Messaging API Channel（已有可跳過）

您提到已經有 Messaging API，如果還沒有，請依照以下步驟：

### 步驟 3-1：建立 Channel（如果尚未建立）
1. 在 Provider 頁面，點擊「Create a Messaging API channel」
2. 填寫以下資訊：
   - **Channel type**: Messaging API
   - **Provider**: （自動選擇）
   - **Channel name**: 例如「BaiFa 貨物通知」
   - **Channel description**: 例如「包裹到店通知與客戶服務」
   - **Category**: E-commerce / Logistics
   - **Subcategory**: Logistics
   - **Email address**: 您的聯絡 Email
3. 閱讀並同意服務條款
4. 點擊「Create」

### 步驟 3-2：設定 Webhook URL
1. 進入 Messaging API Channel
2. 點擊「Messaging API」分頁
3. 在「Webhook settings」區域：
   - Webhook URL: `https://your-project.supabase.co/functions/v1/line-notify-arrival`
   - 將 Webhook 設為「Enabled」
4. 點擊「Update」

### 步驟 3-3：設定自動回應
1. 在「Messaging API」分頁
2. 找到「Auto-reply messages」，設為 **Disabled**
3. 找到「Greeting messages」，可選擇性啟用
4. 找到「Webhook」，設為 **Enabled**

---

## 4. 建立 LIFF App

LIFF (LINE Front-end Framework) 讓您的網頁可以在 LINE 內開啟。

### 步驟 4-1：新增 LIFF App
1. 在 LINE Login Channel 頁面
2. 點擊「LIFF」分頁
3. 點擊「Add」
4. 填寫以下資訊：
   - **LIFF app name**: 「BaiFa 會員綁定」
   - **Size**: Full
   - **Endpoint URL**: `https://your-domain.com/pages/customer/line-bind.html`
   - **Scope**: profile, openid
   - **Bot link feature**: Off
5. 點擊「Add」

### 步驟 4-2：取得 LIFF ID
1. 新增完成後，會看到 LIFF ID（格式：`1234567890-abcdefgh`）
2. 複製此 ID
3. ✅ 稍後會用於 `config.js` 的 `LIFF_ID`

### 步驟 4-3：新增查詢頁面 LIFF（可選）
重複步驟 4-1，但使用以下設定：
- **LIFF app name**: 「BaiFa 包裹查詢」
- **Endpoint URL**: `https://your-domain.com/pages/customer/shpsearch.html`

---

## 5. 取得 Access Token

### 步驟 5-1：取得 Channel Access Token
1. 進入 Messaging API Channel
2. 點擊「Messaging API」分頁
3. 找到「Channel access token (long-lived)」
4. 點擊「Issue」
5. 複製產生的 Token（很長的一串字）
6. ✅ 稍後會用於 `config.js` 的 `CHANNEL_ACCESS_TOKEN`

⚠️ **安全提醒**：
- Access Token 非常重要，不要公開分享
- 正式環境應存放在後端環境變數中
- 不要直接寫在前端 JavaScript

---

## 6. 設定系統參數

### 步驟 6-1：更新 config.js
開啟 `config.js`，找到 `LINE` 區塊，填入您剛才取得的參數：

```javascript
LINE: {
  // 步驟 2-3 取得的 Channel ID
  LOGIN_CHANNEL_ID: '1234567890',
  
  // 步驟 4-2 取得的 LIFF ID
  LIFF_ID: '1234567890-abcdefgh',
  
  // 步驟 5-1 取得的 Access Token
  CHANNEL_ACCESS_TOKEN: 'your-channel-access-token-here',
  
  // 其他設定保持預設即可
  MESSAGING: {
    AUTO_NOTIFY: true,
    NOTIFY_ON_ARRIVAL: true,
    NOTIFY_VERIFICATION_CODE: true,
    REMINDER_HOURS: [24, 48, 72],
    FLEX_MESSAGE_COLOR: '#0a84ff',
    RICH_MENU_ID: ''
  },
  
  LIFF_PAGES: {
    SEARCH: '/pages/customer/shpsearch.html',
    BIND: '/pages/customer/line-bind.html',
    CHECKIN: '/pages/customer/checkin.html'
  }
},
```

### 步驟 6-2：更新 Edge Function URL
開啟 `line-notify-helper.js`，找到這行：

```javascript
uri: `${window.location.origin}/pages/customer/shpsearch.html?tracking=${encodeURIComponent(shipment.tracking_no)}`
```

確認 `window.location.origin` 是您的正式網域。

---

## 7. 部署 Supabase Edge Function

### 步驟 7-1：安裝 Supabase CLI
```bash
npm install -g supabase
```

### 步驟 7-2：登入 Supabase
```bash
supabase login
```

### 步驟 7-3：連結專案
```bash
supabase link --project-ref lhrmgasebwlyrarntoon
```

### 步驟 7-4：設定環境變數
```bash
supabase secrets set LINE_CHANNEL_ACCESS_TOKEN=your-channel-access-token-here
```

### 步驟 7-5：部署 Edge Function
```bash
cd supabase/functions
supabase functions deploy line-notify-arrival
```

✅ 部署完成後，會顯示 Function URL。

---

## 8. 設定 Webhook 自動推播

有兩種方式可以設定自動推播：

### 方案 A：Supabase Webhooks（推薦，最簡單）

1. 登入 Supabase Dashboard
2. 進入「Database」→「Webhooks」
3. 點擊「Create a new hook」
4. 填寫以下資訊：
   - **Name**: LINE Arrival Notification
   - **Table**: shipments
   - **Events**: UPDATE
   - **Type**: HTTP Request
   - **HTTP Request**:
     - Method: POST
     - URL: `https://your-project.supabase.co/functions/v1/line-notify-arrival`
     - HTTP Headers:
       ```
       Authorization: Bearer YOUR_SUPABASE_ANON_KEY
       Content-Type: application/json
       ```
   - **Filters** (進階設定):
     ```sql
     record.status = '待取件' AND record.line_notified = false
     ```
5. 點擊「Create webhook」

### 方案 B：Database Trigger（進階）

如果您有 Supabase Pro 方案，可以使用提供的 SQL 腳本：

```bash
# 在 Supabase SQL Editor 執行
supabase/create-line-trigger.sql
```

---

## 9. 測試功能

### 測試 1：測試 LINE Login 綁定

1. 將 `pages/customer/line-bind.html` 部署到您的網站
2. 在手機上開啟 LINE
3. 在聊天室傳送綁定頁面連結給自己
4. 點擊連結，應該會：
   - 自動開啟 LINE 內建瀏覽器
   - 顯示綁定頁面
   - 輸入手機號碼後完成綁定

✅ 成功標準：Supabase `line_bindings` 表中出現新記錄

### 測試 2：測試包裹查詢 LIFF

1. 在 LINE 中開啟：`https://liff.line.me/YOUR_LIFF_ID`
   （將 `YOUR_LIFF_ID` 替換為步驟 4-2 取得的 LIFF ID）
2. 應該會看到包裹查詢頁面
3. 如果已綁定，會顯示「歡迎回來」提示

✅ 成功標準：頁面正常顯示且可查詢包裹

### 測試 3：測試手動推播

1. 在 `index.html` 的 Console 執行：
   ```javascript
   window.LINENotify.test('0912345678');  // 替換為已綁定的手機號碼
   ```
2. 檢查手機 LINE 是否收到測試訊息

✅ 成功標準：LINE 收到測試訊息

### 測試 4：測試自動推播

1. 在 `index.html` 中建立一筆新貨件
2. 收件人手機填寫已綁定 LINE 的號碼
3. 將狀態更新為「待取件」
4. 檢查手機 LINE 是否收到到店通知

✅ 成功標準：
- LINE 收到 Flex Message 到店通知
- Supabase `line_notifications` 表中有記錄
- Supabase `shipments` 表的 `line_notified` 變為 `true`

---

## 10. 常見問題

### Q1: 為什麼 LIFF 無法開啟？

**A**: 檢查以下項目：
1. LIFF ID 是否正確填入 `config.js`
2. Endpoint URL 是否使用 HTTPS
3. 網域是否已部署（不能用 `file://`）
4. 瀏覽器 Console 是否有錯誤訊息

### Q2: 為什麼 LINE 通知發送失敗？

**A**: 檢查以下項目：
1. Channel Access Token 是否正確
2. Access Token 是否過期（需重新 Issue）
3. 使用者是否已封鎖您的官方帳號
4. 檢查 `line_bindings` 表的 `is_blocked` 欄位

### Q3: 如何取得使用者的 LINE User ID？

**A**: 當使用者完成 LINE Login 或加入官方帳號後，系統會自動取得並儲存在 `line_bindings` 表的 `line_user_id` 欄位。

### Q4: 自動推播沒有觸發怎麼辦？

**A**: 檢查以下項目：
1. Webhook 是否正確設定並啟用
2. Edge Function 是否成功部署
3. 環境變數是否正確設定
4. 檢查 Supabase Logs 是否有錯誤訊息
5. 確認貨件狀態確實變更為「待取件」

### Q5: 可以同時推播給多個使用者嗎？

**A**: 可以！每個收件人的手機號碼只要有綁定 LINE，系統就會自動發送通知。

### Q6: 推播訊息的樣式可以自訂嗎？

**A**: 可以！修改 `line-notify-helper.js` 中的 `createArrivalFlexMessage` 函數，調整 Flex Message 的 JSON 結構。

LINE 官方提供 Flex Message Simulator 可視化編輯器：
https://developers.line.biz/flex-simulator/

### Q7: 如何設定 Rich Menu（圖文選單）？

**A**: Rich Menu 需要透過 LINE Messaging API 設定：
1. 前往 LINE Official Account Manager
2. 進入「聊天」→「圖文選單」
3. 建立新的圖文選單
4. 設定按鈕連結到您的 LIFF 頁面

### Q8: 免費方案有發送限制嗎？

**A**: LINE Messaging API 免費方案每月可發送 **500 則訊息**。
如需更多，請升級為付費方案。

詳細價格：https://www.lycbiz.com/tw/service/line-official-account/plan/

### Q9: 測試環境如何設定？

**A**: 建議建立兩個 LINE Channel：
1. **測試環境** Channel：用於開發測試
2. **正式環境** Channel：用於實際服務

分別設定不同的 LIFF Endpoint URL 和 Webhook URL。

### Q10: 如何處理使用者解除綁定？

**A**: 在 `line-bind.html` 中加入「解除綁定」按鈕，執行：

```javascript
async function unbind() {
  await supabaseClient
    .from('line_bindings')
    .delete()
    .eq('line_user_id', lineProfile.userId);
  
  alert('已解除綁定');
  liff.closeWindow();
}
```

---

## 🆘 需要協助？

如果遇到問題，請：
1. 檢查瀏覽器 Console 的錯誤訊息
2. 檢查 Supabase Logs
3. 參考 LINE Developers 官方文件：https://developers.line.biz/
4. 聯繫技術支援：0973-116-277

---

## 📚 相關連結

- LINE Developers Console: https://developers.line.biz/console/
- LINE Messaging API 文件: https://developers.line.biz/en/docs/messaging-api/
- LIFF 文件: https://developers.line.biz/en/docs/liff/
- Flex Message Simulator: https://developers.line.biz/flex-simulator/
- Supabase Edge Functions: https://supabase.com/docs/guides/functions

---

© 2025 BaiFa.GRP
版本：1.0.0
最後更新：2025-10-28

