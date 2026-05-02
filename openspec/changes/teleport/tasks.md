## 1. Android Service — TELEPORT 模式

- [x] 1.1 在 `GpsMockService.kt` 新增 `EXTRA_MODE` companion constant（值："walk" | "teleport"）
- [x] 1.2 在 `onStartCommand` 讀取 `EXTRA_MODE`，分支處理 WALK 與 TELEPORT 模式
- [x] 1.3 實作 TELEPORT 模式：注入單一座標後以 Handler 每 1000 ms 重新注入，不自動 stopSelf()
- [x] 1.4 確認 `stop()` 在 TELEPORT 模式下正確清除 Handler 並移除 test provider

## 2. Flutter Channel — 新增 teleport 方法

- [x] 2.1 在 `MainActivity.kt` 的 MethodChannel handler 加入 `"teleport"` case，讀取 lat/lng 並啟動 Service（TELEPORT 模式）
- [x] 2.2 在 `gps_mock_channel.dart` 新增 `teleport(LatLng point)` 方法，透過 MethodChannel 呼叫 `"teleport"`

## 3. 路徑生成 — 隨機曲線步行插值

- [x] 3.1 在 `route_interpolator.dart`（或新增 `walking_path_generator.dart`）實作 `generateWalkingPath(List<LatLng> waypoints)` 方法
- [x] 3.2 實作相鄰兩點間的隨機橫向擾動邏輯（每 25m 一個控制點，偏移 ±3~8m 垂直方向）
- [x] 3.3 串接現有 `RouteInterpolator.interpolate()` 對控制點序列加密（5m 間隔）
- [x] 3.4 計算步行速度 interval：`(5.0 / 1.4 * 1000).round()` ms，輸出給 Service

## 4. 地圖 UI — 準心與路點標記

- [x] 4.1 在 `simulator_map.dart` 的 `Stack` 疊加準心 Widget（`Center` + Icon 或自訂十字線）
- [x] 4.2 移除原有 origin（綠）/ destination（紅）Marker 渲染邏輯
- [x] 4.3 新增 `waypoints` 參數（`List<LatLng>`），以編號標記 ①②③ 顯示於地圖
- [x] 4.4 保留目前位置移動標記（藍色圓點），在走路模擬中使用
- [x] 4.5 移除 `onLongPress` 回呼（或清空處理，不觸發任何動作）

## 5. 按鈕 UI — 新控制面板

- [x] 5.1 重寫 `playback_controls.dart`（或新建 `waypoint_controls.dart`）實作新按鈕布局：`[標記] [清除全部] / [傳送] [走路]`
- [x] 5.2 實作「停止」按鈕在 TELEPORTING / WALKING 狀態下替換整個按鈕列
- [x] 5.3 實作各按鈕的啟用/停用邏輯：
  - 「傳送」：marks.isNotEmpty
  - 「走路」：marks.length >= 2
  - 「清除全部」：marks.isNotEmpty && 非進行中
  - 「標記」：非進行中

## 6. 主頁邏輯 — 重寫 GpsSimulatorPage

- [x] 6.1 移除 `_origin`、`_destination` 欄位，加入 `_marks: List<LatLng>`
- [x] 6.2 移除 `_fetchRoute()`、OSRM 相關呼叫與 import
- [x] 6.3 實作 `_onMark()`：讀取 `_mapController.camera.center` 並加入 `_marks`
- [x] 6.4 實作 `_onClearAll()`：清空 `_marks`，重設狀態為 IDLE
- [x] 6.5 實作 `_onTeleport()`：呼叫 `_channel.teleport(_marks.last)`，狀態設為 TELEPORTING
- [x] 6.6 實作 `_onWalk()`：呼叫 `generateWalkingPath(_marks)` 後呼叫 `_channel.start()`，狀態設為 WALKING
- [x] 6.7 實作 `_onStop()`：呼叫 `_channel.stop()`，狀態回到 MARKED（保留 `_marks`）
- [x] 6.8 更新 `SimulationState` / `SimulationStatus` enum 加入 TELEPORTING 狀態（或複用 playing）
- [x] 6.9 移除 `RouteStatusBar` widget 的引用與渲染

## 7. 收尾與驗證

- [ ] 7.1 確認「傳送」後切換至目標 App（如 Google Maps），GPS 定位固定在標記座標
- [ ] 7.2 確認「走路」軌跡在地圖上顯示為帶輕微曲線的移動路徑
- [ ] 7.3 確認「停止」後 GPS 恢復真實定位，通知列通知消失
- [ ] 7.4 確認標記點在走路完成後仍保留於地圖
- [ ] 7.5 確認未設定模擬位置 App 時，按「傳送」或「走路」顯示正確錯誤訊息與引導
