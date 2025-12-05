# 📧 Gmail 通知功能完整指南

## 🎯 功能概述

本系統已整合 **Gmail Email 通知**功能，使用 **EmailJS** 服務，在寄件與取件時自動發送精美的 Email 通知給顧客。

### ✨ 主要特色

- ✅ **寄件成功通知** - 顧客寄件後立即收到確認 Email
- ✅ **取件完成通知** - 顧客取件後收到電子收據 Email
- ✅ **精美 HTML 郵件** - 漸層設計、響應式、品牌一致
- ✅ **完全免費** - EmailJS 免費方案每月 200 封
- ✅ **Gmail 發送** - 使用您的 Gmail 帳號發送
- ✅ **不影響流程** - Email 發送失敗不會阻擋核心功能

---

## 📋 已完成的設定

### ✅ **EmailJS 配置已完成**

```javascript
SERVICE_ID: 'service_57hl9vx'
TEMPLATE_SHIPMENT_CREATED: 'template_nq9bsuv'  // 寄件成功
TEMPLATE_PICKUP_SUCCESS: 'template_f2tddhf'     // 取件成功
PUBLIC_KEY: 'ye3f_U0sSEeABiSqH'
```

### ✅ **郵件模板已建立**

1. **寄件成功通知** (`template_nq9bsuv`)
   - 精美漸層紫色設計
   - 包含寄件單號、寄/收件人資訊、包裹詳細
   
2. **取件完成通知** (`template_f2tddhf`)
   - 精美漸層綠色設計
   - 包含取件時間、門市、交易編號

### ✅ **系統整合已完成**

- ✅ `email-notify-helper.js` - Email 通知核心模組
- ✅ `pages/customer/send-kiosk.html` - 寄件 Kiosk 整合
- ✅ `pages/admin/sales.html` - 取件 POS 整合
- ✅ `pages/customer/email-bind.html` - Email 綁定頁面
- ✅ `index.html` - 選單連結已新增

---

## 🚀 啟用步驟

### 步驟 1：建立 Supabase 資料表

在 **Supabase Dashboard > SQL Editor** 執行：

```sql
-- 執行檔案：supabase/create-email-tables.sql
```

或直接執行：

```sql
-- 1. Email 綁定表
CREATE TABLE IF NOT EXISTS email_bindings (
  id BIGSERIAL PRIMARY KEY,
  phone VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(100),
  verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Email 通知記錄表
CREATE TABLE IF NOT EXISTS email_notifications (
  id BIGSERIAL PRIMARY KEY,
  shipment_id BIGINT REFERENCES shipments(id) ON DELETE SET NULL,
  email VARCHAR(255) NOT NULL,
  notification_type VARCHAR(50) NOT NULL,
  status VARCHAR(20) NOT NULL,
  error_message TEXT,
  tracking_no VARCHAR(50),
  sent_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. RLS 政策
ALTER TABLE email_bindings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "允許查詢 Email 綁定" ON email_bindings
  FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "允許新增 Email 綁定" ON email_bindings
  FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "允許更新 Email 綁定" ON email_bindings
  FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);

ALTER TABLE email_notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "允許新增 Email 通知記錄" ON email_notifications
  FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "允許查詢 Email 通知記錄" ON email_notifications
  FOR SELECT TO anon, authenticated USING (true);
```

### 步驟 2：重新部署網站

```bash
# 如果使用 Git + Vercel
git add .
git commit -m "feat: 新增 Gmail 通知功能"
git push origin main

# Vercel 會自動部署
```

---

## 📱 使用流程

### 顧客端流程

#### 1️⃣ **綁定 Email**

顧客前往：`首頁 > 選單 > 📧 Email 通知綁定`

1. 輸入手機號碼（10 碼）
2. 輸入 Email 地址
3. 輸入姓名（選填）
4. 點擊「📧 綁定 Email」

#### 2️⃣ **使用自助寄件**

顧客使用自助寄件 Kiosk 寄件後：
- ✅ 自動發送 **寄件成功通知 Email**
- 📱 也會發送 LINE 收據（如已綁定）

#### 3️⃣ **取件結帳**

