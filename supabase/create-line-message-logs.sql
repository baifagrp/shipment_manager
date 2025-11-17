-- ============================================
-- 建立 LINE 訊息發送記錄表
-- 用途：記錄所有管理員手動發送的 LINE 訊息
-- ============================================

-- 1. 建立 line_message_logs 資料表
CREATE TABLE IF NOT EXISTS line_message_logs (
  id BIGSERIAL PRIMARY KEY,
  sender_uid UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  receiver_line_uid TEXT NOT NULL,
  receiver_phone TEXT,
  message_type TEXT NOT NULL CHECK (message_type IN ('text', 'flex')),
  message_content TEXT,
  flex_message JSONB,
  send_status TEXT DEFAULT 'sent' CHECK (send_status IN ('sent', 'failed', 'pending')),
  error_message TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. 建立索引以加速查詢
CREATE INDEX IF NOT EXISTS idx_line_message_logs_sender 
ON line_message_logs(sender_uid);

CREATE INDEX IF NOT EXISTS idx_line_message_logs_receiver 
ON line_message_logs(receiver_line_uid);

CREATE INDEX IF NOT EXISTS idx_line_message_logs_phone 
ON line_message_logs(receiver_phone);

CREATE INDEX IF NOT EXISTS idx_line_message_logs_created 
ON line_message_logs(created_at DESC);

-- 3. 建立更新時間觸發器
CREATE OR REPLACE FUNCTION update_line_message_logs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER line_message_logs_updated_at
  BEFORE UPDATE ON line_message_logs
  FOR EACH ROW
  EXECUTE FUNCTION update_line_message_logs_updated_at();

-- 4. 新增註解說明
COMMENT ON TABLE line_message_logs IS 'LINE 訊息發送記錄表';
COMMENT ON COLUMN line_message_logs.id IS '主鍵';
COMMENT ON COLUMN line_message_logs.sender_uid IS '操作人 Supabase UID';
COMMENT ON COLUMN line_message_logs.receiver_line_uid IS '接收者 LINE UserID';
COMMENT ON COLUMN line_message_logs.receiver_phone IS '接收者手機號（方便查詢）';
COMMENT ON COLUMN line_message_logs.message_type IS '訊息類型（text / flex）';
COMMENT ON COLUMN line_message_logs.message_content IS '訊息內容（純文字）';
COMMENT ON COLUMN line_message_logs.flex_message IS 'Flex Message JSON 內容';
COMMENT ON COLUMN line_message_logs.send_status IS '發送狀態（sent / failed / pending）';
COMMENT ON COLUMN line_message_logs.error_message IS '錯誤訊息（如果發送失敗）';
COMMENT ON COLUMN line_message_logs.created_at IS '發送時間';
COMMENT ON COLUMN line_message_logs.updated_at IS '更新時間';

-- 5. RLS 政策（Row Level Security）
ALTER TABLE line_message_logs ENABLE ROW LEVEL SECURITY;

-- 允許認證用戶插入記錄
CREATE POLICY "allow_authenticated_insert" ON line_message_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- 允許認證用戶查看自己發送的記錄
CREATE POLICY "allow_authenticated_select_own" ON line_message_logs
  FOR SELECT
  TO authenticated
  USING (sender_uid = auth.uid());

-- 允許管理員查看所有記錄
CREATE POLICY "allow_admin_select_all" ON line_message_logs
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE id = auth.uid()
      AND raw_user_meta_data->>'role' = 'admin'
    )
  );

-- ============================================
-- 查詢範例
-- ============================================

-- 查詢最近 10 筆發送記錄
-- SELECT 
--   id,
--   sender_uid,
--   receiver_phone,
--   message_type,
--   CASE 
--     WHEN message_type = 'text' THEN message_content
--     WHEN message_type = 'flex' THEN '(Flex Message)'
--   END as content_preview,
--   send_status,
--   created_at
-- FROM line_message_logs
-- ORDER BY created_at DESC
-- LIMIT 10;

-- 查詢特定用戶的發送記錄
-- SELECT *
-- FROM line_message_logs
-- WHERE receiver_phone = '0912345678'
-- ORDER BY created_at DESC;

-- 統計發送數量（依類型）
-- SELECT 
--   message_type,
--   COUNT(*) as total,
--   SUM(CASE WHEN send_status = 'sent' THEN 1 ELSE 0 END) as success,
--   SUM(CASE WHEN send_status = 'failed' THEN 1 ELSE 0 END) as failed
-- FROM line_message_logs
-- GROUP BY message_type;

-- 查詢今日發送統計
-- SELECT 
--   sender_uid,
--   COUNT(*) as total_sent,
--   COUNT(CASE WHEN message_type = 'text' THEN 1 END) as text_count,
--   COUNT(CASE WHEN message_type = 'flex' THEN 1 END) as flex_count
-- FROM line_message_logs
-- WHERE DATE(created_at) = CURRENT_DATE
-- GROUP BY sender_uid;

-- ============================================
-- 執行說明
-- ============================================
-- 1. 登入 Supabase Dashboard
-- 2. 進入 SQL Editor
-- 3. 複製貼上此 SQL 並執行
-- 4. 確認執行成功後，即可使用訊息發送功能
-- ============================================

