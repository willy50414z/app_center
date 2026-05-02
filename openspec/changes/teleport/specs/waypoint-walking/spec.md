## ADDED Requirements

### Requirement: Walk through waypoints at walking speed
系統 SHALL 依序沿所有標記路點以步行速度（約 1.4 m/s）移動虛擬 GPS 位置。

#### Scenario: Walk button starts simulation when ≥2 waypoints exist
- **WHEN** 使用者已標記至少 2 個路點，並點擊「走路」按鈕
- **THEN** 系統 SHALL 啟動 Android Foreground Service（WALK 模式）
- **THEN** GPS 模擬 SHALL 從第一個路點開始，依序移動至最後一個路點
- **THEN** 介面 SHALL 僅顯示「停止」按鈕

#### Scenario: Walk button disabled when fewer than 2 waypoints
- **WHEN** 路點數量少於 2 個
- **THEN** 「走路」按鈕 SHALL 顯示為停用狀態（灰色）

#### Scenario: Walk completes naturally
- **WHEN** GPS 模擬到達最後一個路點
- **THEN** Service SHALL 自動停止並透過 EventChannel 回傳 `{type: "completed"}`
- **THEN** 系統 SHALL 顯示「走路完成」提示
- **THEN** 介面 SHALL 回到 MARKED 狀態，路點標記保留

### Requirement: Random curve path generation between waypoints
系統 SHALL 在相鄰路點之間生成帶有隨機橫向擾動的曲線路徑，模擬自然步行軌跡。

#### Scenario: Path generated with lateral displacement
- **WHEN** 計算相鄰兩路點 A → B 之間的步行路徑
- **THEN** 系統 SHALL 每隔約 25 公尺插入一個中間控制點
- **THEN** 每個控制點 SHALL 在垂直於 A→B 方向加入 ±3~8 公尺的隨機橫向偏移
- **THEN** 最終路徑 SHALL 以 5 公尺間隔加密插值（使用 RouteInterpolator）

#### Scenario: Path maintains overall direction
- **WHEN** 隨機擾動施加後
- **THEN** 路徑整體走向 SHALL 仍由 A 前進至 B（擾動不改變起終點）

### Requirement: Walking speed point interval calculation
系統 SHALL 以步行速度計算相鄰插值點間的時間間隔。

#### Scenario: Interval derived from walking speed
- **WHEN** 系統準備啟動走路模擬
- **THEN** 每個插值點的時間間隔 SHALL 計算為 `(5m / 1.4 m/s) × 1000 ≈ 3571 ms`
- **THEN** 此間隔 SHALL 作為 `EXTRA_INTERVAL_MS` 傳入 Android Service

### Requirement: Display walking progress on map
系統 SHALL 在走路模擬進行中，於地圖顯示目前虛擬位置的移動標記。

#### Scenario: Position marker updates during walk
- **WHEN** 走路模擬進行中，Service 回傳 `{type: "progress", index: N, total: M}`
- **THEN** 地圖 SHALL 更新移動標記至第 N 個插值點座標
- **THEN** 移動標記 SHALL 與路點標記（①②③）視覺上有所區別
