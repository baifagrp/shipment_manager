// 店到店貨物管理系統 - 配置檔案
// 請根據您的 Supabase 專案設定更新以下配置

const CONFIG = {
  // Supabase 配置
  SUPABASE: {
    // 您的 Supabase 專案 URL
    URL: 'https://lhrmgasebwlyrarntoon.supabase.co',
    
    // 您的 Supabase 匿名密鑰
    // 請在 Supabase 專案設定 > API 中找到
    ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxocm1nYXNlYndseXJhcm50b29uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1Mjg3ODQsImV4cCI6MjA3NzEwNDc4NH0.kum-0MizfufOygmPVeb0S_GMJc_H5Y3A0rBWk2xHzLA'
  },

  // 應用程式設定
  APP: {
    // 應用程式名稱
    NAME: '貨物管理系統',
    
    // 版本號
    VERSION: '1.0.0',
    
    // 預設狀態流程
    STATUS_FLOW: ['物流單已建立', '包裹離店作業中', '包裹抵達理貨中心，處理中', '包裹已配達取件門市', '取件成功'],
    
    // 每頁顯示的貨件數量
    ITEMS_PER_PAGE: 20,
    
    // 自動儲存間隔（毫秒）
    AUTO_SAVE_INTERVAL: 30000
  },

  // UI 設定
  UI: {
    // 主題色彩
    THEME: {
      PRIMARY: '#0a84ff',
      SUCCESS: '#28c76f',
      WARNING: '#ff9500',
      DANGER: '#ff3b30',
      MUTED: '#6b7280'
    },
    
    // 動畫設定
    ANIMATION: {
      DURATION: 200,
      EASING: 'ease-out'
    },
    
    // 列印設定
    PRINT: {
      // 列印頁面邊距
      MARGIN: '20mm',
      
      // 字體大小
      FONT_SIZE: '14px',
      
      // 公司資訊
      COMPANY: {
        NAME: 'BaiFa.GRP',
        LOGO: 'B',
        ADDRESS: '高雄市三民區',
        PHONE: '0973-116-277'
      }
    }
  },

  // LINE 官方帳號設定
  LINE: {
    // ✅ 以下設定將從 Supabase app_settings 表動態載入
    // 透過 config-loader.js 的 initLineConfig() 自動更新
    
    // LINE Login Channel ID（將從資料庫載入）
    LOGIN_CHANNEL_ID: '',  // 預設空值，由 config-loader.js 填入
    
    // LIFF App ID（將從資料庫載入）
    LIFF_ID: '',  // 預設空值，由 config-loader.js 填入
    
    // LINE 官方帳號連結（將從資料庫載入）
    OA_URL: 'https://line.me/R/ti/p/@YOUR_LINE_ID',  // 預設值，由 config-loader.js 更新
    
    // LINE Messaging API Channel Access Token
    // ⚠️ 此設定已完全移至 Supabase，只在後端函數中使用
    // 前端不再需要也不應該存取此 Token
    
    // LINE Messaging API 推播設定
    MESSAGING: {
      // 是否啟用自動推播（使用 Supabase RPC，無需 Edge Function）
      AUTO_NOTIFY: true,
      
      // 推播類型開關
      NOTIFY_ON_ARRIVAL: true,  // 包裹到店通知
      NOTIFY_ON_REMINDER: true,  // 取件提醒（未取件）
      NOTIFY_VERIFICATION_CODE: true,  // 驗證碼通知
      
      // 提醒時機（包裹到店後幾小時）
      REMINDER_HOURS: [24, 48, 72],  // 1天、2天、3天
      
      // Flex Message 樣式
      FLEX_MESSAGE_COLOR: '#000000',  // 主題色
      
      // Rich Menu ID（可選）
      RICH_MENU_ID: ''
    },
    
    // LIFF 頁面對應
    LIFF_PAGES: {
      SEARCH: '/pages/customer/shpsearch.html',  // 查詢包裹
      BIND: '/pages/customer/line-bind.html',     // 綁定會員
      CHECKIN: '/pages/customer/checkin.html'    // 自助報到
    }
  },

  // 功能開關
  FEATURES: {
    // 是否啟用即時同步
    REALTIME_SYNC: true,
    
    // 是否啟用通知
    NOTIFICATIONS: true,
    
    // 是否啟用 LINE 官方帳號
    LINE_OA: true,
    
    // 是否啟用資料匯出
    EXPORT: true,
    
    // 是否啟用資料匯入
    IMPORT: true,
    
    // 是否啟用列印功能
    PRINT: true,
    
    // 是否啟用搜尋功能
    SEARCH: true
  },

  // 驗證規則
  VALIDATION: {
    // 必填欄位
    REQUIRED_FIELDS: ['sender_name', 'receiver_name'],
    
    // 電話號碼格式
    PHONE_PATTERN: /^[\d\-\+\(\)\s]+$/,
    
    // 電子郵件格式
    EMAIL_PATTERN: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
    
    // 追蹤單號格式
    TRACKING_PATTERN: /^\d{8}-\d{3}$/
  },

  // 錯誤訊息
  MESSAGES: {
    SUCCESS: {
      LOGIN: '登入成功！',
      LOGOUT: '已成功登出',
      SAVE: '儲存成功！',
      UPDATE: '更新成功！',
      DELETE: '刪除成功！',
      EXPORT: '匯出成功！',
      IMPORT: '匯入成功！'
    },
    ERROR: {
      LOGIN: '登入失敗，請檢查帳號密碼',
      NETWORK: '網路連線錯誤，請稍後再試',
      SAVE: '儲存失敗，請稍後再試',
      DELETE: '刪除失敗，請稍後再試',
      EXPORT: '匯出失敗，請稍後再試',
      IMPORT: '匯入失敗，請檢查檔案格式',
      VALIDATION: '請填寫必填欄位',
      PERMISSION: '權限不足，無法執行此操作'
    }
  }
};

// 匯出配置（如果使用模組系統）
if (typeof module !== 'undefined' && module.exports) {
  module.exports = CONFIG;
}

// 全域變數（供 HTML 使用）
window.CONFIG = CONFIG;
