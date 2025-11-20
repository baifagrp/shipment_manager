-- ========================================
-- 新增 LINE 官方帳號連結設定
-- ========================================
-- 在 app_settings 表中新增 LINE OA URL 欄位
-- 用於首頁顯示「加入 LINE 官方帳號」按鈕
-- ========================================

-- 1. 在 app_settings 表中新增 LINE OA URL 設定
-- ========================================
INSERT INTO app_settings (setting_key, setting_value, description, is_sensitive)
VALUES (
  'LINE_OA_URL',
  'https://line.me/R/ti/p/@YOUR_LINE_ID',
  'LINE 官方帳號連結網址（用於首頁加好友按鈕）',
  false
)
ON CONFLICT (setting_key) DO UPDATE
SET 
  setting_value = EXCLUDED.setting_value,
  description = EXCLUDED.description,
  updated_at = NOW();

-- 2. 確認設定已新增
SELECT * FROM app_settings WHERE setting_key = 'LINE_OA_URL';

-- ========================================
-- 完成！
-- ========================================
-- 
-- 使用說明：
-- 1. 將 '@YOUR_LINE_ID' 替換為您的 LINE 官方帳號 ID
--    例如：https://line.me/R/ti/p/@abc1234
-- 
-- 2. 也可以使用 QR Code 連結格式：
--    https://liff.line.me/YOUR_LIFF_ID
-- 
-- 3. 前端會自動從此設定載入 URL 並顯示在首頁
-- 
-- ========================================

