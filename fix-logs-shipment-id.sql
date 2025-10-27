-- ============================================
-- 修復 logs 表缺少 shipment_id 欄位問題
-- ============================================

-- 1. 檢查並新增 shipment_id 欄位到 logs 表
DO $$ 
BEGIN
  -- 檢查欄位是否存在
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'logs' AND column_name = 'shipment_id'
  ) THEN
    -- 新增欄位（使用 BIGINT 以匹配 shipments.id）
    ALTER TABLE logs ADD COLUMN shipment_id BIGINT;
    RAISE NOTICE '✅ logs.shipment_id 欄位已新增（BIGINT 型別）';
  ELSE
    RAISE NOTICE 'ℹ️ logs.shipment_id 欄位已存在，跳過';
  END IF;
END $$;

-- 2. 檢查 logs 表是否有其他關聯欄位
-- logs 表通常透過其他方式關聯 shipments，我們先跳過自動更新
-- 如果需要，可以手動根據實際情況更新
DO $$ 
BEGIN
  RAISE NOTICE 'ℹ️ 現有 logs 記錄的 shipment_id 可能為空';
  RAISE NOTICE 'ℹ️ 如需填入，請根據 logs 表的實際欄位手動執行更新';
  RAISE NOTICE 'ℹ️ 例如：UPDATE logs SET shipment_id = ... WHERE ...';
END $$;

-- 3. 刪除舊的外鍵約束（如果存在）
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'logs_shipment_id_fkey'
  ) THEN
    ALTER TABLE logs DROP CONSTRAINT logs_shipment_id_fkey;
    RAISE NOTICE '✅ 已刪除舊的 logs_shipment_id_fkey 約束';
  END IF;
END $$;

-- 4. 新增外鍵約束（帶 CASCADE 刪除）
ALTER TABLE logs
ADD CONSTRAINT logs_shipment_id_fkey
FOREIGN KEY (shipment_id)
REFERENCES shipments(id)
ON DELETE CASCADE;

-- 5. 建立索引以提升查詢效能
CREATE INDEX IF NOT EXISTS idx_logs_shipment_id 
ON logs(shipment_id);

-- 6. 驗證結果
DO $$ 
DECLARE
  col_count INTEGER;
  fk_count INTEGER;
BEGIN
  -- 檢查欄位
  SELECT COUNT(*) INTO col_count
  FROM information_schema.columns 
  WHERE table_name = 'logs' AND column_name = 'shipment_id';
  
  -- 檢查外鍵
  SELECT COUNT(*) INTO fk_count
  FROM information_schema.table_constraints 
  WHERE constraint_name = 'logs_shipment_id_fkey';
  
  IF col_count > 0 AND fk_count > 0 THEN
    RAISE NOTICE '✅ logs 表修復完成！';
    RAISE NOTICE '   - shipment_id 欄位: 存在';
    RAISE NOTICE '   - 外鍵約束: 已設定 (ON DELETE CASCADE)';
  ELSE
    RAISE WARNING '⚠️ 可能有問題：col_count=%, fk_count=%', col_count, fk_count;
  END IF;
END $$;

-- ============================================
-- 完成！請執行此腳本來修復 logs 表問題
-- ============================================

