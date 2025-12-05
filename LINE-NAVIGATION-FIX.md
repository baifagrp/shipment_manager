# 🔧 LINE 跳轉問題修復指南

## 🎯 問題

從首頁選單點擊「通知綁定管理」無法正確跳轉到新的統一綁定頁面。

---

## ✅ 已完成的修復

### 1. **更新 LIFF 頁面配置**

**檔案：`config.js`**

```javascript
LIFF_PAGES: {
  SEARCH: '/pages/customer/shpsearch.html',
  BIND: '/pages/customer/bind.html',       // ✅ 已更新為新頁面
  CHECKIN: '/pages/customer/checkin.html'
}
```

### 2. **改進 navigateTo 函數**

**檔案：`index.html`**

```javascript
function navigateTo(url) {
  // 檢查是否在 LIFF 環境中
  if (typeof liff !== 'undefined' && liff.isInClient()) {
    // 在 LINE 中開啟
    const fullUrl = new URL(url, window.location.origin).href;
    liff.openWindow({
      url: fullUrl,
      external: false
    });
  } else {
    // 在瀏覽器中開啟
    window.location.href = url;
  }
}
```

---

## 🧪 測試步驟

### 測試 1：瀏覽器環境

1. 打開 `http://localhost:8000/index.html`（或您的網址）
2. 登入系統
3. 點擊右上角「選單」
4. 點擊「🔔 通知綁定管理」
5. ✅ 應該能正常跳轉到 `bind.html`

### 測試 2：LINE 環境

1. 在 LINE 中開啟您的 LIFF App
2. 點擊選單中的「通知綁定管理」
3. ✅ 應該在 LINE 內建瀏覽器中開啟新頁面

---

## ⚠️ 常見問題

### Q1: 點擊後沒有任何反應？

**檢查：**

1. **Console 是否有錯誤**
   ```javascript
   // 按 F12 開啟開發者工具查看 Console
   ```

2. **檔案是否存在**
   ```bash
   # 確認檔案存在
   pages/customer/bind.html
   ```

3. **路徑是否正確**
   ```javascript
   // 在 Console 測試
   navigateTo('pages/customer/bind.html');
   ```

### Q2: 顯示 404 Not Found？

**解決方法：**

```bash
# 確認檔案在正確位置
新增資料夾/
├── index.html
└── pages/
    └── customer/
        ├── bind.html          ← 確認這個檔案存在
        ├── line-bind.html
        └── email-bind.html
```

### Q3: 在 LINE 中無法開啟？

**可能原因：**

1. **LIFF ID 未設定**
   - 檢查 `config.js` 中的 `LIFF_ID` 是否正確

2. **LIFF Endpoint URL 未更新**
   - 前往 LINE Developers Console
   - 更新 Endpoint URL

3. **使用外部連結模式**
   ```javascript
   // 如果內部開啟失敗，嘗試外部開啟
   liff.openWindow({
     url: fullUrl,
     external: true  // ← 改為 true
   });
   ```

---

## 🔧 進階除錯

### 方法 1：添加 Debug 訊息

在 `index.html` 的 `navigateTo` 函數中添加 console.log：

```javascript
function navigateTo(url) {
  console.log('🔍 navigateTo called:', url);
  console.log('🔍 LIFF available:', typeof liff !== 'undefined');
  console.log('🔍 In LINE client:', typeof liff !== 'undefined' && liff.isInClient());
  
  if (typeof liff !== 'undefined' && liff.isInClient()) {
    const fullUrl = new URL(url, window.location.origin).href;
    console.log('🔍 Full URL:', fullUrl);
    liff.openWindow({
      url: fullUrl,
      external: false
    });
  } else {
    console.log('🔍 Using window.location.href');
    window.location.href = url;
  }
}
```

### 方法 2：手動測試跳轉

在 Console 中執行：

```javascript
// 測試 1：直接跳轉
window.location.href = 'pages/customer/bind.html';

// 測試 2：使用完整 URL
window.location.href = window.location.origin + '/pages/customer/bind.html';

// 測試 3：使用 LIFF（如果在 LINE 中）
liff.openWindow({
  url: window.location.origin + '/pages/customer/bind.html',
  external: false
});
```

---

## 🚀 替代方案

### 方案 A：直接連結（不使用 JavaScript）

將選單項目改為直接使用 `<a>` 標籤：

```html
<a href="pages/customer/bind.html" class="user-menu-item">
  <span class="user-menu-icon">🔔</span>
  <span>通知綁定管理</span>
</a>
```

### 方案 B：使用 LIFF URL Scheme

如果您有配置 LIFF，可以使用專屬的 LIFF URL：

```javascript
// 在 LINE Developers Console 取得 LIFF URL
const liffUrl = 'https://liff.line.me/YOUR-LIFF-ID/pages/customer/bind.html';
liff.openWindow({ url: liffUrl });
```

---

## 📋 檢查清單

完成以下檢查以確保功能正常：

- [ ] ✅ `config.js` 中的 `LIFF_PAGES.BIND` 已更新為 `bind.html`
- [ ] ✅ `index.html` 中的 `navigateTo` 函數已更新
- [ ] ✅ 檔案 `pages/customer/bind.html` 存在
- [ ] ✅ 在瀏覽器中測試跳轉正常
- [ ] ✅ 在 LINE 中測試跳轉正常
- [ ] ✅ Console 沒有錯誤訊息

---

## 💡 快速測試

### 測試代碼（貼到 Console）

```javascript
// 完整測試流程
(async function test() {
  console.log('=== 開始測試 ===');
  
  // 1. 檢查檔案是否存在
  try {
    const response = await fetch('pages/customer/bind.html');
    console.log('✅ bind.html 存在:', response.ok);
  } catch (e) {
    console.error('❌ bind.html 不存在或無法訪問');
  }
  
  // 2. 檢查 LIFF
  console.log('LIFF 可用:', typeof liff !== 'undefined');
  if (typeof liff !== 'undefined') {
    console.log('在 LINE 中:', liff.isInClient());
  }
  
  // 3. 測試跳轉
  console.log('準備跳轉到: pages/customer/bind.html');
  setTimeout(() => {
    navigateTo('pages/customer/bind.html');
  }, 2000);
  
  console.log('=== 2 秒後將跳轉 ===');
})();
```

---

## 📞 如果問題仍然存在

請提供以下資訊：

1. **瀏覽器 Console 的錯誤訊息**
2. **是在瀏覽器還是 LINE 中測試**
3. **執行測試代碼後的輸出**
4. **網址列顯示的完整 URL**

這樣我可以提供更精準的解決方案！🔧

