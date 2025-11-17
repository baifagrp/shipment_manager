// ============================================
// 動態設定載入器
// 用途：從 Supabase 載入 LINE 設定（非敏感部分）
// ============================================

/**
 * 從 Supabase 載入應用程式設定
 * @returns {Promise<Object>} - 設定物件
 */
async function loadLineSettings() {
  try {
    console.log('🔄 正在從 Supabase 載入 LINE 設定...');
    
    // 從資料庫讀取非敏感設定
    const { data, error } = await supabaseClient
      .from('app_settings')
      .select('setting_key, setting_value')
      .in('setting_key', [
        'LINE_LOGIN_CHANNEL_ID',
        'LINE_LIFF_ID'
      ]);
    
    if (error) {
      console.error('❌ 載入設定失敗：', error);
      return null;
    }
    
    // 轉換成物件格式
    const settings = {};
    data.forEach(item => {
      settings[item.setting_key] = item.setting_value;
    });
    
    console.log('✅ LINE 設定載入成功');
    return settings;
    
  } catch (error) {
    console.error('❌ 載入設定時發生錯誤：', error);
    return null;
  }
}

/**
 * 初始化 LINE 設定
 * 覆蓋 config.js 中的設定
 */
async function initLineConfig() {
  try {
    const settings = await loadLineSettings();
    
    if (settings) {
      // 更新全域 CONFIG
      if (settings.LINE_LOGIN_CHANNEL_ID) {
        CONFIG.LINE.LOGIN_CHANNEL_ID = settings.LINE_LOGIN_CHANNEL_ID;
      }
      if (settings.LINE_LIFF_ID) {
        CONFIG.LINE.LIFF_ID = settings.LINE_LIFF_ID;
      }
      
      console.log('✅ LINE 設定已更新');
      console.log('  - LOGIN_CHANNEL_ID:', CONFIG.LINE.LOGIN_CHANNEL_ID);
      console.log('  - LIFF_ID:', CONFIG.LINE.LIFF_ID);
    }
    
  } catch (error) {
    console.error('❌ 初始化 LINE 設定失敗：', error);
  }
}

// 匯出函數
if (typeof window !== 'undefined') {
  window.loadLineSettings = loadLineSettings;
  window.initLineConfig = initLineConfig;
}

