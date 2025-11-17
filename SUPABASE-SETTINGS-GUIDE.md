# 🔐 Supabase 設定儲存指南

## 📋 概述

本系統已將敏感的 LINE API Keys 從前端 `config.js` 移至 Supabase 資料庫安全儲存。

---

## ✅ 優勢

### 🔒 安全性提升
| 項目 | 之前 (config.js) | 現在 (Supabase) |
|------|-----------------|----------------|
| **Access Token** | ❌ 暴露在前端 | ✅ 安全儲存在資料庫 |
| **可見性** | ❌ 任何人都能看到 | ✅ 只有後端函數可存取 |
| **修改** | ❌ 需要重新部署 | ✅ Dashboard 即時更新 |
| **版本控制** | ❌ 會被 commit | ✅ 不會進入 Git |

### ⚡ 其他優點
- ✅ 集中管理所有設定
- ✅ 可透過 Dashboard 即時更新
- ✅ 支援多環境設定（開發/測試/正式）
- ✅ 有完整的更新歷史記錄

---

## 📝 步驟 1：執行 SQL 建立資料表

### 1-1. 登入 Supabase Dashboard
前往：https://supabase.com/dashboard

### 1-2. 進入 SQL Editor
Project → SQL Editor → New query

### 1-3. 執行 SQL
複製並執行 `supabase/create-app-settings.sql` 的內容

### 1-4. 確認建立成功
執行以下查詢確認：
```sql
SELECT setting_key, 
       CASE WHEN is_sensitive THEN '***hidden***' ELSE setting_value END as value,
       description, 
       is_sensitive 
FROM app_settings 
ORDER BY setting_key;
```

應該看到：
```
setting_key                  | value           | description                     | is_sensitive
-----------------------------|-----------------|---------------------------------|-------------
LINE_CHANNEL_ACCESS_TOKEN    | ***hidden***    | LINE Messaging API Access Token | true
LINE_LIFF_ID                 | 2008510299-...  | LIFF App ID                     | false
LINE_LOGIN_CHANNEL_ID        | 2008510299      | LINE Login Channel ID           | false
```

---

## 🔧 步驟 2：檔案結構說明

### 新增的檔案

1. **`supabase/create-app-settings.sql`**
   - 建立 `app_settings` 資料表
   - 設定 RLS 政策
   - 更新 `send_line_notification` 函數

2. **`config-loader.js`**
   - 從 Supabase 動態載入設定
   - 自動更新 `CONFIG.LINE` 物件

3. **`SUPABASE-SETTINGS-GUIDE.md`** (本檔案)
   - 完整的使用與設定指南

### 修改的檔案

1. **`config.js`**
   - 移除硬編碼的 Keys
   - 設為空值，由 `config-loader.js` 動態填入

2. **`index.html`**
   - 加入 `config-loader.js`
   - 在 `init()` 時呼叫 `initLineConfig()`

3. **`pages/customer/line-bind.html`**
   - 加入 `config-loader.js`
   - 在 `initLiff()` 前載入設定

4. **`pages/customer/shpsearch.html`**
   - 加入 `config-loader.js`
   - 在 `initLiff()` 前載入設定

---

## 🎯 步驟 3：工作流程

### 系統啟動流程

```
1. 載入 config.js (靜態設定)
   ↓
2. 載入 config-loader.js (載入器)
   ↓
3. 呼叫 initLineConfig()
   ↓
4. 從 Supabase 讀取 LINE 設定
   ↓
5. 更新 CONFIG.LINE 物件
   ↓
6. 系統正常運作
```

### Console 訊息

正常啟動時，您會看到：

```javascript
🔄 正在從 Supabase 載入 LINE 設定...
✅ LINE 設定載入成功
✅ LINE 設定已更新
  - LOGIN_CHANNEL_ID: 2008510299
  - LIFF_ID: 2008510299-QK9pYMgd
```

---

## 🔑 步驟 4：管理設定

### 方法 A：透過 Supabase Dashboard（推薦）

1. 進入 **Table Editor** → `app_settings`
2. 找到要修改的設定行
3. 雙擊 `setting_value` 欄位編輯
4. 儲存變更

⚡ **立即生效**：重新整理頁面即可使用新設定

### 方法 B：透過 SQL

```sql
-- 更新 Access Token
UPDATE app_settings 
SET setting_value = 'NEW_ACCESS_TOKEN_HERE' 
WHERE setting_key = 'LINE_CHANNEL_ACCESS_TOKEN';

-- 更新 LIFF ID
UPDATE app_settings 
SET setting_value = 'NEW_LIFF_ID_HERE' 
WHERE setting_key = 'LINE_LIFF_ID';

-- 更新 Channel ID
UPDATE app_settings 
SET setting_value = 'NEW_CHANNEL_ID_HERE' 
WHERE setting_key = 'LINE_LOGIN_CHANNEL_ID';
```

---

## 🧪 步驟 5：測試

### 測試 1：前端設定載入

在瀏覽器 Console 執行：

```javascript
// 測試載入設定
await initLineConfig();

// 檢查設定
console.log('LOGIN_CHANNEL_ID:', CONFIG.LINE.LOGIN_CHANNEL_ID);
console.log('LIFF_ID:', CONFIG.LINE.LIFF_ID);
```

### 測試 2：後端 RPC 函數

```sql
-- 測試讀取 Access Token
SELECT get_app_setting('LINE_CHANNEL_ACCESS_TOKEN');

-- 應該返回完整的 Token（後端可見）
```

