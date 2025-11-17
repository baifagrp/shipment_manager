-- ============================================
-- 建立 Database Trigger 觸發 Edge Function
-- 用途：當貨件狀態更新為「待取件」時自動呼叫 Edge Function
-- ============================================

-- 1. 建立 Webhook（需要在 Supabase Dashboard 手動設定）
-- 或者使用 Database Trigger + HTTP Request

-- 方案 A：使用 Supabase Webhooks（推薦，最簡單）
-- ============================================
-- 1. 登入 Supabase Dashboard
-- 2. 進入 Database > Webhooks
-- 3. 點擊「Create a new hook」
-- 4. 設定：
--    - Table: shipments
--    - Events: UPDATE
--    - Type: Supabase Edge Function
--    - Function: line-notify-arrival
--    - HTTP request filters: 
--      record.status=eq.待取件
--      record.line_notified=eq.false
-- ============================================

-- 方案 B：使用 Database Trigger + pg_net（進階）
-- ============================================

-- 啟用 pg_net 擴充功能（需要 Supabase Pro 方案）
-- CREATE EXTENSION IF NOT EXISTS pg_net;

-- 建立觸發函數
CREATE OR REPLACE FUNCTION notify_line_on_arrival()
RETURNS TRIGGER AS $$
DECLARE
  function_url TEXT;
BEGIN
  -- 只在狀態變更為「待取件」且尚未通知時觸發
  IF NEW.status = '待取件' AND 
     (OLD.status IS NULL OR OLD.status != '待取件') AND
     (NEW.line_notified IS NULL OR NEW.line_notified = false) THEN
    
    -- 取得 Edge Function URL（請替換為您的專案 URL）
    function_url := 'https://lhrmgasebwlyrarntoon.supabase.co/functions/v1/line-notify-arrival';
    
    -- 使用 pg_net 發送 HTTP 請求
    -- 注意：此功能需要 Supabase Pro 方案
    /*
    PERFORM net.http_post(
      url := function_url,
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
      ),
      body := jsonb_build_object(
        'record', to_jsonb(NEW)
      )
    );
    */
    
    -- 暫時使用日誌記錄（等待實際執行時替換）
    RAISE NOTICE '📦 觸發 LINE 通知：% - %', NEW.tracking_no, NEW.receiver_phone;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 建立觸發器
DROP TRIGGER IF NOT EXISTS trigger_line_notify_on_arrival ON shipments;

CREATE TRIGGER trigger_line_notify_on_arrival
  AFTER UPDATE ON shipments
  FOR EACH ROW
  EXECUTE FUNCTION notify_line_on_arrival();

-- ============================================
-- 說明
-- ============================================
-- 🎯 推薦方案：使用 Supabase Webhooks（方案 A）
-- 原因：
-- 1. 不需要額外設定
-- 2. 免費方案也可使用
-- 3. 設定簡單，透過 Dashboard 操作
-- 4. 可以直接測試

-- 🔧 進階方案：使用 pg_net（方案 B）
-- 原因：
-- 1. 需要 Pro 方案
-- 2. 更多控制權
-- 3. 可以在 SQL 中完整設定

-- ============================================
-- 測試
-- ============================================
-- 手動更新一筆貨件狀態為「待取件」來測試：

-- UPDATE shipments
-- SET status = '待取件', line_notified = false
-- WHERE id = 1;

-- 檢查通知記錄：
-- SELECT * FROM line_notifications ORDER BY send_time DESC LIMIT 5;

-- 檢查貨件是否標記為已通知：
-- SELECT id, tracking_no, status, line_notified, line_notified_time 
-- FROM shipments 
-- WHERE status = '待取件' 
-- ORDER BY updated_at DESC 
-- LIMIT 10;

