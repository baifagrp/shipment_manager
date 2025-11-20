-- ========================================
-- 修正 POS 系統權限與函數
-- ========================================
-- 解決 sales.html 結帳時的 406、400 錯誤
-- ========================================

-- 1. 確保 pickup_transactions 表存在並設定 RLS
-- ========================================
CREATE TABLE IF NOT EXISTS pickup_transactions (
  id BIGSERIAL PRIMARY KEY,
  transaction_no TEXT UNIQUE NOT NULL,
  shipment_id BIGINT REFERENCES shipments(id),
  tracking_no TEXT NOT NULL,
  receiver_name TEXT NOT NULL,
  receiver_phone TEXT NOT NULL,
  receiver_id_name TEXT,
  amount DECIMAL(10,2) DEFAULT 0,
  payment_method TEXT DEFAULT 'cash',
  is_cod BOOLEAN DEFAULT false,
  cashier_id UUID REFERENCES auth.users(id),
  cashier_name TEXT,
  store_code TEXT,
  status TEXT DEFAULT 'completed',
  print_count INTEGER DEFAULT 0,
  last_print_time TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 啟用 RLS
ALTER TABLE pickup_transactions ENABLE ROW LEVEL SECURITY;

-- 允許匿名用戶查詢（檢查重複取件）
DROP POLICY IF EXISTS "允許查詢取件記錄" ON pickup_transactions;
CREATE POLICY "允許查詢取件記錄" ON pickup_transactions
  FOR SELECT 
  TO anon, authenticated
  USING (true);

-- 允許匿名用戶新增取件記錄（自助系統）
DROP POLICY IF EXISTS "允許新增取件記錄" ON pickup_transactions;
CREATE POLICY "允許新增取件記錄" ON pickup_transactions
  FOR INSERT 
  TO anon, authenticated
  WITH CHECK (true);

-- 允許匿名用戶更新取件記錄（列印次數等）
DROP POLICY IF EXISTS "允許更新取件記錄" ON pickup_transactions;
CREATE POLICY "允許更新取件記錄" ON pickup_transactions
  FOR UPDATE 
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- 已登入用戶完整權限
DROP POLICY IF EXISTS "已登入用戶完整權限_transactions" ON pickup_transactions;
CREATE POLICY "已登入用戶完整權限_transactions" ON pickup_transactions
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- 2. 創建交易序列（如果不存在）
-- ========================================
CREATE SEQUENCE IF NOT EXISTS pickup_transaction_seq START 1;


-- 3. 創建生成交易單號的函數
-- ========================================
DROP FUNCTION IF EXISTS generate_transaction_no();
CREATE OR REPLACE FUNCTION generate_transaction_no()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  seq_num TEXT;
  transaction_no TEXT;
BEGIN
  -- 獲取序列號並格式化為 6 位數
  seq_num := LPAD(nextval('pickup_transaction_seq')::TEXT, 6, '0');
  
  -- 生成交易單號：TX-YYYYMMDD-XXXXXX
  transaction_no := 'TX-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || seq_num;
  
  RETURN transaction_no;
END;
$$;

-- 允許匿名用戶和已登入用戶執行此函數
GRANT EXECUTE ON FUNCTION generate_transaction_no() TO anon, authenticated;


-- 4. pos_logs 表權限（如果存在）
-- ========================================
ALTER TABLE IF EXISTS pos_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "允許匿名用戶新增 POS 日誌" ON pos_logs;
CREATE POLICY "允許匿名用戶新增 POS 日誌" ON pos_logs
  FOR INSERT 
  TO anon, authenticated
  WITH CHECK (true);

DROP POLICY IF EXISTS "已登入用戶完整權限_pos_logs" ON pos_logs;
CREATE POLICY "已登入用戶完整權限_pos_logs" ON pos_logs
  FOR ALL 
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- 5. 更新 shipments 表權限（允許更新狀態）
-- ========================================
DROP POLICY IF EXISTS "允許更新寄件狀態_pos" ON shipments;
CREATE POLICY "允許更新寄件狀態_pos" ON shipments
  FOR UPDATE 
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);


-- ========================================
-- 完成！POS 系統現在可以正常結帳了
-- ========================================
-- 
-- 已設定的功能：
-- ✅ pickup_transactions 表完整權限
-- ✅ generate_transaction_no() 函數
-- ✅ pos_logs 表權限
-- ✅ shipments 表更新權限
-- 
-- ========================================