### 測試 3：LINE 通知

建立一筆包裹並更新狀態為「包裹已配達取件門市」，檢查：
- ✅ 系統是否正常讀取設定
- ✅ LINE 通知是否正常發送
- ✅ Console 是否有錯誤訊息

---

## 🔒 安全最佳實踐

### ✅ 應該做的

1. **定期更換 Access Token**
   - 每 3-6 個月更換一次
   - 在 LINE Developers 重新 Issue
   - 在 Supabase 更新新的 Token

2. **限制資料庫存取**
   - 確保 RLS 政策正確設定
   - 只有認證用戶可讀取敏感設定
   - 只有後端函數可使用 Access Token

3. **監控異常存取**
   - 定期檢查 `app_settings` 表的 `updated_at`
   - 確保沒有未授權的修改

### ❌ 不應該做的

1. **不要在前端使用 Access Token**
   - Access Token 只在後端函數使用
   - 前端只需要 LIFF_ID 和 LOGIN_CHANNEL_ID

2. **不要將設定 commit 到 Git**
   - `config.js` 中的 Keys 保持空值
   - 實際值只存在 Supabase

3. **不要分享 Access Token**
   - 即使是團隊成員也應該透過 Supabase 存取
   - 不要透過訊息或 Email 傳送

---

## 🆘 故障排除

### 問題 1：前端無法讀取設定

**症狀**：
```javascript
✅ LINE 設定載入成功
✅ LINE 設定已更新
  - LOGIN_CHANNEL_ID: 
  - LIFF_ID: 
```

**原因**：`app_settings` 表為空或 RLS 阻擋

**解決**：
```sql
-- 檢查資料是否存在
SELECT * FROM app_settings;

-- 如果為空，重新執行 insert 語句
INSERT INTO app_settings (setting_key, setting_value, description, is_sensitive) VALUES
  ('LINE_LOGIN_CHANNEL_ID', '2008510299', 'LINE Login Channel ID', false),
  ('LINE_LIFF_ID', '2008510299-QK9pYMgd', 'LIFF App ID', false),
  ('LINE_CHANNEL_ACCESS_TOKEN', 'YOUR_TOKEN_HERE', 'LINE Messaging API Channel Access Token', true)
ON CONFLICT (setting_key) DO UPDATE 
  SET setting_value = EXCLUDED.setting_value;
```

### 問題 2：LINE 通知無法發送

**症狀**：
```javascript
❌ LINE 推播失敗： LINE_CHANNEL_ACCESS_TOKEN not found in database
```

**原因**：後端函數無法讀取 Access Token

**解決**：
```sql
-- 檢查函數是否正確
SELECT proname, prosrc 
FROM pg_proc 
WHERE proname = 'send_line_notification';

-- 重新執行 create-app-settings.sql 中的函數部分
```

### 問題 3：LIFF 初始化失敗

**症狀**：
```javascript
系統尚未設定 LINE LIFF，請聯繫管理員。
```

**原因**：設定尚未載入或 LIFF_ID 為空

**解決**：
1. 確認 `initLineConfig()` 在 `liff.init()` 之前執行
2. 檢查 Console 是否有載入成功訊息
3. 手動檢查：`console.log(CONFIG.LINE.LIFF_ID)`

---

## 📊 資料表結構

### `app_settings` 表

| 欄位 | 類型 | 說明 |
|------|------|------|
| `id` | BIGSERIAL | 主鍵 |
| `setting_key` | TEXT | 設定鍵（唯一） |
| `setting_value` | TEXT | 設定值 |
| `description` | TEXT | 說明 |
| `is_sensitive` | BOOLEAN | 是否為敏感資料 |
| `created_at` | TIMESTAMP | 建立時間 |
| `updated_at` | TIMESTAMP | 更新時間 |

### RLS 政策

1. **公開讀取非敏感設定**
   - 任何人可讀取 `is_sensitive = false` 的設定

2. **認證用戶讀取所有設定**
   - 登入用戶可讀取所有設定（包括敏感）

3. **認證用戶更新設定**
   - 只有登入用戶可更新設定

---

## 🎓 進階用法

### 新增自訂設定

```sql
-- 新增自訂設定
INSERT INTO app_settings (setting_key, setting_value, description, is_sensitive) 
VALUES ('CUSTOM_SETTING', 'custom_value', 'My custom setting', false);
```

### 前端讀取自訂設定

```javascript
// 在 config-loader.js 的 loadLineSettings 中新增
const { data, error } = await supabaseClient
  .from('app_settings')
  .select('setting_key, setting_value')
  .in('setting_key', [
    'LINE_LOGIN_CHANNEL_ID',
    'LINE_LIFF_ID',
    'CUSTOM_SETTING'  // ← 新增
  ]);
```

### 後端使用設定

```sql
-- 在任何 SQL 函數中使用
CREATE OR REPLACE FUNCTION my_function()
RETURNS TEXT AS $$
DECLARE
  v_custom_value TEXT;
BEGIN
  -- 讀取設定
  SELECT setting_value INTO v_custom_value
  FROM app_settings
  WHERE setting_key = 'CUSTOM_SETTING';
  
  RETURN v_custom_value;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 📁 相關文檔

- **LINE 設定指南**: `LINE-SETUP-GUIDE.md`
- **Flex Message 預覽**: `LINE-FLEX-MESSAGE-PREVIEW.md`
- **系統主文檔**: `README.md`

---

© 2025 BaiFa.GRP
版本：1.4.0
最後更新：2025/11/17

