## 1. 專案設定與依賴

- [x] 1.1 在 `pubspec.yaml` 新增 `flutter_map ^7.0.0`、`latlong2 ^0.9.1`、`http ^1.2.0` 並執行 `flutter pub get`
- [x] 1.2 在 `android/app/src/main/AndroidManifest.xml` 新增 `ACCESS_FINE_LOCATION`、`FOREGROUND_SERVICE`、`POST_NOTIFICATIONS` 權限及 `<service foregroundServiceType="location">` 宣告
- [x] 1.3 建立功能目錄結構 `lib/features/gps_simulator/`（含 models、services、widgets 子目錄）

## 2. 資料模型

- [x] 2.1 建立 `lib/features/gps_simulator/models/route_point.dart`（含 `LatLng lat/lng`、`double distanceFromStart`）
- [x] 2.2 建立 `lib/features/gps_simulator/models/simulation_state.dart`（`enum SimulationStatus { idle, routing, ready, playing, paused }`）

## 3. 路線規劃服務

- [x] 3.1 建立 `lib/features/gps_simulator/services/osrm_service.dart`，實作 `fetchRoute(LatLng origin, LatLng destination) → Future<List<LatLng>>`，呼叫 OSRM API 並解析 GeoJSON geometry
- [x] 3.2 建立 `lib/features/gps_simulator/services/route_interpolator.dart`，實作 `interpolate(List<LatLng> sparse, {double maxSegmentMeters = 15}) → List<LatLng>`，使相鄰點間距 ≤ 15m
- [x] 3.3 在 `OsrmService` 中加入 OSRM 失敗時的錯誤處理，拋出具描述性訊息的例外

## 4. Android 原生 GPS Mock Service

- [x] 4.1 建立 `android/app/src/main/kotlin/.../GpsMockService.kt`，繼承 `Service`，實作 `addTestProvider` 與 `setTestProviderLocation` 邏輯
- [x] 4.2 在 `GpsMockService` 中實作 Foreground Service 啟動，建立含「GPS 模擬中」文字的常駐通知
- [x] 4.3 實作 timer 邏輯：依 `intervalMs` 參數逐點呼叫 `setTestProviderLocation()`，播放完成後停止
- [x] 4.4 捕獲 `SecurityException` 並透過 EventChannel 回傳 `{type: "error"}` 事件
- [x] 4.5 實作暫停（保留索引）、繼續（從索引重啟 timer）、停止（移除 test provider、停止 Service）邏輯

## 5. Platform Channel 橋接

- [x] 5.1 在 `MainActivity.kt` 中註冊 `MethodChannel("gps_mock/control")` 與 `EventChannel("gps_mock/progress")`，將指令路由至 `GpsMockService`
- [x] 5.2 建立 `lib/features/gps_simulator/services/gps_mock_channel.dart`，封裝 `MethodChannel` 呼叫（start/pause/resume/stop）與 `EventChannel` 訂閱，提供 Dart 友善介面

## 6. 地圖 UI 元件

- [x] 6.1 建立 `lib/features/gps_simulator/widgets/simulator_map.dart`：使用 `flutter_map` 顯示 OSM 底圖、起點綠色標記、終點紅色標記、路線藍色折線、目前模擬位置藍色移動標記
- [x] 6.2 在 `SimulatorMap` 中實作長按處理：第一次 → 設起點；第二次 → 設終點並觸發路線計算；之後 → 顯示 BottomSheet 選擇「設為新起點／終點」；播放中忽略
- [x] 6.3 建立 `lib/features/gps_simulator/widgets/route_status_bar.dart`：顯示距離（km）、預估時間、載入中指示器

## 7. 播放控制 UI 元件

- [x] 7.1 建立 `lib/features/gps_simulator/widgets/playback_controls.dart`：包含播放/暫停按鈕（三角形）、停止按鈕、速度選擇器（1x / 2x / 5x）
- [x] 7.2 播放按鈕依 `SimulationStatus` 切換啟用/停用狀態：僅在 `ready` 或 `paused` 時啟用
- [x] 7.3 實作播放進度條，依 EventChannel 的 `{index, total}` 計算並顯示百分比

## 8. 設定引導元件

- [x] 8.1 建立 `lib/features/gps_simulator/widgets/setup_guide_card.dart`：顯示兩步驟引導（開發者選項 + 選擇模擬位置 App）與確認按鈕
- [x] 8.2 使用 `shared_preferences` 儲存「已完成設定」狀態，初次啟動顯示引導卡片，確認後不再顯示
- [x] 8.3 在 GPS mock 發生錯誤時顯示 SnackBar，含「查看設定步驟」按鈕重新顯示引導

## 9. 主頁面與整合

- [x] 9.1 建立 `lib/features/gps_simulator/gps_simulator_page.dart`，整合 `SimulatorMap`、`RouteStatusBar`、`PlaybackControls`、`SetupGuideCard`，以 `ChangeNotifier` 管理全頁狀態
- [x] 9.2 在 `lib/core/navigation/feature_registry.dart` 新增「位置工具」分類，並加入「GPS 路線模擬器」項目
- [x] 9.3 確認 pubspec.yaml 補充 `shared_preferences` 依賴並執行 `flutter pub get`

## 10. 測試與驗證

- [ ] 10.1 在實體 Android 11+ 裝置上完成端對端測試 *(需裝置實測)*：長按設點 → 路線規劃 → 播放 → 確認其他 App 收到假位置
- [ ] 10.2 測試速度倍率 1x / 2x / 5x 移動平滑度
- [ ] 10.3 測試未設定模擬位置 App 時的錯誤提示與引導流程
- [ ] 10.4 測試 App 切至背景（開啟遊戲）後 GPS mock 持續運作
