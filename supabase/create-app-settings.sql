-- ============================================
-- 建立應用程式設定表
-- 用途：安全儲存 LINE API Keys 和其他敏感設定
-- ============================================

-- 1. 建立 app_settings 資料表
CREATE TABLE IF NOT EXISTS app_settings (
  id BIGSERIAL PRIMARY KEY,
  setting_key TEXT NOT NULL UNIQUE,
  setting_value TEXT NOT NULL,
  description TEXT,
  is_sensitive BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. 插入 LINE 相關設定
INSERT INTO app_settings (setting_key, setting_value, description, is_sensitive) VALUES
  ('LINE_LOGIN_CHANNEL_ID', '2008510299', 'LINE Login Channel ID', false),
  ('LINE_LIFF_ID', '2008510299-QK9pYMgd', 'LIFF App ID', false),
  ('LINE_CHANNEL_ACCESS_TOKEN', 'YxOqg7ZIc3JpOQun2kJjmpuoPotzuXwicVjE6FvbRtuc+rSjencX6dJiUMfhY4DySgIY1uBpHhRidZTiZjQP7XPqgCkOJM7ey6eVB11B3AKgpV4MQ06X2O+lZTaYXPsrNobvkGXTbhwOBLD2CFyWAQdB04t89/1O/w1cDnyilFU=', 'LINE Messaging API Channel Access Token', true)
ON CONFLICT (setting_key) DO UPDATE 
  SET setting_value = EXCLUDED.setting_value,
      updated_at = NOW();

-- 3. 建立索引
CREATE INDEX IF NOT EXISTS idx_app_settings_key 
ON app_settings(setting_key);

-- 4. 建立更新時間觸發器
CREATE OR REPLACE FUNCTION update_app_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER app_settings_updated_at
  BEFORE UPDATE ON app_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_app_settings_updated_at();

-- 5. RLS 政策（Row Level Security）
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- 允許所有人讀取非敏感設定
CREATE POLICY "公開讀取非敏感設定" ON app_settings
  FOR SELECT
  USING (is_sensitive = false);

-- 只允許認證用戶讀取所有設定（包括敏感設定）
CREATE POLICY "認證用戶讀取所有設定" ON app_settings
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- 只允許認證用戶更新設定
CREATE POLICY "認證用戶更新設定" ON app_settings
  FOR UPDATE
  USING (auth.role() = 'authenticated');

-- 6. 建立讀取設定的函數
CREATE OR REPLACE FUNCTION get_app_setting(p_key TEXT)
RETURNS TEXT AS $$
DECLARE
  v_value TEXT;
BEGIN
  SELECT setting_value INTO v_value
  FROM app_settings
  WHERE setting_key = p_key;
  
  RETURN v_value;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. 更新 send_line_notification 函數以使用資料庫設定
CREATE OR REPLACE FUNCTION send_line_notification(
  p_line_user_id TEXT,
  p_message JSONB
)
RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
  v_access_token TEXT;
BEGIN
  -- 從資料庫讀取 Access Token
  SELECT setting_value INTO v_access_token
  FROM app_settings
  WHERE setting_key = 'LINE_CHANNEL_ACCESS_TOKEN';
  
  IF v_access_token IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'LINE_CHANNEL_ACCESS_TOKEN not found in database'
    );
  END IF;
  
  -- 呼叫 LINE Messaging API
  SELECT content::JSONB INTO v_result
  FROM http((
    'POST',
    'https://api.line.me/v2/bot/message/push',
    ARRAY[
      http_header('Content-Type', 'application/json'),
      http_header('Authorization', 'Bearer ' || v_access_token)
    ],
    'application/json',
    jsonb_build_object(
      'to', p_line_user_id,
      'messages', jsonb_build_array(p_message)
    )::TEXT
  )::http_request);
  
  RETURN jsonb_build_object(
    'success', true,
    'result', v_result
  );
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object(
    'success', false,
    'error', SQLERRM
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 查詢設定（測試用）
-- ============================================
-- 查看所有設定
-- SELECT setting_key, 
--        CASE WHEN is_sensitive THEN '***hidden***' ELSE setting_value END as value,
--        description, 
--        is_sensitive 
-- FROM app_settings 
-- ORDER BY setting_key;

-- 查詢特定設定
-- SELECT get_app_setting('LINE_LOGIN_CHANNEL_ID');

-- 更新設定
-- UPDATE app_settings 
-- SET setting_value = 'NEW_VALUE' 
-- WHERE setting_key = 'LINE_CHANNEL_ACCESS_TOKEN';

-- ============================================
-- 安全說明
-- ============================================
-- ✅ 優點：
-- 1. Access Token 不再暴露在前端 config.js 中
-- 2. 可以透過 Dashboard 安全地更新設定
-- 3. RLS 保護敏感資料
-- 4. 只有後端函數可以讀取 Access Token
--
-- ⚠️ 注意：
-- 1. 非敏感設定（LIFF_ID、LOGIN_CHANNEL_ID）前端仍需讀取
-- 2. 敏感設定只在後端函數中使用
-- 3. 定期更換 Access Token 以提高安全性
-- ============================================

