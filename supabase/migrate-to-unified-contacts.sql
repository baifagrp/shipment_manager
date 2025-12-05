-- ============================================
-- 統一顧客聯絡資訊表
-- 整合 LINE 和 Email 綁定資料
-- ============================================

-- 1. 創建統一的顧客聯絡表
CREATE TABLE IF NOT EXISTS customer_contacts (
  id BIGSERIAL PRIMARY KEY,
  
  -- 基本資訊
  phone VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100),
  
  -- Email 相關
  email VARCHAR(255),
  email_verified BOOLEAN DEFAULT false,
  email_verification_code VARCHAR(10),
  email_code_expires_at TIMESTAMPTZ,
  
  -- LINE 相關
  line_user_id VARCHAR(255),
  line_display_name VARCHAR(255),
  line_picture_url TEXT,
  line_is_blocked BOOLEAN DEFAULT false,
  line_bound_at TIMESTAMPTZ,
  
  -- 通知偏好
  notify_by_line BOOLEAN DEFAULT true,
  notify_by_email BOOLEAN DEFAULT true,
  
  -- 時間戳
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- 約束
  CONSTRAINT valid_email CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  CONSTRAINT valid_phone CHECK (phone ~* '^[0-9]{10}$')
);

-- 2. 創建索引
CREATE INDEX IF NOT EXISTS idx_customer_contacts_phone ON customer_contacts(phone);
CREATE INDEX IF NOT EXISTS idx_customer_contacts_email ON customer_contacts(email);
CREATE INDEX IF NOT EXISTS idx_customer_contacts_line_user_id ON customer_contacts(line_user_id);

-- 3. 更新時間戳觸發器
CREATE OR REPLACE FUNCTION update_customer_contacts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_customer_contacts_updated_at ON customer_contacts;
CREATE TRIGGER trigger_update_customer_contacts_updated_at
  BEFORE UPDATE ON customer_contacts
  FOR EACH ROW
  EXECUTE FUNCTION update_customer_contacts_updated_at();

-- ============================================
-- 4. 遷移現有資料
-- ============================================

-- 從 line_bindings 遷移資料
INSERT INTO customer_contacts (
  phone,
  line_user_id,
  line_display_name,
  line_picture_url,
  line_is_blocked,
  line_bound_at,
  created_at
)
SELECT 
  phone,
  line_user_id,
  display_name,
  picture_url,
  is_blocked,
  created_at,  -- 使用 created_at 作為綁定時間
  created_at
FROM line_bindings
ON CONFLICT (phone) DO UPDATE
SET 
  line_user_id = EXCLUDED.line_user_id,
  line_display_name = EXCLUDED.line_display_name,
  line_picture_url = EXCLUDED.line_picture_url,
  line_is_blocked = EXCLUDED.line_is_blocked,
  line_bound_at = EXCLUDED.line_bound_at;

-- 從 email_bindings 遷移資料
INSERT INTO customer_contacts (
  phone,
  name,
  email,
  email_verified,
  created_at
)
SELECT 
  phone,
  name,
  email,
  verified,
  created_at
FROM email_bindings
ON CONFLICT (phone) DO UPDATE
SET 
  name = COALESCE(EXCLUDED.name, customer_contacts.name),
  email = EXCLUDED.email,
  email_verified = EXCLUDED.email_verified;

-- ============================================
-- 5. RLS 政策設定
-- ============================================

ALTER TABLE customer_contacts ENABLE ROW LEVEL SECURITY;

-- 允許查詢
DROP POLICY IF EXISTS "允許查詢顧客聯絡資訊" ON customer_contacts;
CREATE POLICY "允許查詢顧客聯絡資訊" ON customer_contacts
  FOR SELECT TO anon, authenticated USING (true);

-- 允許新增
DROP POLICY IF EXISTS "允許新增顧客聯絡資訊" ON customer_contacts;
CREATE POLICY "允許新增顧客聯絡資訊" ON customer_contacts
  FOR INSERT TO anon, authenticated WITH CHECK (true);

