# 📊 統一顧客聯絡資訊表 - 遷移指南

## 🎯 目標

將分散的 `line_bindings` 和 `email_bindings` 整合為統一的 `customer_contacts` 表，便於管理顧客的所有聯絡方式。

---

## ✅ 優勢

### 之前（分散的表）

```
line_bindings          email_bindings
├─ phone              ├─ phone
├─ line_user_id       ├─ email
├─ is_blocked         ├─ name
└─ ...                └─ ...
```

**問題：**
- ❌ 資料重複（兩個表都有 phone）
- ❌ 查詢複雜（需要 JOIN）
- ❌ 同步困難（姓名可能不一致）

### 現在（統一的表）

```
customer_contacts
├─ phone (主鍵)
├─ name
├─ email
├─ line_user_id
├─ notify_by_line
├─ notify_by_email
└─ ...
```

**優勢：**
- ✅ 資料集中（一個號碼一筆記錄）
- ✅ 查詢簡單（單表查詢）
- ✅ 擴展容易（可添加更多聯絡方式）
- ✅ 通知偏好（可關閉特定通知）

---

## 📋 遷移步驟

### 步驟 1：備份現有資料（重要！）

```sql
-- 備份 line_bindings
CREATE TABLE line_bindings_backup AS SELECT * FROM line_bindings;

-- 備份 email_bindings
CREATE TABLE email_bindings_backup AS SELECT * FROM email_bindings;
```

### 步驟 2：執行遷移 SQL

在 **Supabase Dashboard > SQL Editor** 執行：

```bash
supabase/migrate-to-unified-contacts.sql
```

或直接複製執行內容（SQL 內容見該文件）。

### 步驟 3：驗證資料遷移

```sql
-- 檢查總數是否正確
SELECT COUNT(*) FROM customer_contacts;
SELECT COUNT(*) FROM line_bindings_backup;
SELECT COUNT(*) FROM email_bindings_backup;

-- 檢查 LINE 綁定遷移
SELECT COUNT(*) FROM customer_contacts WHERE line_user_id IS NOT NULL;

-- 檢查 Email 綁定遷移
SELECT COUNT(*) FROM customer_contacts WHERE email IS NOT NULL;

-- 檢查同時有 LINE 和 Email 的顧客
SELECT 
  phone, 
  name, 
  line_user_id, 
  email 
FROM customer_contacts 
WHERE line_user_id IS NOT NULL AND email IS NOT NULL;
```

### 步驟 4：測試前端功能

1. **測試 Email 綁定**
   - 前往 `pages/customer/email-bind.html`
   - 綁定一個新的 Email
   - 檢查 `customer_contacts` 表

2. **測試 LINE 綁定**
   - 前往 `pages/customer/line-bind.html`
   - 綁定一個新的 LINE
   - 檢查 `customer_contacts` 表

3. **測試寄件通知**
   - 使用已綁定的手機號碼寄件
   - 應收到 LINE 和/或 Email 通知

4. **測試取件通知**
   - 使用已綁定的手機號碼取件
   - 應收到 LINE 和/或 Email 通知

### 步驟 5：清理舊表（可選，確認無誤後）

```sql
-- ⚠️ 確認資料遷移成功且系統運作正常後再執行！

-- 刪除舊的綁定表
DROP TABLE IF EXISTS line_bindings;
DROP TABLE IF EXISTS email_bindings;

-- 保留備份表（以防萬一）
-- 可在一段時間後再刪除
-- DROP TABLE IF EXISTS line_bindings_backup;
-- DROP TABLE IF EXISTS email_bindings_backup;
```

---

## 📊 資料表結構

### `customer_contacts` - 統一顧客聯絡資訊表

