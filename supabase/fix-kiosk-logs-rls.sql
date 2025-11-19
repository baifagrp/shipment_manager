-- 修正 Kiosk 日誌表的 RLS 政策
-- 允許自助寄件 Kiosk 記錄操作日誌

-- 1. 確保 kiosk_logs 表存在並啟用 RLS
ALTER TABLE kiosk_logs ENABLE ROW LEVEL SECURITY;

-- 2. 允許匿名用戶新增日誌記錄
DROP POLICY IF EXISTS "允許 Kiosk 記錄日誌" ON kiosk_logs;
CREATE POLICY "允許 Kiosk 記錄日誌" ON kiosk_logs
  FOR INSERT 
  TO anon
  WITH CHECK (true);

-- 3. 允許已登入用戶查詢和新增日誌
DROP POLICY IF EXISTS "已登入用戶可操作日誌" ON kiosk_logs;
CREATE POLICY "已登入用戶可操作日誌" ON kiosk_logs
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- 完成！