-- 允許更新
DROP POLICY IF EXISTS "允許更新顧客聯絡資訊" ON customer_contacts;
CREATE POLICY "允許更新顧客聯絡資訊" ON customer_contacts
  FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);

-- 已登入用戶完整權限
DROP POLICY IF EXISTS "已登入用戶完整權限_customer_contacts" ON customer_contacts;
CREATE POLICY "已登入用戶完整權限_customer_contacts" ON customer_contacts
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ============================================
-- 6. 創建實用的 Views
-- ============================================

-- 有 LINE 綁定的顧客
CREATE OR REPLACE VIEW customers_with_line AS
SELECT * FROM customer_contacts 
WHERE line_user_id IS NOT NULL AND line_is_blocked = false;

-- 有 Email 綁定的顧客
CREATE OR REPLACE VIEW customers_with_email AS
SELECT * FROM customer_contacts 
WHERE email IS NOT NULL;

-- 完整綁定的顧客（LINE + Email）
CREATE OR REPLACE VIEW customers_fully_bound AS
SELECT * FROM customer_contacts 
WHERE line_user_id IS NOT NULL 
  AND email IS NOT NULL 
  AND line_is_blocked = false;

-- ============================================
-- 7. 更新通知記錄表的外鍵（可選）
-- ============================================

-- 如果需要將 line_notifications 和 email_notifications 關聯到統一表
-- 可以添加 customer_phone 欄位作為外鍵

-- ALTER TABLE line_notifications 
--   ADD COLUMN IF NOT EXISTS customer_phone VARCHAR(20) REFERENCES customer_contacts(phone);

-- ALTER TABLE email_notifications 
--   ADD COLUMN IF NOT EXISTS customer_phone VARCHAR(20) REFERENCES customer_contacts(phone);

-- ============================================
-- 8. 備份舊表（可選，遷移成功後可刪除）
-- ============================================

-- 重命名舊表作為備份
-- ALTER TABLE line_bindings RENAME TO line_bindings_backup;
-- ALTER TABLE email_bindings RENAME TO email_bindings_backup;

-- 或者直接刪除（確認資料遷移成功後）
-- DROP TABLE line_bindings;
-- DROP TABLE email_bindings;

-- ============================================
-- 9. 實用查詢範例
-- ============================================

-- 查看所有顧客聯絡資訊
-- SELECT * FROM customer_contacts ORDER BY created_at DESC;

-- 查看有 LINE 但沒有 Email 的顧客
-- SELECT phone, name, line_display_name 
-- FROM customer_contacts 
-- WHERE line_user_id IS NOT NULL AND email IS NULL;

-- 查看有 Email 但沒有 LINE 的顧客
-- SELECT phone, name, email 
-- FROM customer_contacts 
-- WHERE email IS NOT NULL AND line_user_id IS NULL;

-- 統計綁定情況
-- SELECT 
--   COUNT(*) as total_customers,
--   COUNT(line_user_id) as has_line,
--   COUNT(email) as has_email,
--   COUNT(CASE WHEN line_user_id IS NOT NULL AND email IS NOT NULL THEN 1 END) as has_both
-- FROM customer_contacts;

COMMENT ON TABLE customer_contacts IS '統一的顧客聯絡資訊表 - 整合 LINE 和 Email 綁定資料';
COMMENT ON COLUMN customer_contacts.phone IS '手機號碼（主鍵，10碼）';
COMMENT ON COLUMN customer_contacts.email IS 'Email 地址';
COMMENT ON COLUMN customer_contacts.line_user_id IS 'LINE 用戶 ID';
COMMENT ON COLUMN customer_contacts.notify_by_line IS '是否接收 LINE 通知';
COMMENT ON COLUMN customer_contacts.notify_by_email IS '是否接收 Email 通知';

