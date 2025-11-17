# 🔧 LINE 通知格式問題修復

## 🐛 問題描述

**症狀**：有驗證碼的包裹到店通知仍然使用舊的純文字格式，而非 Flex Message 精美卡片格式。

**預期**：所有包裹（無論有無驗證碼）都應使用統一的 Flex Message 格式。

---

## 🔍 問題根源

### 1. **Supabase Select 查詢不完整**

在 `index.html` 的 `advanceStatus` 函數中：

```javascript
// ❌ 問題代碼
const { data, error } = await supabaseClient
  .from('shipments')
  .update({ status: nextStatus })
  .eq('id', shipmentId)
  .select();  // ← 沒有明確指定欄位
```

**問題**：`.select()` 沒有參數時，Supabase 可能不會返回所有欄位，特別是新增的 `verification_code` 和 `require_code` 欄位。

### 2. **資料傳遞不完整**

當 `updatedShipment` 資料傳到 `notifyPackageArrival()` 時：

```javascript
window.LINENotify.notifyArrival(
  updatedShipment.receiver_phone,
  updatedShipment  // ← 可能缺少 verification_code 和 require_code
);
```

### 3. **Flex Message 判斷失敗**

在 `createArrivalFlexMessage()` 中：

```javascript
const hasVerificationCode = shipment.require_code && shipment.verification_code;
```

如果 `shipment.require_code` 或 `shipment.verification_code` 是 `undefined`，則 `hasVerificationCode` 為 `false`，導致驗證碼區塊不顯示。

---

## ✅ 解決方案

### 1. **明確指定 Select 欄位**

在 `index.html` 的 `advanceStatus` 函數中：

```javascript
// ✅ 修復代碼
const { data, error } = await supabaseClient
  .from('shipments')
  .update({ 
    status: nextStatus,
    updated_at: new Date().toISOString()
  })
  .eq('id', shipmentId)
  .select('*, verification_code, require_code');  // ← 明確指定欄位
```

**說明**：
- `*` 選取所有基本欄位
- 明確列出 `verification_code` 和 `require_code` 確保這些欄位被返回

### 2. **添加 Debug 日誌**

在 `index.html` 的發送通知前：

```javascript
// Debug: 檢查貨件資料
console.log('📦 準備發送 LINE 通知，貨件資料：', {
  tracking_no: updatedShipment.tracking_no,
  receiver_phone: updatedShipment.receiver_phone,
  require_code: updatedShipment.require_code,
  verification_code: updatedShipment.verification_code ? '***有驗證碼***' : '無',
  cod_amount: updatedShipment.cod_amount
});
```

在 `line-notify-helper.js` 的 `notifyPackageArrival()` 中：

```javascript
console.log('🔔 notifyPackageArrival 被呼叫', {
  phone,
  tracking_no: shipment.tracking_no,
  require_code: shipment.require_code,
  has_verification_code: !!shipment.verification_code
});
```

在 `createArrivalFlexMessage()` 中：

```javascript
console.log('📝 建立 Flex Message', {
  tracking_no: shipment.tracking_no,
  hasVerificationCode,
  hasCOD,
  require_code: shipment.require_code,
  verification_code_length: shipment.verification_code ? shipment.verification_code.length : 0
});
```

---

## 🧪 測試步驟

### 1. **建立測試包裹**

在 `index.html` 中建立一個代收金額為 0 的包裹：

```
收件人：測試用戶
手機號：0912345678  (需先綁定 LINE)
代收金額：0 元
```

系統應該自動產生 6 位數驗證碼。

### 2. **更新包裹狀態**

1. 打開瀏覽器 Console（F12）
2. 點擊「更新狀態」按鈕，將包裹狀態更新為「包裹已配達取件門市」
3. 觀察 Console 輸出

### 3. **檢查 Console 輸出**

應該看到類似以下的日誌：

```javascript
📦 準備發送 LINE 通知，貨件資料： {
  tracking_no: "20251117-XXXXX",
  receiver_phone: "0912345678",
  require_code: true,           // ← 應該是 true
  verification_code: "***有驗證碼***",  // ← 應該顯示有
  cod_amount: 0
}

🔔 notifyPackageArrival 被呼叫 {
  phone: "0912345678",
  tracking_no: "20251117-XXXXX",
  require_code: true,           // ← 應該是 true
  has_verification_code: true   // ← 應該是 true
}

📝 建立 Flex Message {
  tracking_no: "20251117-XXXXX",
  hasVerificationCode: true,    // ← 應該是 true
  hasCOD: false,
  require_code: true,
  verification_code_length: 6   // ← 應該是 6
}

✅ LINE 通知發送成功
✅ LINE 到店通知已發送
```

