/**
 * Email 通知助手
 * 使用 EmailJS 服務發送 Gmail 通知
 * 
 * 功能：
 * - 寄件成功通知
 * - 取件成功通知
 */

// EmailJS 配置
const EMAIL_CONFIG = {
  SERVICE_ID: 'service_57hl9vx',
  TEMPLATE_SHIPMENT_CREATED: 'template_nq9bsuv',  // 寄件成功
  TEMPLATE_PICKUP_SUCCESS: 'template_f2tddhf',     // 取件成功
  PUBLIC_KEY: 'ye3f_U0sSEeABiSqH'
};

// 初始化 EmailJS（在頁面載入時自動執行）
(function() {
  if (typeof emailjs !== 'undefined') {
    emailjs.init(EMAIL_CONFIG.PUBLIC_KEY);
    console.log('✅ EmailJS 已初始化');
  } else {
    console.warn('⚠️ EmailJS 庫未載入，請確認已引入 SDK');
  }
})();

/**
 * 發送寄件成功通知
 * @param {Object} shipmentData - 包裹資料
 * @param {string} toEmail - 收件 Email
 */
async function sendShipmentCreatedEmail(shipmentData, toEmail) {
  if (!toEmail || !validateEmail(toEmail)) {
    console.warn('⚠️ 無效的 Email 地址，跳過發送:', toEmail);
    return { success: false, error: '無效的 Email 地址' };
  }

  try {
    console.log('📧 準備發送寄件成功通知 Email 到:', toEmail);

    // 格式化日期
    const createdAt = shipmentData.created_at 
      ? new Date(shipmentData.created_at).toLocaleString('zh-TW', {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
          hour: '2-digit',
          minute: '2-digit'
        })
      : new Date().toLocaleString('zh-TW', {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
          hour: '2-digit',
          minute: '2-digit'
        });

    // 準備模板參數
    const templateParams = {
      to_email: toEmail,
      tracking_no: shipmentData.tracking_no || 'N/A',
      sender_name: shipmentData.sender_name || 'N/A',
      sender_phone: shipmentData.sender_phone || 'N/A',
      receiver_name: shipmentData.receiver_name || 'N/A',
      receiver_phone: shipmentData.receiver_phone || 'N/A',
      item_name: shipmentData.item_name || '未指定',
      quantity: shipmentData.quantity || 1,
      shipping_fee: shipmentData.shipping_fee || 60,
      created_at: createdAt
    };

    console.log('📤 發送參數:', templateParams);

    // 發送郵件
    const response = await emailjs.send(
      EMAIL_CONFIG.SERVICE_ID,
      EMAIL_CONFIG.TEMPLATE_SHIPMENT_CREATED,
      templateParams
    );

    console.log('✅ 寄件成功通知 Email 已發送:', response);
    
    // 記錄到資料庫（可選）
    await logEmailNotification({
      shipment_id: shipmentData.id,
      email: toEmail,
      type: 'shipment_created',
      status: 'sent',
      tracking_no: shipmentData.tracking_no
    });

    return { success: true, response };

  } catch (error) {
    console.error('❌ 發送寄件成功 Email 失敗:', error);
    
    // 記錄失敗到資料庫
    await logEmailNotification({
      shipment_id: shipmentData.id,
      email: toEmail,
      type: 'shipment_created',
      status: 'failed',
      error: error.text || error.message,
      tracking_no: shipmentData.tracking_no
    });

    return { success: false, error };
  }
}

/**
 * 發送取件成功通知
 * @param {Object} pickupData - 取件資料
 * @param {string} toEmail - 收件 Email
 */
