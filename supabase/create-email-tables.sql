-- ====================================
-- Email 通知系統資料表
-- ====================================

-- 1. Email 綁定表（存儲用戶電話與 Email 的對應關係）
CREATE TABLE IF NOT EXISTS email_bindings (
  id BIGSERIAL PRIMARY KEY,
  phone VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(100),
  verified BOOLEAN DEFAULT false,
  verification_code VARCHAR(10),
  code_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- 創建索引加速查詢
CREATE INDEX IF NOT EXISTS idx_email_bindings_phone ON email_bindings(phone);
CREATE INDEX IF NOT EXISTS idx_email_bindings_email ON email_bindings(email);

-- 更新時間戳觸發器
CREATE OR REPLACE FUNCTION update_email_bindings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_email_bindings_updated_at
  BEFORE UPDATE ON email_bindings
  FOR EACH ROW
  EXECUTE FUNCTION update_email_bindings_updated_at();

-- 2. Email 通知記錄表（記錄所有發送的 Email）
CREATE TABLE IF NOT EXISTS email_notifications (
  id BIGSERIAL PRIMARY KEY,
  shipment_id BIGINT REFERENCES shipments(id) ON DELETE SET NULL,
  email VARCHAR(255) NOT NULL,
  notification_type VARCHAR(50) NOT NULL, -- 'shipment_created', 'pickup_success', 等
  status VARCHAR(20) NOT NULL, -- 'sent', 'failed'
  error_message TEXT,
  tracking_no VARCHAR(50),
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB -- 額外資訊
);

-- 創建索引
CREATE INDEX IF NOT EXISTS idx_email_notifications_shipment ON email_notifications(shipment_id);
CREATE INDEX IF NOT EXISTS idx_email_notifications_email ON email_notifications(email);
CREATE INDEX IF NOT EXISTS idx_email_notifications_type ON email_notifications(notification_type);
CREATE INDEX IF NOT EXISTS idx_email_notifications_status ON email_notifications(status);
CREATE INDEX IF NOT EXISTS idx_email_notifications_sent_at ON email_notifications(sent_at DESC);

-- ====================================
-- RLS 政策設定
-- ====================================

-- Email 綁定表 RLS
ALTER TABLE email_bindings ENABLE ROW LEVEL SECURITY;

-- 允許匿名用戶查詢和新增綁定
DROP POLICY IF EXISTS "允許查詢 Email 綁定" ON email_bindings;
CREATE POLICY "允許查詢 Email 綁定" ON email_bindings
  FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "允許新增 Email 綁定" ON email_bindings;
CREATE POLICY "允許新增 Email 綁定" ON email_bindings
  FOR INSERT TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "允許更新 Email 綁定" ON email_bindings;
CREATE POLICY "允許更新 Email 綁定" ON email_bindings
  FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);

-- Email 通知記錄表 RLS
ALTER TABLE email_notifications ENABLE ROW LEVEL SECURITY;

-- 允許新增通知記錄
DROP POLICY IF EXISTS "允許新增 Email 通知記錄" ON email_notifications;
CREATE POLICY "允許新增 Email 通知記錄" ON email_notifications
  FOR INSERT TO anon, authenticated WITH CHECK (true);

-- 允許查詢通知記錄
DROP POLICY IF EXISTS "允許查詢 Email 通知記錄" ON email_notifications;
CREATE POLICY "允許查詢 Email 通知記錄" ON email_notifications
  FOR SELECT TO anon, authenticated USING (true);

-- 已登入用戶完整權限
DROP POLICY IF EXISTS "已登入用戶完整權限_email_notifications" ON email_notifications;
CREATE POLICY "已登入用戶完整權限_email_notifications" ON email_notifications
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ====================================
-- 測試資料（可選）
-- ====================================

-- 插入測試綁定（請根據實際情況修改）
-- INSERT INTO email_bindings (phone, email, name, verified)
-- VALUES 
--   ('0912345678', 'test@example.com', '測試用戶', true),
--   ('0987654321', 'demo@example.com', '示範用戶', true)
-- ON CONFLICT (phone) DO NOTHING;

-- ====================================
-- 查詢範例
-- ====================================

-- 查看所有 Email 綁定
-- SELECT * FROM email_bindings ORDER BY created_at DESC;

-- 查看最近的 Email 通知記錄
-- SELECT * FROM email_notifications ORDER BY sent_at DESC LIMIT 20;

-- 統計每種類型的通知數量
-- SELECT notification_type, status, COUNT(*) 
-- FROM email_notifications 
-- GROUP BY notification_type, status;

COMMENT ON TABLE email_bindings IS 'Email 綁定表 - 儲存用戶電話與 Email 的對應關係';
COMMENT ON TABLE email_notifications IS 'Email 通知記錄表 - 記錄所有發送的 Email 通知';

