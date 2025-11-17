-- =====================================================
-- 📦 取件交易表與交易單號生成函數
-- =====================================================
-- 功能：建立取件交易表與自動生成唯一的取件交易單號
-- 格式：TXN-YYYYMMDD-NNNN
-- 範例：TXN-20251117-0001
-- =====================================================

-- =====================================================
-- 1️⃣ 建立取件交易表（如果不存在）
-- =====================================================
CREATE TABLE IF NOT EXISTS pickup_transactions (
  id BIGSERIAL PRIMARY KEY,
  transaction_no VARCHAR(50) UNIQUE NOT NULL,
  shipment_id BIGINT,
  tracking_no VARCHAR(100) NOT NULL,
  receiver_name VARCHAR(100),
  receiver_phone VARCHAR(20),
  receiver_id_name VARCHAR(100),
  amount DECIMAL(10,2) DEFAULT 0,
  payment_method VARCHAR(20) DEFAULT 'cash',
  is_cod BOOLEAN DEFAULT false,
  cashier_id UUID REFERENCES auth.users(id),
  cashier_name VARCHAR(100),
  store_code VARCHAR(50),
  status VARCHAR(50) DEFAULT 'completed',
  print_count INTEGER DEFAULT 0,
  last_print_time TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 建立索引
CREATE INDEX IF NOT EXISTS idx_pickup_transactions_tracking_no 
  ON pickup_transactions(tracking_no);
CREATE INDEX IF NOT EXISTS idx_pickup_transactions_receiver_phone 
  ON pickup_transactions(receiver_phone);
CREATE INDEX IF NOT EXISTS idx_pickup_transactions_created_at 
  ON pickup_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_pickup_transactions_store_code 
  ON pickup_transactions(store_code);

-- 啟用 RLS
ALTER TABLE pickup_transactions ENABLE ROW LEVEL SECURITY;

-- 建立 RLS 政策：允許已認證用戶完整存取
DROP POLICY IF EXISTS "Authenticated users can access pickup_transactions" ON pickup_transactions;
CREATE POLICY "Authenticated users can access pickup_transactions"
  ON pickup_transactions FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- 建立更新時間觸發器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_pickup_transactions_updated_at ON pickup_transactions;
CREATE TRIGGER update_pickup_transactions_updated_at
  BEFORE UPDATE ON pickup_transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 添加註解
COMMENT ON TABLE pickup_transactions IS '取件交易記錄表';
COMMENT ON COLUMN pickup_transactions.transaction_no IS '交易單號（格式：TXN-YYYYMMDD-NNNN）';
COMMENT ON COLUMN pickup_transactions.amount IS '代收金額';
COMMENT ON COLUMN pickup_transactions.is_cod IS '是否為代收貨款';
COMMENT ON COLUMN pickup_transactions.print_count IS '列印收據次數';

-- =====================================================
-- 2️⃣ 建立取件交易單號序列
-- =====================================================
CREATE SEQUENCE IF NOT EXISTS pickup_transaction_seq;

-- 建立生成交易單號的函數
CREATE OR REPLACE FUNCTION generate_transaction_no()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  today_date TEXT;
  seq_num INTEGER;
  transaction_no TEXT;
  exists_check BOOLEAN;
BEGIN
  -- 取得今天的日期（格式：YYYYMMDD）
  today_date := TO_CHAR(CURRENT_DATE, 'YYYYMMDD');
  
  -- 嘗試生成唯一的交易單號（最多嘗試 100 次）
  FOR i IN 1..100 LOOP
    -- 取得序列的下一個值
    seq_num := nextval('pickup_transaction_seq');
    
    -- 組合交易單號：TXN-日期-流水號
    transaction_no := 'TXN-' || today_date || '-' || LPAD(seq_num::TEXT, 4, '0');
    
    -- 檢查是否已存在
    SELECT EXISTS(
      SELECT 1 FROM pickup_transactions 
      WHERE transaction_no = transaction_no
    ) INTO exists_check;
    
    -- 如果不存在，返回這個單號
    IF NOT exists_check THEN
      RETURN transaction_no;
    END IF;
  END LOOP;
  
  -- 如果 100 次都失敗，使用時間戳確保唯一性
  transaction_no := 'TXN-' || today_date || '-' || 
                    EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT;
  
  RETURN transaction_no;
END;
$$;

-- =====================================================
-- 🎯 使用範例
-- =====================================================
-- SELECT generate_transaction_no();
-- 
-- 輸出範例：
-- TXN-20251117-0001
-- TXN-20251117-0002
-- TXN-20251117-0003
-- =====================================================

-- =====================================================
-- 🔐 權限設定
-- =====================================================
-- 允許已認證的使用者呼叫此函數
GRANT EXECUTE ON FUNCTION generate_transaction_no() TO authenticated;

-- =====================================================
-- 📝 說明
-- =====================================================
-- 此函數會：
-- 1. 取得當前日期（YYYYMMDD 格式）
-- 2. 從序列取得下一個流水號
-- 3. 組合成 TXN-YYYYMMDD-NNNN 格式
-- 4. 檢查是否已存在，若存在則重試
-- 5. 最多重試 100 次
-- 6. 若仍失敗，使用時間戳確保唯一性
-- 
-- 注意：
-- - 序列不會每日自動重置
-- - 但透過日期作為前綴，可確保唯一性
-- - 建議定期清理舊序列（可選）
-- =====================================================

COMMENT ON FUNCTION generate_transaction_no() IS '生成唯一的取件交易單號（格式：TXN-YYYYMMDD-NNNN）';