門市人員結帳後：
- ✅ 自動發送 **取件完成通知 Email**
- 📱 也會發送 LINE 收據（如已綁定）

---

## 🎨 郵件預覽

### 📦 寄件成功通知

```
┌─────────────────────────────────────┐
│     📦 SHIPMENT RECEIPT            │
│        BaiFa.GRP                   │
│                                     │
│          ✓ 寄件成功！              │
│   您的包裹已成功建立，系統正在處理中  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │   追蹤單號                   │  │
│  │   20251205-123456            │  │
│  └─────────────────────────────┘  │
│                                     │
│  📤 寄件人資訊                      │
│  王小明                             │
│  0912345678                         │
│                                     │
│  📥 收件人資訊                      │
│  李大華                             │
│  0987654321                         │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━        │
│  品名        文件                   │
│  數量        1 件                   │
│  運費        NT$ 60                 │
│  寄件時間    2025/12/05 10:30      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━        │
│                                     │
│  💡 溫馨提醒                        │
│  • 請妥善保管寄件單號               │
│  • 包裹到達後收件人將收到通知       │
└─────────────────────────────────────┘
```

### ✅ 取件完成通知

```
┌─────────────────────────────────────┐
│     ✅ PICKUP COMPLETE             │
│        BaiFa.GRP                   │
│                                     │
│          🎉 取件完成！             │
│   感謝您的使用，期待再次為您服務     │
│                                     │
│  ┌─────────────────────────────┐  │
│  │   追蹤單號                   │  │
│  │   20251205-123456            │  │
│  └─────────────────────────────┘  │
│                                     │
│  👤 收件人                          │
│  李大華                             │
│                                     │
│  📤 寄件人                          │
│  王小明                             │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━        │
│  取件時間    2025/12/05 14:30      │
│  取件門市    NPHONE-KHJG           │
│  交易編號    TX-20251205-001       │
│  ━━━━━━━━━━━━━━━━━━━━━━━━        │
│                                     │
│  ⭐ 滿意我們的服務嗎？              │
│  您的回饋是我們進步的動力！         │
│  [給予評價]                         │
└─────────────────────────────────────┘
```

---

## 🔧 技術細節

### 檔案結構

```
├── email-notify-helper.js          # Email 通知核心模組
├── pages/
│   ├── customer/
│   │   ├── email-bind.html         # Email 綁定頁面
│   │   └── send-kiosk.html         # 自助寄件 (已整合)
│   └── admin/
│       └── sales.html              # 取件 POS (已整合)
├── supabase/
│   └── create-email-tables.sql     # 資料表建立 SQL
└── GMAIL-NOTIFICATION-GUIDE.md     # 本文檔
```

### 核心函數

#### `email-notify-helper.js`

```javascript
// 發送寄件成功通知
await EmailNotify.sendShipmentCreatedEmail(shipmentData, toEmail);

// 發送取件成功通知
await EmailNotify.sendPickupSuccessEmail(pickupData, toEmail);

// 查詢用戶 Email
const email = await EmailNotify.getEmailByPhone(phone);

// 驗證 Email 格式
EmailNotify.validateEmail(email);
```

### 資料表

#### `email_bindings` - Email 綁定表

| 欄位 | 類型 | 說明 |
|------|------|------|
| `id` | BIGSERIAL | 主鍵 |
| `phone` | VARCHAR(20) | 手機號碼（唯一） |
| `email` | VARCHAR(255) | Email 地址 |
| `name` | VARCHAR(100) | 姓名（選填） |
| `verified` | BOOLEAN | 是否已驗證 |
| `created_at` | TIMESTAMPTZ | 建立時間 |
| `updated_at` | TIMESTAMPTZ | 更新時間 |

#### `email_notifications` - Email 通知記錄表

| 欄位 | 類型 | 說明 |
|------|------|------|
| `id` | BIGSERIAL | 主鍵 |
| `shipment_id` | BIGINT | 包裹 ID |
| `email` | VARCHAR(255) | 收件 Email |
| `notification_type` | VARCHAR(50) | 通知類型 |
| `status` | VARCHAR(20) | 狀態（sent/failed） |
| `error_message` | TEXT | 錯誤訊息 |
| `tracking_no` | VARCHAR(50) | 追蹤單號 |
| `sent_at` | TIMESTAMPTZ | 發送時間 |