async function sendPickupSuccessEmail(pickupData, toEmail) {
  if (!toEmail || !validateEmail(toEmail)) {
    console.warn('⚠️ 無效的 Email 地址，跳過發送:', toEmail);
    return { success: false, error: '無效的 Email 地址' };
  }

  try {
    console.log('📧 準備發送取件成功通知 Email 到:', toEmail);

    // 格式化日期
    const pickupTime = pickupData.pickup_time 
      ? new Date(pickupData.pickup_time).toLocaleString('zh-TW', {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
          hour: '2-digit',
          minute: '2-digit'
        })
      : new Date().toLocaleString('zh-TW', {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
          hour: '2-digit',
          minute: '2-digit'
        });

    // 準備模板參數
    const templateParams = {
      to_email: toEmail,
      tracking_no: pickupData.tracking_no || 'N/A',
      receiver_name: pickupData.receiver_name || 'N/A',
      sender_name: pickupData.sender_name || 'N/A',
      pickup_time: pickupTime,
      store_name: pickupData.store_name || CONFIG?.STORE?.NAME || 'NPHONE-KHJG',
      transaction_no: pickupData.transaction_no || 'N/A'
    };

    console.log('📤 發送參數:', templateParams);

    // 發送郵件
    const response = await emailjs.send(
      EMAIL_CONFIG.SERVICE_ID,
      EMAIL_CONFIG.TEMPLATE_PICKUP_SUCCESS,
      templateParams
    );

    console.log('✅ 取件成功通知 Email 已發送:', response);
    
    // 記錄到資料庫（可選）
    await logEmailNotification({
      shipment_id: pickupData.shipment_id,
      email: toEmail,
      type: 'pickup_success',
      status: 'sent',
      tracking_no: pickupData.tracking_no
    });

    return { success: true, response };

  } catch (error) {
    console.error('❌ 發送取件成功 Email 失敗:', error);
    
    // 記錄失敗到資料庫
    await logEmailNotification({
      shipment_id: pickupData.shipment_id,
      email: toEmail,
      type: 'pickup_success',
      status: 'failed',
      error: error.text || error.message,
      tracking_no: pickupData.tracking_no
    });

    return { success: false, error };
  }
}

/**
 * 驗證 Email 格式
 * @param {string} email 
 * @returns {boolean}
 */
function validateEmail(email) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(String(email).toLowerCase());
}

/**
 * 記錄 Email 通知到資料庫
 * @param {Object} logData 
 */
async function logEmailNotification(logData) {
  if (typeof supabaseClient === 'undefined') {
    console.warn('⚠️ Supabase 客戶端未定義，跳過記錄');
    return;
  }

  try {
    // 先查詢顧客手機號碼（通過 Email）
    let customerPhone = null;
    if (logData.email) {
      const { data: contact } = await supabaseClient
        .from('customer_contacts')
        .select('phone')
        .eq('email', logData.email)
        .maybeSingle();
      customerPhone = contact?.phone || null;
    }

    const { error } = await supabaseClient
      .from('email_notifications')
      .insert([{
        shipment_id: logData.shipment_id,
        email: logData.email,
        customer_phone: customerPhone,  // 新增：關聯到統一表
        notification_type: logData.type,
        status: logData.status,
        error_message: logData.error || null,
        tracking_no: logData.tracking_no,
        sent_at: new Date().toISOString()
      }]);

    if (error) {
      console.warn('⚠️ 記錄 Email 通知失敗（不影響功能）:', error.message);
    } else {
      console.log('✅ Email 通知已記錄到資料庫');
    }
  } catch (err) {
    console.warn('⚠️ 記錄 Email 通知時發生錯誤（不影響功能）:', err);
  }
}

/**
 * 從 Supabase 查詢用戶 Email
 * @param {string} phone - 電話號碼
 * @returns {string|null} Email 地址
 */
async function getEmailByPhone(phone) {
  if (typeof supabaseClient === 'undefined') {
    console.warn('⚠️ Supabase 客戶端未定義');
    return null;
  }

  try {
    // 從統一的 customer_contacts 表查詢
    const { data, error } = await supabaseClient
      .from('customer_contacts')
      .select('email, notify_by_email')
      .eq('phone', phone)
      .maybeSingle();

    if (error) {
      console.warn('⚠️ 查詢 Email 失敗:', error.message);
      return null;
    }

    if (data && data.email) {
      // 檢查是否啟用 Email 通知
      if (data.notify_by_email === false) {
        console.log('ℹ️ 顧客已關閉 Email 通知');
        return null;
      }
      console.log('✅ 找到綁定的 Email:', data.email);
      return data.email;
    }

    console.log('ℹ️ 未找到綁定的 Email');
    return null;

  } catch (err) {
    console.error('❌ 查詢 Email 時發生錯誤:', err);
    return null;
  }
}

// 匯出函數供其他檔案使用
window.EmailNotify = {
  sendShipmentCreatedEmail,
  sendPickupSuccessEmail,
  getEmailByPhone,
  validateEmail
};

console.log('✅ email-notify-helper.js 載入完成');

