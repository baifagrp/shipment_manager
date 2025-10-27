-- ============================================
-- 檢查 logs 表的實際結構
-- ============================================

-- 1. 查看 logs 表的所有欄位
SELECT 
  column_name AS "欄位名稱",
  data_type AS "資料型別",
  is_nullable AS "可為空",
  column_default AS "預設值"
FROM information_schema.columns
WHERE table_name = 'logs'
ORDER BY ordinal_position;

-- 2. 查看 logs 表的前幾筆資料
SELECT * FROM logs LIMIT 5;

-- 3. 查看 logs 表的外鍵約束
SELECT
  tc.constraint_name AS "約束名稱",
  tc.table_name AS "表名",
  kcu.column_name AS "欄位名稱",
  ccu.table_name AS "參照表",
  ccu.column_name AS "參照欄位"
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name = 'logs';

-- ============================================
-- 執行此腳本以了解 logs 表的結構
-- ============================================