---

## 📊 EmailJS 用量管理

### 免費方案限制

- ✅ 每月 200 封郵件
- ✅ 2 個 Email 服務
- ✅ 無限模板
- ✅ 基本支援

### 監控用量

1. 登入 [EmailJS Dashboard](https://dashboard.emailjs.com/)
2. 查看「Usage」頁面
3. 監控每月發送量

### 如果超過用量

**選項 1：升級方案**
- Personal: $9.9/月，1000 封
- Professional: $29/月，10000 封

**選項 2：使用多個免費帳號**
- 分別用於寄件通知和取件通知
- 需要在 `email-notify-helper.js` 中調整設定

---

## 🧪 測試步驟

### 1. 測試 Email 綁定

1. 前往 `http://localhost:8000/pages/customer/email-bind.html`
2. 輸入：
   - 手機：`0912345678`
   - Email：您的測試 Email
   - 姓名：`測試用戶`
3. 點擊「綁定 Email」
4. 檢查 Supabase `email_bindings` 表

### 2. 測試寄件通知

1. 前往自助寄件 Kiosk
2. 寄件人電話填寫已綁定的手機號碼
3. 完成寄件
4. 檢查您的 Email 信箱
5. 應該收到「📦 寄件成功」郵件

### 3. 測試取件通知

1. 在 POS 系統搜尋包裹
2. 收件人電話為已綁定的號碼
3. 完成取件結帳
4. 檢查您的 Email 信箱
5. 應該收到「✅ 取件完成」郵件

---

## ⚠️ 常見問題

### Q1: 為什麼沒收到 Email？

**可能原因：**
1. Email 尚未綁定
2. Email 地址錯誤
3. 郵件被分類到垃圾郵件
4. EmailJS 用量已達上限

**解決方法：**
1. 確認已在「Email 通知綁定」頁面綁定
2. 檢查垃圾郵件資料夾
3. 前往 EmailJS Dashboard 檢查用量

### Q2: Email 發送失敗會影響寄件嗎？

**不會！**
- Email 發送是非阻塞式的
- 即使失敗也不會影響寄件/取件流程
- Console 會顯示警告訊息

### Q3: 如何更換 Email 地址？

1. 前往「Email 通知綁定」頁面
2. 輸入相同的手機號碼
3. 輸入新的 Email 地址
4. 系統會自動更新

### Q4: 如何自訂郵件模板？

1. 登入 [EmailJS Dashboard](https://dashboard.emailjs.com/)
2. 前往「Email Templates」
3. 選擇對應的模板編輯
4. 修改 HTML 內容
5. 儲存即可生效

---

## 🎉 功能總結

### ✅ 已完成

- ✅ EmailJS 服務設定
- ✅ 2 個精美郵件模板
- ✅ Email 綁定頁面
- ✅ 自助寄件整合
- ✅ 取件 POS 整合
- ✅ Supabase 資料表
- ✅ 選單連結
- ✅ 完整文檔

### 🎯 使用流程

```
顧客綁定 Email
     ↓
使用自助寄件 Kiosk
     ↓
✅ 收到寄件成功 Email
     ↓
包裹送達門市
     ↓
顧客取件結帳
     ↓
✅ 收到取件完成 Email
```

### 📈 優勢

- ✅ **雙重通知** - LINE + Email 雙保險
- ✅ **精美設計** - 專業漸層卡片式郵件
- ✅ **完全免費** - 每月 200 封免費額度
- ✅ **不影響流程** - 發送失敗不阻擋核心功能
- ✅ **環保便利** - 減少紙本收據需求

---

## 📞 技術支援

如有問題，請檢查：

1. **Console 訊息** - 查看詳細錯誤資訊
2. **Supabase Logs** - 檢查資料庫操作
3. **EmailJS Dashboard** - 檢查發送狀態
4. **Email 垃圾郵件資料夾** - 郵件可能被過濾

---

**🎉 Gmail 通知功能已完整整合！享受便利的電子化通知服務！**