| 欄位 | 類型 | 說明 |
|------|------|------|
| `id` | BIGSERIAL | 主鍵 |
| `phone` | VARCHAR(20) | 手機號碼（唯一，10碼） |
| `name` | VARCHAR(100) | 顧客姓名 |
| `email` | VARCHAR(255) | Email 地址 |
| `email_verified` | BOOLEAN | Email 是否已驗證 |
| `line_user_id` | VARCHAR(255) | LINE 用戶 ID |
| `line_display_name` | VARCHAR(255) | LINE 顯示名稱 |
| `line_picture_url` | TEXT | LINE 頭像網址 |
| `line_is_blocked` | BOOLEAN | 是否封鎖官方帳號 |
| `line_bound_at` | TIMESTAMPTZ | LINE 綁定時間 |
| `notify_by_line` | BOOLEAN | 是否接收 LINE 通知 |
| `notify_by_email` | BOOLEAN | 是否接收 Email 通知 |
| `created_at` | TIMESTAMPTZ | 建立時間 |
| `updated_at` | TIMESTAMPTZ | 更新時間 |

### 索引

- `idx_customer_contacts_phone` - 手機號碼
- `idx_customer_contacts_email` - Email 地址
- `idx_customer_contacts_line_user_id` - LINE 用戶 ID

---

## 🔍 實用 Views

遷移 SQL 已自動創建以下 Views：

### 1. `customers_with_line` - 有 LINE 綁定的顧客

```sql
SELECT * FROM customers_with_line;
```

### 2. `customers_with_email` - 有 Email 綁定的顧客

```sql
SELECT * FROM customers_with_email;
```

### 3. `customers_fully_bound` - 完整綁定的顧客（LINE + Email）

```sql
SELECT * FROM customers_fully_bound;
```

---

## 📝 已更新的文件

### 核心模組

1. **`email-notify-helper.js`**
   - ✅ 更新 `getEmailByPhone()` - 從 `customer_contacts` 查詢
   - ✅ 更新 `logEmailNotification()` - 添加 `customer_phone`
   - ✅ 檢查 `notify_by_email` 通知偏好

2. **`line-notify-helper.js`**
   - ✅ 更新所有 LINE 綁定查詢
   - ✅ 檢查 `line_is_blocked` 和 `notify_by_line`
   - ✅ 更新測試函數

### 前端頁面

3. **`pages/customer/email-bind.html`**
   - ✅ 更新為使用 `customer_contacts` 表
   - ✅ 新增時自動設定通知偏好

4. **`pages/customer/send-kiosk.html`**
   - ✅ 更新 LINE 收據發送邏輯
   - ✅ 檢查通知偏好

5. **`pages/admin/sales.html`**
   - ✅ 更新取件收據發送邏輯
   - ✅ 檢查通知偏好

### 其他（需手動更新）

- ⚠️ `pages/customer/line-bind.html` - LINE 綁定頁面
- ⚠️ `pages/customer/shpsearch.html` - 包裹查詢頁面
- ⚠️ `pages/admin/liff-send.html` - LINE 訊息發送頁面

---

## 🔧 API 變更

### 查詢 Email（之前）

```javascript
const { data } = await supabaseClient
  .from('email_bindings')
  .select('email')
  .eq('phone', phone)
  .single();
```

### 查詢 Email（現在）

```javascript
const { data } = await supabaseClient
  .from('customer_contacts')
  .select('email, notify_by_email')
  .eq('phone', phone)
  .single();

// 檢查通知偏好
if (data && data.email && data.notify_by_email !== false) {
  // 發送 Email
}
```

### 查詢 LINE（之前）

```javascript
const { data } = await supabaseClient
  .from('line_bindings')
  .select('line_user_id, is_blocked')
  .eq('phone', phone)
  .single();
```

### 查詢 LINE（現在）

```javascript
const { data } = await supabaseClient
  .from('customer_contacts')
  .select('line_user_id, line_is_blocked, notify_by_line')
  .eq('phone', phone)
  .single();

// 檢查通知偏好
if (data && data.line_user_id && 
    !data.line_is_blocked && 
    data.notify_by_line !== false) {
  // 發送 LINE 通知
}
```

---

## 📊 統計查詢

### 顧客綁定統計

