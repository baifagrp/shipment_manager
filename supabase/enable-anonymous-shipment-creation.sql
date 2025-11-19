-- 允許匿名用戶（自助寄件 Kiosk）新增寄件資料
-- 此政策用於自助寄件 Kiosk 系統

-- 1. 啟用 shipments 表的 RLS（如果尚未啟用）
ALTER TABLE shipments ENABLE ROW LEVEL SECURITY;

-- 2. 允許匿名用戶新增寄件記錄（INSERT）
CREATE POLICY "允許自助寄件 Kiosk 新增寄件" ON shipments
  FOR INSERT 
  TO anon
  WITH CHECK (true);

-- 3. 允許匿名用戶查詢自己建立的寄件（SELECT）
-- 注意：這個政策允許所有人查詢，如果需要更嚴格的權限控制，請調整
CREATE POLICY "允許查詢寄件資料" ON shipments
  FOR SELECT 
  TO anon
  USING (true);

-- 4. 確認已登入用戶可以執行所有操作（如果需要）
CREATE POLICY "已登入用戶完整權限" ON shipments
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- 完成！現在自助寄件 Kiosk 可以正常新增寄件資料了

