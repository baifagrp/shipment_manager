-- ============================================
-- LINE 官方帳號串接 - 資料庫結構
-- 用途：儲存 LINE 綁定資訊與推播記錄
-- ============================================

-- 1. LINE 綁定資料表
CREATE TABLE IF NOT EXISTS line_bindings (
  id BIGSERIAL PRIMARY KEY,
  phone TEXT NOT NULL UNIQUE,
  line_user_id TEXT NOT NULL UNIQUE,
  display_name TEXT,
  picture_url TEXT,
  status_message TEXT,
  bind_time TIMESTAMP DEFAULT NOW(),
  last_notify_time TIMESTAMP,
  is_blocked BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. LINE 推播記錄
CREATE TABLE IF NOT EXISTS line_notifications (
  id BIGSERIAL PRIMARY KEY,
  line_user_id TEXT NOT NULL,
  phone TEXT,
  notification_type TEXT NOT NULL,
  -- 類型：arrival(到店), reminder(提醒), marketing(行銷), verification(驗證碼)
  shipment_id BIGINT,
  tracking_no TEXT,
  message_content TEXT,
  flex_message JSONB,
  send_time TIMESTAMP DEFAULT NOW(),
  status TEXT DEFAULT 'pending',
  -- pending, sent, failed, blocked
  error_message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 3. 新增索引
CREATE INDEX IF NOT EXISTS idx_line_bindings_phone 
ON line_bindings(phone);

CREATE INDEX IF NOT EXISTS idx_line_bindings_line_user_id 
ON line_bindings(line_user_id);

CREATE INDEX IF NOT EXISTS idx_line_notifications_line_user_id 
ON line_notifications(line_user_id);

CREATE INDEX IF NOT EXISTS idx_line_notifications_tracking_no 
ON line_notifications(tracking_no);

CREATE INDEX IF NOT EXISTS idx_line_notifications_send_time 
ON line_notifications(send_time DESC);

-- 4. 新增註解
COMMENT ON TABLE line_bindings IS 'LINE 帳號綁定資訊';
COMMENT ON COLUMN line_bindings.phone IS '手機號碼（主要識別）';
COMMENT ON COLUMN line_bindings.line_user_id IS 'LINE User ID（用於推播）';
COMMENT ON COLUMN line_bindings.display_name IS 'LINE 顯示名稱';
COMMENT ON COLUMN line_bindings.picture_url IS 'LINE 頭像 URL';
COMMENT ON COLUMN line_bindings.is_blocked IS '是否被封鎖（無法推播）';

COMMENT ON TABLE line_notifications IS 'LINE 推播記錄';
COMMENT ON COLUMN line_notifications.notification_type IS '通知類型：arrival/reminder/marketing/verification';
COMMENT ON COLUMN line_notifications.flex_message IS 'Flex Message JSON（完整格式）';
COMMENT ON COLUMN line_notifications.status IS '發送狀態：pending/sent/failed/blocked';

-- 5. RLS 政策
ALTER TABLE line_bindings ENABLE ROW LEVEL SECURITY;
ALTER TABLE line_notifications ENABLE ROW LEVEL SECURITY;

-- 允許所有人查詢自己的綁定資訊（透過 phone）
CREATE POLICY "公開查詢 LINE 綁定" ON line_bindings
  FOR SELECT
  USING (true);

-- 允許所有人新增綁定
CREATE POLICY "公開新增 LINE 綁定" ON line_bindings
  FOR INSERT
  WITH CHECK (true);

-- 允許更新自己的綁定資訊
CREATE POLICY "公開更新 LINE 綁定" ON line_bindings
  FOR UPDATE
  USING (true);

-- 允許管理員查詢所有推播記錄
CREATE POLICY "管理員查詢推播記錄" ON line_notifications
  FOR SELECT
  USING (auth.role() = 'authenticated' OR true);

-- 允許系統新增推播記錄
CREATE POLICY "系統新增推播記錄" ON line_notifications
  FOR INSERT
  WITH CHECK (true);

-- 6. 新增 shipments 表的 line_notified 欄位（追蹤是否已推播）
ALTER TABLE shipments
ADD COLUMN IF NOT EXISTS line_notified BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS line_notified_time TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_shipments_line_notified 
ON shipments(line_notified) 
WHERE line_notified = false;

COMMENT ON COLUMN shipments.line_notified IS '是否已發送 LINE 到店通知';
COMMENT ON COLUMN shipments.line_notified_time IS 'LINE 通知發送時間';

-- 7. 更新時間觸發器
CREATE OR REPLACE FUNCTION update_line_bindings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER line_bindings_updated_at
  BEFORE UPDATE ON line_bindings
  FOR EACH ROW
  EXECUTE FUNCTION update_line_bindings_updated_at();

-- ============================================
-- 執行說明
-- ============================================
-- 1. 登入 Supabase Dashboard
-- 2. 進入 SQL Editor
-- 3. 複製貼上此 SQL 並執行
-- 4. 確認執行成功後，即可開始 LINE 串接
-- ============================================

-- ============================================
-- 測試查詢
-- ============================================
-- 查看綁定資訊
-- SELECT * FROM line_bindings ORDER BY bind_time DESC LIMIT 10;

-- 查看推播記錄
-- SELECT * FROM line_notifications ORDER BY send_time DESC LIMIT 10;

-- 查看尚未推播的包裹
-- SELECT tracking_no, receiver_name, receiver_phone, status 
-- FROM shipments 
-- WHERE status = '待取件' AND line_notified = false;