```sql
SELECT 
  COUNT(*) as total_customers,
  COUNT(line_user_id) as has_line,
  COUNT(email) as has_email,
  COUNT(CASE WHEN line_user_id IS NOT NULL AND email IS NOT NULL THEN 1 END) as has_both,
  COUNT(CASE WHEN line_user_id IS NULL AND email IS NULL THEN 1 END) as has_none
FROM customer_contacts;
```

### 通知偏好統計

```sql
SELECT 
  COUNT(CASE WHEN notify_by_line = true THEN 1 END) as line_enabled,
  COUNT(CASE WHEN notify_by_line = false THEN 1 END) as line_disabled,
  COUNT(CASE WHEN notify_by_email = true THEN 1 END) as email_enabled,
  COUNT(CASE WHEN notify_by_email = false THEN 1 END) as email_disabled
FROM customer_contacts;
```

### 查看未完整綁定的顧客

```sql
-- 只有 LINE 沒有 Email
SELECT phone, name, line_display_name 
FROM customer_contacts 
WHERE line_user_id IS NOT NULL AND email IS NULL
ORDER BY created_at DESC;

-- 只有 Email 沒有 LINE
SELECT phone, name, email 
FROM customer_contacts 
WHERE email IS NOT NULL AND line_user_id IS NULL
ORDER BY created_at DESC;
```

---

## 🎯 未來擴展

統一表的設計便於未來添加更多聯絡方式：

```sql
-- 未來可添加的欄位範例
ALTER TABLE customer_contacts ADD COLUMN sms_enabled BOOLEAN DEFAULT true;
ALTER TABLE customer_contacts ADD COLUMN whatsapp_number VARCHAR(20);
ALTER TABLE customer_contacts ADD COLUMN wechat_id VARCHAR(255);
ALTER TABLE customer_contacts ADD COLUMN telegram_id VARCHAR(255);
```

---

## ⚠️ 注意事項

### 1. 通知偏好預設值

- `notify_by_line` 預設為 `true`
- `notify_by_email` 預設為 `true`
- 顧客可在個人設定中修改（未來功能）

### 2. 資料一致性

- `phone` 為主鍵，確保唯一性
- LINE 和 Email 可以為 `NULL`（未綁定）
- 更新時會自動觸發 `updated_at`

### 3. 舊表處理

- 建議保留備份表至少 1 個月
- 確認系統穩定後再刪除舊表
- 可考慮導出為 CSV 備份

---

## 🧪 測試檢查清單

- [ ] SQL 遷移執行成功
- [ ] 資料完整性驗證通過
- [ ] Email 綁定功能正常
- [ ] LINE 綁定功能正常
- [ ] 寄件 Email 通知正常
- [ ] 取件 Email 通知正常
- [ ] 寄件 LINE 通知正常
- [ ] 取件 LINE 通知正常
- [ ] 通知偏好正常運作
- [ ] 前端無 Console 錯誤
- [ ] Linter 檢查通過

---

## 📞 疑難排解

### Q1: 遷移後無法收到通知？

**檢查：**
1. `customer_contacts` 表是否有該顧客資料
2. `notify_by_line` 或 `notify_by_email` 是否為 `true`
3. LINE: `line_is_blocked` 是否為 `false`
4. Console 是否有錯誤訊息

### Q2: 舊資料沒有遷移？

**解決：**
```sql
-- 重新執行資料遷移部分（SQL 文件第 4 節）
-- 使用 ON CONFLICT DO UPDATE 確保不會重複
```

### Q3: 想回復到舊的表結構？

**步驟：**
```sql
-- 1. 從備份表恢復
ALTER TABLE line_bindings_backup RENAME TO line_bindings;
ALTER TABLE email_bindings_backup RENAME TO email_bindings;

-- 2. 刪除新表
DROP TABLE customer_contacts;

-- 3. 回復前端代碼（使用 Git）
git checkout -- email-notify-helper.js line-notify-helper.js
```

---

**🎉 遷移完成後，您將擁有一個統一、高效的顧客聯絡資訊系統！**