### 4. **檢查 LINE 收到的訊息**

在 LINE 中應該看到：

```
┌─────────────────────────────────┐
│  📦 包裹已送達門市                │
│  您有1個包裹已到店，請盡快取件      │
└─────────────────────────────────┘

20251117-XXXXX

收件人        測試用戶
取件門市      NPHONE-KHJG
送達日期      2025/11/17

┌───────────────────────────────┐
│ 🔐 取貨驗證碼                  │  ← 應該顯示驗證碼區塊
│                               │
│         123456                │  ← 實際的驗證碼
│                               │
│ ⚠️ 取件時需出示此驗證碼          │
└───────────────────────────────┘

[查看詳細資訊]
[前往報到]

請盡快取件，逾期可能退回
```

---

## ❓ 故障排除

### 問題 1：Console 顯示 `require_code: undefined`

**原因**：資料庫欄位不存在或 RLS 政策阻擋

**解決**：
```sql
-- 確認欄位是否存在
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'shipments' 
  AND column_name IN ('verification_code', 'require_code');

-- 如果不存在，執行
ALTER TABLE shipments
ADD COLUMN IF NOT EXISTS verification_code TEXT,
ADD COLUMN IF NOT EXISTS require_code BOOLEAN DEFAULT false;
```

### 問題 2：Console 顯示 `hasVerificationCode: false` 但驗證碼存在

**原因**：`require_code` 欄位為 `false` 或 `null`

**解決**：
```sql
-- 檢查包裹的驗證碼設定
SELECT id, tracking_no, verification_code, require_code, cod_amount
FROM shipments
WHERE tracking_no = 'YOUR_TRACKING_NO';

-- 如果需要，手動更新
UPDATE shipments
SET require_code = true
WHERE verification_code IS NOT NULL AND verification_code != '';
```

### 問題 3：LINE 收到純文字而非 Flex Message

**原因**：可能呼叫了舊的 `notifyVerificationCode` 函數

**檢查**：
```javascript
// 在 Console 中搜尋
// 確保沒有直接呼叫 notifyVerificationCode
```

**確認**：
- 只應該呼叫 `window.LINENotify.notifyArrival()`
- `notifyVerificationCode` 只作為備用函數保留

### 問題 4：Supabase RPC 呼叫失敗

**症狀**：Console 顯示 `❌ LINE 推播失敗`

**檢查**：
```sql
-- 確認 send_line_notification 函數存在
SELECT proname, prosrc 
FROM pg_proc 
WHERE proname = 'send_line_notification';

-- 如果不存在，執行 create-app-settings.sql
```

---

## 📝 修改檔案清單

### 1. **`index.html`**
- 修改 `advanceStatus` 函數的 `.select()` 查詢
- 新增 debug 日誌

### 2. **`line-notify-helper.js`**
- 在 `notifyPackageArrival()` 新增 debug 日誌
- 在 `createArrivalFlexMessage()` 新增 debug 日誌

---

## ✅ 驗證清單

- [ ] Console 顯示完整的貨件資料（包含 `verification_code` 和 `require_code`）
- [ ] Console 顯示 `hasVerificationCode: true`（當有驗證碼時）
- [ ] LINE 收到 Flex Message 格式的通知
- [ ] Flex Message 中顯示驗證碼區塊（灰色背景、超大字號）
- [ ] 驗證碼顯示正確（6 位數字）

---

## 🎯 預期結果

### 有驗證碼的包裹

- ✅ 自動產生 6 位數驗證碼
- ✅ `require_code = true`
- ✅ 到店時發送 Flex Message
- ✅ Flex Message 包含驗證碼區塊
- ✅ 驗證碼以超大字號顯示

### 有代收金額的包裹

- ✅ 不產生驗證碼
- ✅ `require_code = false`
- ✅ 到店時發送 Flex Message
- ✅ Flex Message 包含代收金額（紅色粗體）

### 一般包裹

- ✅ 不產生驗證碼
- ✅ `require_code = false`
- ✅ 到店時發送 Flex Message
- ✅ Flex Message 簡潔版（只有基本資訊）

---

## 📚 相關文檔

- **Flex Message 預覽**: `LINE-FLEX-MESSAGE-PREVIEW.md`
- **驗證碼指南**: `VERIFICATION-CODE-GUIDE.md`
- **LINE 設定指南**: `LINE-SETUP-GUIDE.md`
- **Supabase 設定**: `SUPABASE-SETTINGS-GUIDE.md`

---

© 2025 BaiFa.GRP
版本：1.4.1
修復日期：2025/11/17

