## Why

現有的 GPS 路線模擬器依賴 OSRM API 規劃起訖點路線，對於想要快速定點測試或手動規劃任意路徑的使用者而言流程繁瑣。此次改版將操作模式改為「地圖準心標記座標」，支援一鍵瞬移至指定位置，以及依序在多個標記點間以步行速度模擬自然移動。

## What Changes

- **BREAKING** 移除 OSRM 路線規劃：不再以長按設定起訖點、不再呼叫外部 OSRM API
- **BREAKING** 播放控制改版：移除播放 / 暫停按鈕組合，改為「傳送 / 走路 / 停止」
- 新增地圖準心 (crosshair) 疊加層，常駐顯示於地圖中央
- 新增「標記」按鈕：記錄當前地圖中心座標，於地圖上顯示編號標記 ①②③…
- 新增「傳送」按鈕：瞬間將 GPS 定位設至最後一個標記座標，並持續保持
- 新增「走路」按鈕：依序沿所有標記點以步行速度（約 1.4 m/s）移動，路徑加入隨機橫向擾動模擬自然走路
- 新增「清除全部」按鈕：清除所有標記點
- 「停止」按鈕：在傳送 / 走路進行中為唯一可用按鈕，停止後回到標記狀態（標記點保留）
- Android `GpsMockService` 新增 TELEPORT 模式：持續以固定間隔注入同一座標，直到手動停止

## Capabilities

### New Capabilities

- `waypoint-marking`: 地圖準心疊加層、標記按鈕記錄地圖中心座標、編號標記顯示（①②③）、清除全部按鈕
- `waypoint-walking`: 步行速度插值路徑生成、隨機橫向擾動曲線模擬、多標記點依序移動

### Modified Capabilities

- `route-planner`: **BREAKING** 移除 OSRM API 整合、移除起訖點長按互動模型，改由準心標記主導地圖互動
- `gps-mock-engine`: 新增 TELEPORT 持續注入模式（傳送功能）；按鈕模型由播放/暫停/停止改為傳送/走路/停止

## Impact

- **移除依賴使用**：`osrm_service.dart`（不再呼叫外部路線 API）
- **修改 Flutter 元件**：`gps_simulator_page.dart`、`simulator_map.dart`、`playback_controls.dart`、`gps_mock_channel.dart`
- **移除 Flutter 元件**：`route_status_bar.dart`（不再顯示 OSRM 路線資訊）
- **修改 Android 原生**：`GpsMockService.kt` 新增 TELEPORT intent extra 與持續注入邏輯
- **修改 Dart channel**：`gps_mock_channel.dart` 新增 `teleport()` 方法
- **擴充插值邏輯**：`route_interpolator.dart` 加入隨機曲線擾動演算法
- **目標平台**：僅影響 Android，iOS / 其他平台不受影響
