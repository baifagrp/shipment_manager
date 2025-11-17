-- ============================================
-- 修復 app_settings 表的 RLS 政策
-- 如果出現「系統尚未設定」錯誤，執行此 SQL
-- ============================================

-- 1. 刪除現有政策（如果有衝突）
DROP POLICY IF EXISTS "公開讀取非敏感設定" ON app_settings;
DROP POLICY IF EXISTS "認證用戶讀取所有設定" ON app_settings;

-- 2. 重新建立政策
-- 允許任何人（包括未登入用戶）讀取非敏感設定
CREATE POLICY "allow_public_read_non_sensitive" ON app_settings
  FOR SELECT
  USING (is_sensitive = false);

-- 允許認證用戶讀取所有設定（包括敏感設定）
CREATE POLICY "allow_authenticated_read_all" ON app_settings
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- 3. 或者，如果上面的政策還是不行，暫時允許所有人讀取所有設定（測試用）
-- DROP POLICY IF EXISTS "allow_public_read_non_sensitive" ON app_settings;
-- CREATE POLICY "allow_public_read_all_temp" ON app_settings
--   FOR SELECT
--   USING (true);

-- 4. 確認政策已建立
SELECT schemaname, tablename, policyname, permissive, cmd 
FROM pg_policies 
WHERE tablename = 'app_settings';

-- ============================================
-- 測試查詢
-- ============================================
-- 執行以下查詢確認可以讀取設定
SELECT setting_key, setting_value, is_sensitive 
FROM app_settings 
WHERE is_sensitive = false
ORDER BY setting_key;

