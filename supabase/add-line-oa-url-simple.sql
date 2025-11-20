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

SELECT * FROM app_settings WHERE setting_key = 'LINE_OA_URL';


