# 🔧 LINE 綁定問題快速修復指南

## 問題：「系統尚未設定 LINE LIFF」

---

## ✅ 已完成的修復

### 1. 修改 `line-bind.html`
- ✅ 將 `config-loader.js` 的邏輯內嵌到頁面中
- ✅ 使用本地的 `supabaseClient` 實例
- ✅ 確保載入順序正確

---

## 🔍 立即測試步驟

### 步驟 1：重新整理頁面

在 `line-bind.html` 頁面按 `F5` 重新整理。

### 步驟 2：查看 Console 輸出

打開瀏覽器 Console (F12)，應該看到：

```javascript
🚀 初始化 LIFF...
🔄 正在從 Supabase 載入 LINE 設定...
```

---

## 📊 可能的結果

### ✅ 成功情況

```javascript
🚀 初始化 LIFF...
🔄 正在從 Supabase 載入 LINE 設定...
✅ LINE 設定載入成功 {LINE_LOGIN_CHANNEL_ID: "2008510299", LINE_LIFF_ID: "2008510299-QK9pYMgd"}
✅ LINE 設定已更新
  - LOGIN_CHANNEL_ID: 2008510299
  - LIFF_ID: 2008510299-QK9pYMgd
✅ LIFF 初始化成功
```

**→ 綁定功能正常，可以使用！**

---

### ❌ RLS 政策阻擋

```javascript
🚀 初始化 LIFF...
🔄 正在從 Supabase 載入 LINE 設定...
❌ 載入設定失敗： {code: "42501", message: "new row violates row-level security policy"}
⚠️ 系統尚未設定 LINE LIFF，請聯繫管理員。
```

**→ 需要修復 RLS 政策**

#### 解決方法：

1. 前往 Supabase Dashboard → SQL Editor
2. 執行 `fix-app-settings-rls.sql` 的內容：

```sql
-- 刪除現有政策
DROP POLICY IF EXISTS "公開讀取非敏感設定" ON app_settings;
DROP POLICY IF EXISTS "認證用戶讀取所有設定" ON app_settings;

-- 重新建立政策（允許所有人讀取非敏感設定）
CREATE POLICY "allow_public_read_non_sensitive" ON app_settings
  FOR SELECT
  USING (is_sensitive = false);
```

3. 重新整理頁面

---

### ❌ 找不到資料

```javascript
🚀 初始化 LIFF...
🔄 正在從 Supabase 載入 LINE 設定...
✅ LINE 設定載入成功 {}
✅ LINE 設定已更新
  - LOGIN_CHANNEL_ID: 
  - LIFF_ID: 
⚠️ 系統尚未設定 LINE LIFF，請聯繫管理員。
```

**→ 資料庫中沒有設定資料**

#### 解決方法：

1. 前往 Supabase Dashboard → SQL Editor
2. 確認資料是否存在：

```sql
SELECT * FROM app_settings;
```

3. 如果為空，重新插入資料：

```sql
INSERT INTO app_settings (setting_key, setting_value, description, is_sensitive) VALUES
  ('LINE_LOGIN_CHANNEL_ID', '2008510299', 'LINE Login Channel ID', false),
  ('LINE_LIFF_ID', '2008510299-QK9pYMgd', 'LIFF App ID', false),
  ('LINE_CHANNEL_ACCESS_TOKEN', 'YOUR_ACCESS_TOKEN_HERE', 'LINE Messaging API Channel Access Token', true)
ON CONFLICT (setting_key) DO UPDATE 
  SET setting_value = EXCLUDED.setting_value;
```

---

### ❌ 表不存在

```javascript
🚀 初始化 LIFF...
🔄 正在從 Supabase 載入 LINE 設定...
❌ 載入設定失敗： {code: "42P01", message: "relation \"app_settings\" does not exist"}
⚠️ 系統尚未設定 LINE LIFF，請聯繫管理員。
```

**→ `app_settings` 表未建立**

#### 解決方法：

執行完整的 `supabase/create-app-settings.sql` 檔案。

---

## 🔧 萬能測試命令

在 Console 中執行以下命令，可以直接測試查詢：

```javascript
// 測試查詢 app_settings 表
const { data, error } = await supabaseClient
  .from('app_settings')
  .select('*');

console.log('資料:', data);
console.log('錯誤:', error);
```

---

## 📝 檢查清單

- [ ] `app_settings` 表已建立
- [ ] 表中有 3 筆資料（LINE_LOGIN_CHANNEL_ID, LINE_LIFF_ID, LINE_CHANNEL_ACCESS_TOKEN）
- [ ] RLS 政策允許讀取非敏感設定
- [ ] `line-bind.html` 已更新（使用內嵌版本的載入邏輯）
- [ ] 重新整理頁面後 Console 顯示成功訊息
- [ ] 可以進入 LINE Login 流程

---

## 🎯 預期最終結果

當一切設定正確後，訪問 `line-bind.html` 應該：

1. ✅ 自動載入 LINE 設定
2. ✅ 初始化 LIFF
3. ✅ 如果未登入，導向 LINE Login
4. ✅ 登入後顯示手機號輸入畫面
5. ✅ 輸入手機號後完成綁定

---

## 🆘 還是有問題？

請在 Console 執行以下命令並回報結果：

```javascript
// 1. 檢查 Supabase 連線
console.log('Supabase URL:', CONFIG.SUPABASE.URL);
console.log('Supabase Client:', supabaseClient);

// 2. 測試資料庫查詢
const { data, error } = await supabaseClient
  .from('app_settings')
  .select('*');
console.log('查詢結果:', { data, error });

// 3. 檢查 CONFIG
console.log('CONFIG.LINE:', CONFIG.LINE);

// 4. 手動載入設定
await initLineConfigLocal();
console.log('載入後 CONFIG.LINE:', CONFIG.LINE);
```

---

© 2025 BaiFa.GRP
版本：1.4.1
最後更新：2025/11/17

