# App Center — 測試與 Build 操作手冊

## 環境資訊

- Flutter 3.41.6 (Dart 3.11.4)
- 專案目錄：`E:/code/app_center`

---

## 方法一：Build APK 安裝到 Android 手機

### 前置條件

- Android 手機已開啟「開發人員選項」與「USB 偵錯」
- 手機允許「安裝未知來源應用程式」

### Step 1：開啟 Windows 開發人員模式（首次需要）

Flutter 在 Windows 上 build 需要 symlink 支援：

1. 開啟設定：`設定 → 系統 → 開發人員專用`
2. 開啟「開發人員模式」
3. **重新啟動終端機**

### Step 2：Build APK

```bash
# Debug APK（用於測試，檔案較大但可直接安裝）
flutter build apk --debug

# Release APK（較小、效能較好，但需要 signing）
flutter build apk --release
```

輸出路徑：
```
build/app/outputs/flutter-apk/app-debug.apk
build/app/outputs/flutter-apk/app-release.apk
```

### Step 3：傳輸 APK 到手機並安裝

**方法 A：用 USB 傳檔**
1. 將 APK 複製到手機
2. 在手機的檔案管理器中找到 APK 並點擊安裝

**方法 B：ADB 直接安裝（需連接 USB）**
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

---

## 方法二：手機透過 USB 連接電腦即時測試（推薦開發用）

這是最方便的開發方式，程式碼修改後可熱重載，不需要每次重新 build APK。

### Step 1：手機設定

1. `設定 → 關於手機` → 連點「版本號」7 次，開啟開發人員選項
2. `設定 → 開發人員選項` → 開啟「USB 偵錯」
3. 用 USB 連接手機到電腦

### Step 2：確認裝置已被偵測

```bash
flutter devices
```

應該會看到你的手機出現在清單中，例如：
```
Pixel 8 (mobile) • XXXXXXXX • android-arm64 • Android 14
```

若沒出現，執行 `flutter doctor` 診斷問題。

### Step 3：啟動 App

```bash
# 自動選擇已連接的手機
flutter run

# 指定裝置（裝置 ID 從 flutter devices 取得）
flutter run -d <device-id>
```

### 熱重載快捷鍵（App 運行中）

| 按鍵 | 動作 |
|------|------|
| `r` | Hot Reload（UI 變更立即生效） |
| `R` | Hot Restart（完整重啟，狀態清除） |
| `q` | 結束 |

### GPS 路線模擬器專用設定（USB 測試時）

在手機的「開發人員選項」中額外設定：

1. `選取模擬位置應用程式` → 選擇 **App Center**

---

## 方法三：瀏覽器 Web 測試

Web 模式可快速驗證 UI 與路線規劃功能，但 **GPS Mock 功能無法在 Web 上運作**（Android 原生功能）。

### 啟動 Web

```bash
# 使用 Chrome
flutter run -d chrome

# 使用 Edge
flutter run -d edge
```

或直接在瀏覽器開啟後執行 build：

```bash
flutter build web
# 輸出於 build/web/，可用任何靜態伺服器托管
```

### Web 可測試的功能

| 功能 | Web 可用 |
|------|---------|
| 地圖顯示（OpenStreetMap） | ✅ |
| 長按設定起訖點 | ✅ |
| OSRM 路線規劃 | ✅ |
| 路線視覺化 | ✅ |
| 播放/暫停/停止 UI | ✅（按鈕可點，但不會真的 mock GPS） |
| GPS 座標注入至 OS | ❌（Android 限定） |

---

## 方法四：Windows 桌面執行（最快，僅測試 UI）

```bash
flutter run -d windows
```

限制同 Web，GPS Mock 功能不可用。

---

## 常見問題

### `flutter pub get` 或 build 失敗，提示 symlink 錯誤

需開啟 Windows 開發人員模式（見方法一 Step 1）。

### `flutter devices` 看不到手機

1. 確認 USB 偵錯已開啟
2. 手機螢幕上確認「允許 USB 偵錯」對話框
3. 嘗試切換 USB 連接模式為「檔案傳輸（MTP）」
4. 執行 `adb devices` 確認 ADB 是否有偵測到

### GPS Mock 啟動後遊戲沒收到假位置

1. 確認「模擬位置應用程式」已設為 App Center
2. 確認 App 有位置權限（`設定 → 應用程式 → App Center → 權限`）
3. 通知列確認有「GPS 模擬中」常駐通知
