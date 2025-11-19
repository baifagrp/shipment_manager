-- ========================================
-- 修正所有日誌表的 RLS 權限
-- ========================================
-- 解決 "new row violates row-level security policy for table 'logs'" 錯誤
-- ========================================

-- 1. logs 表（系統日誌）
-- ========================================
ALTER TABLE IF EXISTS logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "允許匿名用戶新增日誌" ON logs;
CREATE POLICY "允許匿名用戶新增日誌" ON logs
  FOR INSERT 
  TO anon
  WITH CHECK (true);

DROP POLICY IF EXISTS "已登入用戶完整權限_logs" ON logs;
CREATE POLICY "已登入用戶完整權限_logs" ON logs
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- 2. kiosk_logs 表（Kiosk 操作日誌）
-- ========================================
ALTER TABLE IF EXISTS kiosk_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "允許 Kiosk 記錄日誌" ON kiosk_logs;
CREATE POLICY "允許 Kiosk 記錄日誌" ON kiosk_logs
  FOR INSERT 
  TO anon
  WITH CHECK (true);

DROP POLICY IF EXISTS "已登入用戶可操作日誌" ON kiosk_logs;
CREATE POLICY "已登入用戶可操作日誌" ON kiosk_logs
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- 3. pos_logs 表（POS 操作日誌）
-- ========================================
ALTER TABLE IF EXISTS pos_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "允許匿名用戶新增 POS 日誌" ON pos_logs;
CREATE POLICY "允許匿名用戶新增 POS 日誌" ON pos_logs
  FOR INSERT 
  TO anon
  WITH CHECK (true);

DROP POLICY IF EXISTS "已登入用戶完整權限_pos_logs" ON pos_logs;
CREATE POLICY "已登入用戶完整權限_pos_logs" ON pos_logs
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- ========================================
-- 完成！所有日誌表現在都允許匿名用戶新增記錄
-- ========================================

