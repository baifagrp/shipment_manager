# 📦 店到店貨物管理系統

> 一個功能完整的現代化店到店貨物管理系統，整合自助報到、櫃檯叫號、POS 結帳、公播顯示、顧客查詢等完整解決方案。

**版本：** 1.3.0  
**最後更新：** 2025/10/27

---

## 📑 目錄

- [系統概述](#系統概述)
- [核心功能](#核心功能)
- [技術架構](#技術架構)
- [快速開始](#快速開始)
- [功能模組詳解](#功能模組詳解)
- [資料庫結構](#資料庫結構)
- [使用指南](#使用指南)
- [故障排除](#故障排除)
- [最佳實踐](#最佳實踐)
- [常見問題](#常見問題)

---

## 系統概述

### 🎯 設計理念

本系統專為店到店貨物管理業務設計，提供從貨物登記、追蹤、報到、叫號、取件到結帳的完整流程管理。採用簡潔的 HTML/CSS/JavaScript 架構，搭配 Supabase 後端，無需複雜部署，即可快速上線使用。

### 🌟 核心特色

- ✅ **零複雜度架構** - 純 HTML/CSS/JS，無需 React、Vue 等框架
- ✅ **即時同步** - Supabase Realtime 實現多端即時更新
- ✅ **完整流程** - 涵蓋報到、叫號、取件、結帳全流程
- ✅ **語音播報** - 自動語音叫號，提升顧客體驗
- ✅ **公播顯示** - 大螢幕叫號顯示，清晰易見
- ✅ **行動友善** - 響應式設計，支援各種裝置
- ✅ **蘋果風格** - 優雅的 UI 設計，符合現代審美

---

## 核心功能

### 📋 1. 貨件管理系統 (`index.html`)

**功能：**
- 貨件登記（寄件人、收件人、貨物資訊）
- 自動生成追蹤單號（SHP-YYYYMMDD-XXXX）
- 狀態管理（物流單已建立 → 包裹離店作業中 → 包裹抵達理貨中心 → 包裹已配達取件門市 → 取件成功）
- 歷史記錄追蹤
- 列印 88mm × 140mm 寄件單（含 QR Code 和條碼）
- 代收金額管理
- 搜尋功能（單號、姓名、電話）

**特色：**
- FamilyMart 風格寄件單設計
- QR Code 快速掃描
- CODE128 條碼支援
- 完整的狀態流轉

### 🏷️ 2. 自助報到 Kiosk (`pages/checkin.html`)

**功能：**
- 顧客輸入手機號碼查詢包裹
- 身份確認（姓名前兩字 + 電話末三碼）
- 自動生成報到號碼（001-999）
- 列印 58mm 報到單
- 代收金額提醒

**特色：**
- 大字體觸控友善介面
- 三步驟簡易流程
- 防重複報到機制
- 每日自動重置號碼

**流程：**
```
輸入手機號碼 → 確認身份 → 生成報到號 → 列印報到單
```

### 🔔 3. 櫃檯叫號管理 (`pages/counter.html`)

**功能：**
- 即時顯示待叫號列表
- 一鍵叫號通知顧客
- 等待時間顯示
- 狀態分頁（待叫號/已叫號/今日完成）
- 統計儀表板

**特色：**
- 卡片式列表設計
- 10 秒自動刷新
- Supabase Realtime 即時同步
- 直接跳轉至 POS 結帳

**流程：**
```
查看待叫號 → 點擊叫號 → 準備包裹 → 前往結帳
```

### 🖥️ 4. 公播顯示畫面 (`pages/display.html`)

**功能：**
- 超大字號顯示當前叫號（160px）
- 下一號預告顯示
- 自動語音播報（播放兩次）
- 多螢幕同步顯示
- 底部訊息輪播
- 全螢幕模式

**特色：**
- 現代漸層背景設計
- 動態脈衝動畫效果
- 待機歡迎畫面
- 連線狀態即時顯示
- 可調節音量控制

**語音設定：**
- 語言：zh-TW（繁體中文）
- 語速：0.85（稍慢）
- 音量：80%（可調）
- 重複：2 次

### 🔍 5. 顧客包裹查詢 (`shpsearch.html`)

**功能：**
- 輸入包裹編號即時查詢
- 顯示包裹當前狀態
- 查看完整配送歷史
- 代收金額顯示
- 結果分享功能（Web Share API）
- URL 參數直連查詢

**特色：**
- 行動裝置優先設計
- 無需登入即可查詢
- 漂亮的漸層背景
- 時間軸式歷史記錄
- 狀態圖標與顏色區分
- 複製/分享查詢結果

**適用場景：**
- 顧客自行查詢包裹狀態
- 客服快速查詢回覆
- 分享追蹤連結給收件人
- 嵌入官網或 LINE 客服

**流程：**
```
輸入包裹編號 → 查詢資料庫 → 顯示狀態與歷史 → 分享結果
```

### 🛒 6. POS 取件結帳 (`pages/sales.html`)

**功能：**
- 掃描/輸入取件單號
- 手機末三碼查詢（支援多筆選擇）
- 顯示貨件詳細資訊
- 代收金額計算
- 更新貨件狀態為「取件成功」
- 列印 58mm 取件收據
- 交易記錄上傳

**特色：**
- 條碼掃描器支援
- 雙查詢模式切換
- 防重複取件機制
- 完整交易日誌

**流程：**
```
掃描單號/輸入末三碼 → 確認貨件 → 收取代收款 → 列印收據
```

### 👤 7. 帳號設定管理

**功能：**
- 修改個人資料（姓名）
- 修改密碼（需驗證目前密碼）
- 角色顯示（管理員/員工/一般用戶）
- 安全驗證機制

**特色：**
- 對話框式介面
- 即時錯誤提示
- 自動重新載入用戶資訊

---

## 技術架構

### 🎨 前端技術

| 技術 | 用途 | 版本 |
|------|------|------|
| HTML5 | 結構 | - |
| CSS3 | 樣式（漸層、動畫、響應式） | - |
| JavaScript (ES6+) | 邏輯 | - |
| Supabase JS SDK | 後端連接 | v2 |
| QRCode.js | QR Code 生成 | - |
| JsBarcode | 條碼生成 | - |
| Web Speech API | 語音播報 | - |

### 🔧 後端服務

| 服務 | 用途 |
|------|------|
| Supabase Auth | 用戶認證與授權 |
| Supabase Database | PostgreSQL 資料庫 |
| Supabase Realtime | 即時資料同步 |
| Row Level Security (RLS) | 資料安全控制 |

### 📊 系統架構圖

```
┌─────────────────────────────────────────────────┐
│                   用戶端                         │
├─────────────────────────────────────────────────┤
│  index.html        │  主系統（貨件管理）         │
│  shpsearch.html    │  顧客包裹查詢              │
│  checkin.html      │  自助報到 Kiosk            │
│  counter.html      │  櫃檯叫號管理              │
│  display.html      │  公播顯示畫面              │
│  sales.html        │  POS 取件結帳              │
└────────────┬────────────────────────────────────┘
             │
             ↓ Supabase JS SDK
             │
┌────────────┴────────────────────────────────────┐
│              Supabase 後端                       │
├─────────────────────────────────────────────────┤
│  • Authentication  （用戶認證）                  │
│  • PostgreSQL      （資料庫）                    │
│  • Realtime        （即時同步）                  │
│  • Storage         （檔案儲存，可選）            │
└─────────────────────────────────────────────────┘
```

---

## 快速開始

### 📋 前置需求

- 現代網頁瀏覽器（Chrome 90+、Edge 90+、Safari 14+）
- [Supabase](https://supabase.com) 帳號
- 基本的 HTML/JavaScript 知識（用於自訂）

### 🚀 5 步驟快速部署

#### 步驟 1：創建 Supabase 專案

```bash
1. 前往 https://supabase.com
2. 註冊/登入帳號
3. 點擊「New Project」
4. 填寫專案名稱、資料庫密碼
5. 選擇地區（建議：Singapore）
6. 點擊「Create new project」
```

#### 步驟 2：獲取 API 金鑰

```bash
1. 專案建立完成後，前往「Settings」
2. 點擊「API」
3. 複製以下資訊：
   - Project URL (例如: https://xxx.supabase.co)
   - anon public key (公開金鑰)
```

#### 步驟 3：設定 config.js

創建或更新 `config.js` 文件：

```javascript
const CONFIG = {
  SUPABASE: {
    URL: 'https://你的專案ID.supabase.co',
    ANON_KEY: '你的anon-key'
  },
  UI: {
    PRINT: {
      COMPANY: {
        NAME: '您的店名',
        ADDRESS: '您的地址',
        PHONE: '02-xxxx-xxxx',
        LOGO: '' // 可選：base64 圖片
      }
    }
  },
  STATUS_FLOW: [
    '物流單已建立',
    '包裹離店作業中',
    '包裹抵達理貨中心，處理中',
    '包裹已配達取件門市',
    '取件成功'
  ]
};
```

#### 步驟 4：執行資料庫 SQL

**依序在 Supabase SQL Editor 執行以下 SQL 檔案：**

1. **基礎表結構** - 創建 users、shipments、notifications、logs 表
2. **`create-pos-tables.sql`** - POS 系統表（pickup_transactions、stores、pos_logs）
3. **`create-checkin-tables.sql`** - 報到系統表（checkin_records、checkin_sequence、call_history、kiosk_logs）
4. **`add-cod-amount-field.sql`** - 添加代收金額欄位
5. **`fix-all-missing-columns.sql`** - 修復缺失欄位和外鍵約束

**或使用整合腳本：**

```sql
-- 在 Supabase Dashboard → SQL Editor 執行
-- 執行 fix-all-missing-columns.sql 會自動修復所有問題
```

#### 步驟 5：開啟系統

```bash
方式 A：本地開啟
1. 直接在瀏覽器開啟 index.html
2. 完成登入/註冊
3. 開始使用

方式 B：部署至雲端
1. 上傳所有檔案至靜態託管服務
   - GitHub Pages
   - Netlify
   - Vercel
   - Cloudflare Pages
2. 訪問部署的網址
3. 完成登入/註冊
```

### ✅ 驗證安裝

**檢查清單：**
- [ ] 可以正常登入系統
- [ ] 可以創建貨件
- [ ] 可以列印寄件單
- [ ] 可以在 Kiosk 完成報到
- [ ] 可以在櫃檯叫號
- [ ] 公播畫面正常顯示和語音播報
- [ ] 可以在 POS 完成取件結帳

---

## 功能模組詳解

### 📦 模組 1：貨件管理 (index.html)

#### 介面概覽

```
┌────────────────────────────────────────────────┐
│  📦 貨物管理系統    [選單] [登出]             │
├────────────────────────────────────────────────┤
│  [新增貨件] [🛒取件結帳] [匯入資料]           │
├──────────────┬─────────────────────────────────┤
│              │                                 │
│  貨件列表    │        貨件詳情                │
│              │                                 │
│  001 王小明  │   追蹤單號：SHP-xxx            │
│  ○ 待取件   │   寄件人：xxx                  │
│  [查看]      │   收件人：xxx                  │
│              │   代收：$567                   │
│  002 李大華  │   [下一步] [列印] [刪除]       │
│  ○ 運送中   │                                 │
│              │                                 │
└──────────────┴─────────────────────────────────┘
```

#### 功能列表

**1. 新增貨件**
- 填寫寄件人資料（姓名、電話、地址）
- 填寫收件人資料（姓名、電話、地址）
- 填寫貨物資訊（品名、數量、重量、備註）
- 設定代收金額
- 自動生成追蹤單號

**2. 狀態管理**
- 五階段狀態流程
- 一鍵「下一步」推進
- 完整歷史記錄
- 狀態顏色視覺化

**3. 列印功能**
- 88mm × 140mm 寄件單
- QR Code（90×90px）
- CODE128 條碼
- FamilyMart 風格設計

**4. 搜尋與篩選**
- 即時搜尋
- 支援單號、姓名、電話
- 狀態篩選

#### 鍵盤快捷鍵

| 按鍵 | 功能 |
|------|------|
| `Ctrl + N` | 新增貨件 |
| `Ctrl + S` | 儲存貨件 |
| `Ctrl + P` | 列印寄件單 |
| `Ctrl + F` | 聚焦搜尋框 |
| `ESC` | 關閉彈窗 |

---

### 🏷️ 模組 2：自助報到 Kiosk (pages/checkin.html)

#### 介面概覽

```
┌────────────────────────────────────────────────┐
│            🏷️ 自助報到                        │
│        請輸入手機號碼查詢包裹                  │
├────────────────────────────────────────────────┤
│                                                │
│             0912345678                         │
│                                                │
│        [1] [2] [3]                            │
│        [4] [5] [6]                            │
│        [7] [8] [9]                            │
│        [清除] [0] [←]                         │
│                                                │
│        [取消]     [查詢]                      │
│                                                │
└────────────────────────────────────────────────┘
```

#### 使用流程

**步驟 1：輸入手機號碼**
```
• 使用螢幕數字鍵盤
• 或使用實體鍵盤輸入
• 必須輸入完整 10 碼
```

**步驟 2：確認身份**
```
顯示資訊：
• 收件人：王**（前兩字）
• 電話末三碼：678
• 取件單號：SHP-xxx
• 代收金額：$567

⚠️ 如有代收，顯示提醒訊息
```

**步驟 3：完成報到**
```
• 自動生成報到號：001
• 列印 58mm 報到單
• 顯示報到時間
• 提供「重新列印」選項
```

#### 報到單格式 (58mm)

```
      ★ 報到單 ★
--------------------------------
       店名 LOGO
--------------------------------

報到號碼：
        001

--------------------------------
取件單號： SHP-20251027-8893
報到時間： 14:35
--------------------------------

      代收金額
        $567

  請先備妥您的現金
--------------------------------
   請稍待叫號
   準備包裹中...
--------------------------------
   服務專線：02-xxxx-xxxx
```

#### 安全機制

- 🔒 姓名遮蔽顯示（王**）
- 🔒 只顯示電話末三碼
- 🔒 防重複報到（同一單號當天只能報到一次）
- 🔒 每日自動重置號碼

---

### 🔔 模組 3：櫃檯叫號管理 (pages/counter.html)

#### 介面概覽

```
┌────────────────────────────────────────────────┐
│  🔔 櫃檯叫號管理  [待叫號:3][已叫號:1][已完成:5]│
│                   [🔄刷新][💰結帳][←返回]     │
├────────────────────────────────────────────────┤
│  [待叫號] [已叫號] [今日完成]                  │
├────────────────────────────────────────────────┤
│                                                │
│  ┌──────────┐  ┌──────────┐                  │
│  │001 [待叫號]│ │002 [待叫號]│                  │
│  │等待:5分鐘 │  │等待:2分鐘 │                  │
│  │王** 678  │  │李** 234  │                  │
│  │代收:$567 │  │代收:$120 │                  │
│  │[🔔叫號]  │  │[🔔叫號]  │                  │
│  └──────────┘  └──────────┘                  │
│                                                │
└────────────────────────────────────────────────┘
```

#### 功能列表

**1. 待叫號管理**
- 卡片式列表顯示
- 等待時間計算
- 代收金額提醒
- 一鍵叫號

**2. 已叫號管理**
- 顯示已叫號列表
- 直接跳轉 POS 結帳
- 包裹準備狀態

**3. 今日完成**
- 查看已完成取件
- 統計資料
- 歷史記錄

**4. 統計儀表板**
- 待叫號數量
- 已叫號數量
- 已完成數量
- 即時更新

#### 叫號流程

```
查看列表 → 點擊「🔔 叫號」
    ↓
更新狀態為「已叫號」
    ↓
記錄叫號時間與人員
    ↓
Realtime 通知 display.html
    ↓
display.html 更新畫面 + 播放語音
    ↓
顧客看到/聽到通知
    ↓
點擊「💰 前往結帳」→ 開啟 POS 系統
```

#### 即時同步

- ⚡ Supabase Realtime 訂閱
- ⚡ 10 秒自動刷新（備用）
- ⚡ 多個櫃檯完全同步

---

### 🖥️ 模組 4：公播顯示畫面 (pages/display.html)

#### 介面概覽（全螢幕）

```
┌────────────────────────────────────────────────┐
│  店名 LOGO                          ● 已連線  │
├────────────────────────────────────────────────┤
│                                                │
│                                                │
│            🔔 現在叫號                         │
│                                                │
│              001                               │ ← 160px
│                                                │
│         請 001 號至櫃檯取件                    │
│                                                │
│         ────────────────                       │
│          下一號                                │
│            002                                 │
│                                                │
│                                                │
├────────────────────────────────────────────────┤
│  💰 取件請攜帶現金                            │
└────────────────────────────────────────────────┘
  🔊 音量 ━━●━━━━━━ 80%    🖥️ 全螢幕
```

#### 功能特色

**1. 超大字號顯示**
- 當前號碼：160px
- 指示文字：42px
- 下一號：72px
- 脈衝動畫效果

**2. 自動語音播報**
- 櫃檯叫號後自動觸發
- 播放內容：「請 001 號，至櫃檯取件。請 001 號，至櫃檯取件。」
- 播放兩次確保聽到
- 可調節音量（0-100%）

**3. 即時同步**
- Supabase Realtime 訂閱
- < 1 秒延遲
- 多螢幕完全同步

**4. 待機畫面**
```
        📦
     歡迎光臨
   目前暫無叫號
```

**5. 底部訊息輪播**
- 每 5 秒自動切換
- 可自訂訊息內容
- 平滑過渡動畫

#### 語音設定

| 參數 | 值 | 說明 |
|------|-----|------|
| 語言 | zh-TW | 繁體中文 |
| 語速 | 0.85 | 稍慢，確保清晰 |
| 音調 | 1.0 | 標準 |
| 音量 | 0.8 (80%) | 可調 |
| 重複 | 2 次 | 確保聽到 |

#### 鍵盤快捷鍵

| 按鍵 | 功能 |
|------|------|
| `F11` 或 `F` | 切換全螢幕 |
| `ESC` | 退出全螢幕 |
| `R` | 手動重新載入 |

#### 連線狀態

- 🟢 **已連線** - 正常運作
- 🟡 **連線中...** - 正在連線
- 🔴 **連線中斷** - 需檢查網路

#### 硬體建議

**顯示設備：**
- 📺 32吋以上電視或螢幕
- 🖥️ 1920×1080 解析度（Full HD）
- 🔊 內建喇叭或外接音響

**電腦設備：**
- 💻 迷你電腦或舊筆電
- 🌐 有線網路（推薦）
- 🔌 不斷電系統（UPS）

**擺放位置：**
- 候位區正前方
- 高度 1.5-2 米
- 避免陽光直射
- 所有顧客可見

---

### 🛒 模組 5：POS 取件結帳 (pages/sales.html)

#### 介面概覽

```
┌────────────────────────────────────────────────┐
│  💰 取件結帳系統                    [返回首頁] │
├────────────────────────────────────────────────┤
│  查詢方式：                                    │
│  ⦿ 取件單號  ○ 手機末三碼                     │
│                                                │
│  請掃描或輸入取件單號...                       │
│  [______________________] [查詢] [重置]       │
│                                                │
│  💡 提示：可直接使用條碼掃描器                 │
├────────────────────────────────────────────────┤
│  📦 貨件資訊                                   │
│  ┌────────────────────────────────────────┐   │
│  │ 取件單號：SHP-20251027-8893            │   │
│  │ 收件人：王小明                         │   │
│  │ 電話：0912-345-678                     │   │
│  │ 品名：一般貨物                         │   │
│  │ 代收金額：$567                         │   │
│  │                                        │   │
│  │ [取消]              [確認取件結帳]     │   │
│  └────────────────────────────────────────┘   │
└────────────────────────────────────────────────┘
```

#### 功能列表

**1. 雙查詢模式**
- **取件單號查詢**：掃描或輸入完整單號
- **手機末三碼查詢**：輸入後三碼，顯示多筆選擇

**2. 貨件確認**
- 顯示完整貨件資訊
- 代收金額醒目顯示
- 防重複取件檢查

**3. 結帳處理**
- 自動計算代收金額
- 更新狀態為「取件成功」
- 記錄交易資訊
- 上傳至 Supabase

**4. 收據列印**
- 58mm 熱感紙格式
- 包含交易單號
- 代收金額明細
- 結帳時間與人員

#### 手機末三碼查詢

**使用情境：**
```
顧客：「我忘記單號了」
店員：「請問您的電話末三碼？」
顧客：「678」
店員：輸入 678 → 顯示多筆選擇列表
```

**選擇介面：**
```
┌────────────────────────────────────┐
│  查詢到多筆貨件，請選擇            │
├────────────────────────────────────┤
│  ┌──────────────────────────────┐ │
│  │ SHP-001  [包裹已配達取件門市]│ │
│  │ 王小明  0912-345-678         │ │
│  │ 一般貨物  代收:$567          │ │
│  └──────────────────────────────┘ │
│  ┌──────────────────────────────┐ │
│  │ SHP-002  [包裹已配達取件門市]│ │
│  │ 王大華  0923-456-789         │ │
│  │ 文件  代收:$0                │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

#### 收據格式 (58mm)

```
      ★ 取件收據 ★
--------------------------------
       店名 LOGO
--------------------------------
交易單號：TX202510270001
取件單號：SHP-20251027-8893
結帳人員：王小明
交易時間：2025/10/27 14:35
--------------------------------
品項：
取件 - SHP-20251027-8893  $567
--------------------------------
合計金額：$567
--------------------------------
感謝您的取件，歡迎再度光臨！
--------------------------------
```

#### 防重複機制

```javascript
// 檢查是否已有取件記錄
if (existingTransaction) {
  showMessage('此貨件已完成取件，無法重複結帳', 'error');
  return;
}
```

---

## 資料庫結構

### 📊 完整資料表

#### 1. users - 用戶表

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 2. shipments - 貨件表

```sql
CREATE TABLE shipments (
  id BIGSERIAL PRIMARY KEY,
  tracking_no TEXT UNIQUE NOT NULL,
  sender_name TEXT NOT NULL,
  sender_phone TEXT,
  sender_address TEXT,
  receiver_name TEXT NOT NULL,
  receiver_phone TEXT,
  receiver_address TEXT,
  item_name TEXT,
  quantity INTEGER DEFAULT 1,
  weight DECIMAL(10,2),
  note TEXT,
  status TEXT DEFAULT '物流單已建立',
  cod_amount DECIMAL(10,2) DEFAULT 0,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 3. checkin_records - 報到記錄表

```sql
CREATE TABLE checkin_records (
  id BIGSERIAL PRIMARY KEY,
  checkin_no VARCHAR(20) UNIQUE NOT NULL,
  shipment_id BIGINT REFERENCES shipments(id) ON DELETE CASCADE,
  tracking_no VARCHAR(100) NOT NULL,
  receiver_name VARCHAR(100),
  receiver_phone VARCHAR(50),
  cod_amount DECIMAL(10,2) DEFAULT 0,
  status VARCHAR(50) DEFAULT '待叫號',
  store_code VARCHAR(50),
  checkin_time TIMESTAMPTZ DEFAULT NOW(),
  called_time TIMESTAMPTZ,
  completed_time TIMESTAMPTZ,
  print_count INT DEFAULT 0,
  last_print_time TIMESTAMPTZ
);
```

#### 4. pickup_transactions - 取件交易表

```sql
CREATE TABLE pickup_transactions (
  id BIGSERIAL PRIMARY KEY,
  transaction_no VARCHAR(50) UNIQUE NOT NULL,
  tracking_no VARCHAR(100) NOT NULL,
  pickup_amount DECIMAL(10,2) DEFAULT 0,
  pickup_by UUID REFERENCES auth.users(id),
  pickup_time TIMESTAMPTZ DEFAULT NOW(),
  status VARCHAR(50) DEFAULT 'completed',
  store_code VARCHAR(50)
);
```

#### 5. call_history - 叫號歷史表

```sql
CREATE TABLE call_history (
  id BIGSERIAL PRIMARY KEY,
  checkin_id BIGINT REFERENCES checkin_records(id) ON DELETE CASCADE,
  checkin_no VARCHAR(20) NOT NULL,
  caller_id UUID REFERENCES auth.users(id),
  caller_name VARCHAR(100),
  call_time TIMESTAMPTZ DEFAULT NOW(),
  store_code VARCHAR(50)
);
```

#### 6. logs - 操作日誌表

```sql
CREATE TABLE logs (
  id BIGSERIAL PRIMARY KEY,
  shipment_id BIGINT REFERENCES shipments(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  old_status TEXT,
  new_status TEXT,
  note TEXT,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 🔗 關聯關係圖

```
auth.users (Supabase Auth)
    │
    ├─→ users (用戶資料)
    │
    ├─→ shipments (貨件)
    │       │
    │       ├─→ checkin_records (報到記錄)
    │       │       │
    │       │       └─→ call_history (叫號歷史)
    │       │
    │       └─→ logs (操作日誌)
    │
    └─→ pickup_transactions (取件交易)
```

### 🔐 RLS 政策

所有表都啟用 Row Level Security (RLS)：

```sql
-- 只有登入用戶可以讀寫
CREATE POLICY "Authenticated users can access"
  ON table_name FOR ALL
  TO authenticated
  USING (true);
```

---

## 使用指南

### 📘 完整業務流程

#### 情境：顧客寄送包裹

**第 1 天：建立貨件**
```
09:00 - 店員在主系統建立貨件
      • 輸入寄件人、收件人資料
      • 設定代收金額：$567
      • 生成單號：SHP-20251027-8893
      • 列印寄件單，貼於包裹
      
10:00 - 更新狀態：「包裹離店作業中」
```

**第 2 天：包裹到達理貨中心**
```
14:00 - 理貨中心掃描包裹
      • 更新狀態：「包裹抵達理貨中心，處理中」
```

**第 3 天：包裹到達取件門市**
```
08:00 - 取件門市收到包裹
      • 更新狀態：「包裹已配達取件門市」
      
（等待顧客來取件...）
```

**第 3 天下午：顧客取件**
```
14:00 - 顧客到店，走向 Kiosk
      • 輸入手機號碼：0912345678
      • 確認身份：王** / 678
      • ⚠️ 系統提示：代收金額 $567，請備妥現金
      • 點擊「確認報到」
      • 獲得報到號：001
      • 列印報到單
      
14:05 - 櫃檯人員看到報到列表
      • 001 號 - 王** / 末三碼 678 / 代收 $567
      • 點擊「🔔 叫號」
      
14:05 - 公播畫面更新 + 語音播報
      • 顯示：現在叫號 001
      • 播放：「請 001 號，至櫃檯取件」（× 2）
      
14:06 - 顧客聽到叫號，前往櫃檯
      • 店員：「請問是 001 號嗎？」
      • 顧客：「是的」
      • 店員點擊「💰 前往結帳」
      
14:07 - POS 系統自動開啟
      • 單號：SHP-20251027-8893
      • 代收：$567
      • 店員：「請支付 567 元」
      • 顧客支付現金
      • 店員點擊「確認取件結帳」
      
14:08 - 系統自動處理
      • 更新狀態：「取件成功」
      • 生成交易單號：TX202510270001
      • 記錄交易：567 元
      • 列印收據
      
14:08 - 交易完成
      • 店員：「這是您的收據，謝謝光臨」
      • 顧客離開

✅ 完整流程結束
```

### 🎯 常見操作

#### 操作 1：修改貨件資料

```
1. 在主系統搜尋單號
2. 點擊「查看」
3. 點擊「編輯」（如有）
4. 修改資料
5. 點擊「儲存」
```

#### 操作 2：重新列印寄件單

```
1. 搜尋單號
2. 點擊「查看」
3. 點擊「列印」
4. 選擇印表機
5. 列印
```

#### 操作 3：查詢歷史記錄

```
1. 開啟貨件詳情
2. 滾動至「處理歷史」區塊
3. 查看所有狀態變更記錄
```

#### 操作 4：刪除貨件

```
⚠️ 注意：刪除貨件會同時刪除所有相關記錄

1. 開啟貨件詳情
2. 點擊「刪除」
3. 確認對話框會顯示：
   「此操作將同時刪除相關的報到記錄和取件記錄」
4. 點擊「確定」
5. 系統依序刪除：
   • call_history（叫號歷史）
   • checkin_records（報到記錄）
   • pickup_transactions（取件交易）
   • logs（日誌記錄）
   • shipments（貨件本身）
```

---

## 故障排除

### ❌ 常見問題與解決方案

#### 問題 1：無法登入

**現象：**
```
點擊登入後沒有反應或顯示錯誤
```

**可能原因：**
- Supabase 設定錯誤
- 網路連線問題
- RLS 政策未正確設定

**解決方式：**
```
1. 檢查 config.js 中的 URL 和 ANON_KEY
2. 在瀏覽器控制台檢查錯誤訊息
3. 確認 Supabase 專案狀態正常
4. 檢查 RLS 政策是否啟用
```

#### 問題 2：刪除貨件失敗（HTTP 409）

**現象：**
```
ERROR: 409 (Conflict)
刪除貨件失敗：Key is still referenced from table "xxx"
```

**解決方式：**
```
執行修復 SQL：fix-all-missing-columns.sql

此腳本會：
1. 添加缺失的 shipment_id 欄位
2. 設定外鍵 CASCADE 刪除
3. 創建必要的索引
```

**參考文檔：**
- `FIX-DELETE-ERROR-GUIDE.md`
- `QUICK-FIX-GUIDE.md`

#### 問題 3：公播畫面沒有語音

**現象：**
```
公播畫面顯示正常，但沒有語音播報
```

**可能原因：**
- 瀏覽器不支援 Speech API
- 音量設定為 0
- 系統音量關閉

**解決方式：**
```
1. 使用 Chrome 瀏覽器（推薦）
2. 調整左下角音量滑桿至 80%
3. 檢查系統音量設定
4. 在控制台測試：
   window.speechSynthesis.speak(
     new SpeechSynthesisUtterance('測試')
   );
```

#### 問題 4：畫面不同步

**現象：**
```
櫃檯叫號後，公播畫面沒有更新
```

**可能原因：**
- Realtime 連線中斷
- 網路不穩定

**解決方式：**
```
1. 檢查右上角連線狀態
2. 按 R 鍵手動重新載入
3. 重新整理頁面（F5）
4. 檢查網路連線
5. 確認 Supabase Realtime 已啟用
```

#### 問題 5：列印格式錯誤

**現象：**
```
列印的寄件單格式不正確或分頁錯誤
```

**解決方式：**
```
1. 確認 @page 設定：
   @page { size: 88mm 140mm; margin: 0; }

2. 使用 Chrome 列印
3. 列印設定：
   • 紙張大小：自訂（88mm × 140mm）
   • 邊界：無
   • 縮放：100%
```

#### 問題 6：Kiosk 重複報到

**現象：**
```
同一個單號可以重複報到
```

**解決方式：**
```
確認資料庫觸發器已建立：

CREATE TRIGGER check_duplicate_checkin
  BEFORE INSERT ON checkin_records
  FOR EACH ROW
  EXECUTE FUNCTION prevent_duplicate_checkin();

執行：create-checkin-tables.sql
```

---

## 最佳實踐

### 💡 營運建議

#### 每日開店流程

```
08:30 - 開啟所有設備
      • 主系統電腦
      • Kiosk 平板
      • 公播顯示螢幕

08:35 - 啟動系統
      • 開啟主系統（index.html）
      • 開啟 Kiosk（checkin.html）
      • 開啟公播畫面（display.html）
      • 開啟櫃檯叫號（counter.html）

08:40 - 檢查狀態
      • 所有畫面顯示「已連線」
      • 測試語音播報
      • 測試列印功能

09:00 - 開始營業
```

#### 每日關店流程

```
18:00 - 確認所有顧客已取件
18:10 - 匯出今日資料（可選）
18:15 - 關閉所有瀏覽器分頁
18:20 - 關閉設備
```

#### 定期維護

**每週：**
- 清理螢幕和設備
- 檢查列印機紙張和碳粉
- 測試所有功能

**每月：**
- 檢查資料庫空間使用
- 清理 30 天前的舊記錄
- 更新瀏覽器版本

**每季：**
- 備份完整資料庫
- 檢查系統效能
- 更新系統版本

### 🔐 安全建議

**1. 資料庫安全**
```
• 定期備份 Supabase 資料庫
• 啟用 RLS 政策
• 定期更換資料庫密碼
• 限制 API 金鑰權限
```

**2. 用戶管理**
```
• 使用強密碼
• 定期更換密碼
• 限制管理員數量
• 記錄所有操作日誌
```

**3. 網路安全**
```
• 使用 HTTPS 連線
• 避免使用公共 Wi-Fi
• 設定防火牆規則
• 定期檢查連線狀態
```

### 📊 效能優化

**1. 資料庫優化**
```sql
-- 定期清理舊記錄
DELETE FROM logs WHERE created_at < NOW() - INTERVAL '30 days';
DELETE FROM checkin_records WHERE checkin_time < NOW() - INTERVAL '30 days';
DELETE FROM call_history WHERE call_time < NOW() - INTERVAL '30 days';

-- 重建索引
REINDEX TABLE shipments;
REINDEX TABLE checkin_records;
```

**2. 前端優化**
```javascript
// 使用節流避免過度查詢
const throttle = (func, delay) => {
  let timeout;
  return (...args) => {
    if (!timeout) {
      timeout = setTimeout(() => {
        func(...args);
        timeout = null;
      }, delay);
    }
  };
};
```

**3. 網路優化**
```
• 使用有線網路（公播畫面）
• 啟用瀏覽器緩存
• 壓縮圖片資源
• 減少不必要的 API 呼叫
```

---

## 常見問題

### ❓ FAQ

**Q1：系統支援哪些瀏覽器？**

A：
- ✅ Chrome 90+（推薦）
- ✅ Edge 90+
- ✅ Safari 14+
- ⚠️ Firefox（語音支援有限）

---

**Q2：可以離線使用嗎？**

A：部分功能可以，但需要網路連線：
- ❌ 登入/認證（需要網路）
- ❌ 資料同步（需要網路）
- ❌ Realtime 更新（需要網路）
- ✅ 查看已載入的資料（離線可）
- ✅ 列印已載入的寄件單（離線可）

---

**Q3：可以修改狀態流程嗎？**

A：可以！在 `config.js` 修改：
```javascript
STATUS_FLOW: [
  '物流單已建立',
  '包裹離店作業中',
  '包裹抵達理貨中心，處理中',
  '包裹已配達取件門市',
  '取件成功'
]
```

修改後需要同步更新資料庫 CHECK 約束。

---

**Q4：可以同時開啟多個公播畫面嗎？**

A：可以！系統支援多螢幕同步：
- 所有畫面完全同步
- 每個畫面都會播放語音
- 延遲 < 1 秒

---

**Q5：如何更換店家 LOGO？**

A：在 `config.js` 修改：
```javascript
UI: {
  PRINT: {
    COMPANY: {
      NAME: '您的店名',
      LOGO: 'data:image/png;base64,...'  // Base64 圖片
    }
  }
}
```

---

**Q6：報到號碼會重複嗎？**

A：不會。系統每日自動重置，每天從 001 開始。

---

**Q7：可以修改報到號碼格式嗎？**

A：可以！修改 `create-checkin-tables.sql` 中的 `generate_checkin_no()` 函數：
```sql
-- 改為四位數：0001, 0002
new_no := LPAD(current_seq::TEXT, 4, '0');

-- 改為加前綴：A001, A002
new_no := 'A' || LPAD(current_seq::TEXT, 3, '0');
```

---

**Q8：如何備份資料？**

A：在 Supabase Dashboard：
```
1. 前往 Database → Backups
2. 點擊「Create Backup」
3. 或設定自動備份排程
```

---

**Q9：可以匯出資料嗎？**

A：可以，在 SQL Editor 執行：
```sql
-- 匯出貨件資料（CSV 格式）
COPY (
  SELECT * FROM shipments 
  WHERE created_at >= '2025-10-01'
) TO STDOUT WITH CSV HEADER;
```

---

**Q10：系統可以處理多少筆資料？**

A：理論上無限，但建議：
- < 10,000 筆：無需優化
- 10,000 - 50,000 筆：添加分頁
- \> 50,000 筆：考慮歸檔舊資料

---

## 📚 相關文檔

### 完整指南列表

| 文檔 | 說明 | 頁數 |
|------|------|------|
| **README.md** | 主要文檔（當前文件） | - |
| **SETUP-GUIDE.md** | 初始設定指南 | 139 行 |
| **DEPLOYMENT.md** | 部署指南 | 259 行 |
| **CHECKIN-KIOSK-GUIDE.md** | 自助報到完整指南 | 詳細 |
| **DISPLAY-SYSTEM-GUIDE.md** | 公播顯示系統指南 | 詳細 |
| **POS-SETUP-GUIDE.md** | POS 系統設定 | 342 行 |
| **COD-AMOUNT-GUIDE.md** | 代收金額功能 | 348 行 |
| **ACCOUNT-SETTINGS-GUIDE.md** | 帳號設定指南 | 詳細 |
| **DELETE-SHIPMENT-FIX.md** | 刪除功能修復 | 394 行 |
| **FIX-DELETE-ERROR-GUIDE.md** | 錯誤修復指南 | 詳細 |
| **QUICK-FIX-GUIDE.md** | 快速修復指南 | 簡明 |

### SQL 腳本列表

| 腳本 | 用途 |
|------|------|
| `create-pos-tables.sql` | 創建 POS 系統表 |
| `create-checkin-tables.sql` | 創建報到系統表 |
| `add-cod-amount-field.sql` | 添加代收金額欄位 |
| `fix-cod-amount-view.sql` | 修復代收金額視圖 |
| `fix-all-missing-columns.sql` | **修復所有缺失欄位（推薦）** |
| `fix-checkin-records-shipment-id.sql` | 修復 shipment_id 欄位 |
| `fix-foreign-key-cascade.sql` | 設定外鍵 CASCADE |

---

## 🚀 未來規劃

### 計劃中的功能

**v1.3.0** ✅ 已完成
- [x] 顧客包裹查詢頁面（shpsearch.html）
- [x] Web Share API 分享功能
- [x] 時間軸式歷史記錄
- [x] 行動裝置優先設計

**v1.4.0**
- [ ] 行動 App 版本（React Native）
- [ ] 多店管理功能
- [ ] 數據分析儀表板
- [ ] 客戶評價系統

**v1.5.0**
- [ ] 微信/LINE 通知整合
- [ ] 自動簡訊通知
- [ ] 電子簽收功能
- [ ] 多語言支援（英/日/韓）

**v2.0.0**
- [ ] AI 智能路線規劃
- [ ] 物流預測分析
- [ ] 區塊鏈追蹤
- [ ] 智能客服機器人

---

## 📞 技術支援

### 聯絡方式

- **問題回報：** 透過 GitHub Issues
- **功能建議：** 透過 GitHub Discussions
- **緊急支援：** service@example.com

### 開發者

**AI 進化論-花生**
- 角色：系統架構師 & 全端開發
- 專長：Supabase、JavaScript、UI/UX 設計

---

## 📄 授權與版權

### MIT License

```
Copyright (c) 2025 BaiFa.GRP

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🎉 致謝

感謝以下開源項目：
- [Supabase](https://supabase.com) - 強大的後端服務
- [QRCode.js](https://davidshimjs.github.io/qrcodejs/) - QR Code 生成
- [JsBarcode](https://github.com/lindell/JsBarcode) - 條碼生成
- Web Speech API - 語音播報

---

## 📊 項目統計

**程式碼統計：**
- 總行數：~11,000 行
- HTML 文件：7 個（新增顧客查詢頁面）
- JavaScript：~6,000 行
- CSS：~2,000 行
- SQL 腳本：10+ 個

**功能模組：**
- 核心模組：6 個
- 資料表：10+ 個
- API 端點：Supabase 自動生成

**文檔：**
- 指南文檔：12+ 個
- 總字數：~50,000 字
- 範例代碼：100+ 段

---

**🎯 開始使用：** 請參考 [快速開始](#快速開始) 章節

**📖 詳細文檔：** 請參考 [相關文檔](#相關文檔) 章節

**❓ 遇到問題：** 請參考 [故障排除](#故障排除) 或 [常見問題](#常見問題)

---

**最後更新：** 2025/10/27  
**版本：** 1.2.0  
**狀態：** ✅ 生產就緒

© 2025 BaiFa.GRP - Made with ❤️ by AI進化論-花生
#   s h i p m e n t _ m a n a g e r 
 
 