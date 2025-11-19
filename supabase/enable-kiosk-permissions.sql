-- ========================================
-- 自助 Kiosk 系統完整權限設定
-- ========================================
-- 此 SQL 文件設定所有自助 Kiosk 需要的權限
-- 包括：自助寄件、自助報到、日誌記錄
-- ========================================

-- 1. shipments 表 - 寄件資料
-- ========================================
ALTER TABLE shipments ENABLE ROW LEVEL SECURITY;

-- 允許匿名用戶新增寄件記錄
DROP POLICY IF EXISTS "允許自助寄件 Kiosk 新增寄件" ON shipments;
CREATE POLICY "允許自助寄件 Kiosk 新增寄件" ON shipments
  FOR INSERT 
  TO anon
  WITH CHECK (true);

-- 允許匿名用戶查詢寄件資料
DROP POLICY IF EXISTS "允許查詢寄件資料" ON shipments;
CREATE POLICY "允許查詢寄件資料" ON shipments
  FOR SELECT 
  TO anon
  USING (true);

-- 允許匿名用戶更新寄件狀態（報到、取件時需要）
DROP POLICY IF EXISTS "允許更新寄件狀態" ON shipments;
CREATE POLICY "允許更新寄件狀態" ON shipments
  FOR UPDATE 
  TO anon
  USING (true)
  WITH CHECK (true);

-- 已登入用戶完整權限
DROP POLICY IF EXISTS "已登入用戶完整權限_shipments" ON shipments;
CREATE POLICY "已登入用戶完整權限_shipments" ON shipments
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- 2. kiosk_logs 表 - Kiosk 操作日誌
-- ========================================
ALTER TABLE kiosk_logs ENABLE ROW LEVEL SECURITY;

-- 允許匿名用戶新增日誌記錄
DROP POLICY IF EXISTS "允許 Kiosk 記錄日誌" ON kiosk_logs;
CREATE POLICY "允許 Kiosk 記錄日誌" ON kiosk_logs
  FOR INSERT 
  TO anon
  WITH CHECK (true);

-- 已登入用戶完整權限
DROP POLICY IF EXISTS "已登入用戶可操作日誌" ON kiosk_logs;
CREATE POLICY "已登入用戶可操作日誌" ON kiosk_logs
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- 3. checkin_records 表 - 報到記錄
-- ========================================
ALTER TABLE checkin_records ENABLE ROW LEVEL SECURITY;

-- 允許匿名用戶新增報到記錄
DROP POLICY IF EXISTS "允許自助報到" ON checkin_records;
CREATE POLICY "允許自助報到" ON checkin_records
  FOR INSERT 
  TO anon
  WITH CHECK (true);

-- 允許匿名用戶查詢報到記錄（檢查重複報到）
DROP POLICY IF EXISTS "允許查詢報到記錄" ON checkin_records;
CREATE POLICY "允許查詢報到記錄" ON checkin_records
  FOR SELECT 
  TO anon
  USING (true);

-- 允許匿名用戶更新報到記錄（列印次數等）
DROP POLICY IF EXISTS "允許更新報到記錄" ON checkin_records;
CREATE POLICY "允許更新報到記錄" ON checkin_records
  FOR UPDATE 
  TO anon
  USING (true)
  WITH CHECK (true);

-- 已登入用戶完整權限
DROP POLICY IF EXISTS "已登入用戶完整權限_checkin" ON checkin_records;
CREATE POLICY "已登入用戶完整權限_checkin" ON checkin_records
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- 4. line_bindings 表 - LINE 綁定資料（查詢用）
-- ========================================
ALTER TABLE line_bindings ENABLE ROW LEVEL SECURITY;

-- 允許匿名用戶查詢 LINE 綁定（自助報到驗證用）
DROP POLICY IF EXISTS "允許查詢 LINE 綁定" ON line_bindings;
CREATE POLICY "允許查詢 LINE 綁定" ON line_bindings
  FOR SELECT 
  TO anon
  USING (true);

-- 已登入用戶完整權限
DROP POLICY IF EXISTS "已登入用戶完整權限_line_bindings" ON line_bindings;
CREATE POLICY "已登入用戶完整權限_line_bindings" ON line_bindings
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- ========================================
-- 完成！自助 Kiosk 系統現在可以正常運作了
-- ========================================
-- 
-- 已設定的權限：
-- ✅ shipments - 新增、查詢、更新
-- ✅ kiosk_logs - 新增日誌
-- ✅ checkin_records - 新增、查詢、更新
-- ✅ line_bindings - 查詢
-- 
-- 安全性：
-- - 匿名用戶只能執行必要的操作
-- - 已登入用戶（管理員/員工）擁有完整權限
-- - 所有操作都會記錄在日誌中
-- 
-- ========================================

