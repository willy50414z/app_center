## Why

開發者和測試人員在測試位置相關功能（如 AR 遊戲、導航 App）時，需要能在真實 Android 裝置上模擬 GPS 移動軌跡，而現有工具通常需要 root 或繁瑣的 ADB 指令。此功能直接整合在 App Center 中，提供圖形化介面讓使用者規劃路線並一鍵啟動 GPS 模擬。

## What Changes

- 新增「GPS 路線模擬器」功能頁面，整合至 App Center 的功能導覽
- 使用 flutter_map（OpenStreetMap）顯示互動地圖，長按設定起點與終點
- 透過 OSRM 公開 API 計算駕車路線，並以線性插值產生平滑座標序列
- Android Foreground Service 持續注入假 GPS 座標至系統 LocationManager
- 支援播放、暫停、停止與速度倍率控制（1x / 2x / 5x）
- 首次使用時顯示引導頁，說明如何開啟開發者選項並設定模擬位置應用程式

## Capabilities

### New Capabilities

- `route-planner`: 地圖顯示、起訖點設定（長按）、OSRM 路線規劃、路線視覺化
- `gps-mock-engine`: Android Foreground Service、LocationManager mock、播放控制、Method/Event Channel 橋接
- `simulator-setup-guide`: 首次使用引導流程，說明開發者選項設定步驟

### Modified Capabilities

## Impact

- **新增 Flutter 套件**：`flutter_map ^7.0.0`、`latlong2 ^0.9.1`、`http ^1.2.0`
- **新增 Android 原生程式碼**：`GpsMockService.kt`（Kotlin Foreground Service）
- **修改 AndroidManifest.xml**：新增位置、前景服務、通知權限及 `foregroundServiceType="location"`
- **修改 `feature_registry.dart`**：在新分類「位置工具」下註冊 GPS 路線模擬器
- **目標平台**：Android 11+（API 30+），不影響 iOS 組建
