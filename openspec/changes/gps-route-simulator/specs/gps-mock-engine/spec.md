## ADDED Requirements

### Requirement: Start GPS mock playback
系統 SHALL 提供播放按鈕，啟動 Android Foreground Service 並開始沿路線注入假 GPS 座標。

#### Scenario: Play button enabled only when route is ready
- **WHEN** 路線尚未計算完成或正在載入
- **THEN** 播放按鈕 SHALL 顯示為停用狀態（灰色）

#### Scenario: Start playback
- **WHEN** 使用者點擊播放按鈕且路線已就緒
- **THEN** 系統 SHALL 啟動 Android Foreground Service
- **THEN** Service SHALL 開始從第一個插值座標點依序呼叫 `LocationManager.setTestProviderLocation()`
- **THEN** 通知列 SHALL 顯示常駐通知，內容為「GPS 模擬中」與起訖點名稱
- **THEN** 地圖 SHALL 顯示目前模擬位置的藍色移動標記

#### Scenario: Mock location provider not set
- **WHEN** 使用者點擊播放按鈕，但 App 未被設定為系統的模擬位置應用程式
- **THEN** Service SHALL 捕獲 `SecurityException`
- **THEN** 系統 SHALL 透過 EventChannel 回傳 `{type: "error", message: "..."}`
- **THEN** Flutter 層 SHALL 顯示錯誤提示並引導使用者至設定引導頁

### Requirement: Pause and resume GPS mock
系統 SHALL 允許使用者暫停與繼續 GPS 模擬。

#### Scenario: Pause playback
- **WHEN** 使用者點擊暫停按鈕（播放中）
- **THEN** Service SHALL 停止 timer，保留目前座標索引
- **THEN** 移動標記 SHALL 停留在目前位置

#### Scenario: Resume playback
- **WHEN** 使用者點擊播放按鈕（已暫停）
- **THEN** Service SHALL 從暫停位置的座標索引繼續注入 GPS 座標

### Requirement: Stop GPS mock
系統 SHALL 允許使用者停止 GPS 模擬，重設至初始狀態。

#### Scenario: Stop playback
- **WHEN** 使用者點擊停止按鈕
- **THEN** Service SHALL 停止並移除 test provider
- **THEN** Foreground Service SHALL 停止，通知列通知消失
- **THEN** 座標索引重設為 0，移動標記回到起點
- **THEN** 播放按鈕恢復為可用狀態

#### Scenario: Playback completes naturally
- **WHEN** GPS 模擬到達路線終點（最後一個座標點）
- **THEN** Service SHALL 自動停止並回傳 `{type: "completed"}`
- **THEN** Flutter 層 SHALL 顯示「模擬完成」提示
- **THEN** 狀態重設與手動停止相同

### Requirement: Speed multiplier control
系統 SHALL 提供速度倍率選擇（1x / 2x / 5x），調整 GPS 更新頻率。

#### Scenario: Change speed multiplier
- **WHEN** 使用者選擇速度倍率
- **THEN** timer interval SHALL 依倍率調整：1x = 基準間隔，2x = 基準 / 2，5x = 基準 / 5
- **THEN** 速度變更 SHALL 在下一個 timer tick 立即生效（無需重啟 Service）

### Requirement: Playback progress reporting
系統 SHALL 持續回報播放進度至 Flutter 層。

#### Scenario: Progress event stream
- **WHEN** GPS 模擬播放中
- **THEN** Service SHALL 每個座標點透過 EventChannel 發送 `{type: "progress", index: N, total: M}`
- **THEN** Flutter 層 SHALL 以進度條顯示已完成百分比
- **THEN** 地圖移動標記 SHALL 更新至對應座標

### Requirement: Foreground Service with persistent notification
系統 SHALL 以 Android Foreground Service 運作，確保 App 在背景時 GPS mock 不中斷。

#### Scenario: App moves to background
- **WHEN** 使用者切換至其他 App（如目標遊戲），GPS 模擬正在進行中
- **THEN** Foreground Service SHALL 持續運作
- **THEN** GPS 座標注入 SHALL 不中斷
- **THEN** 通知列通知 SHALL 持續顯示
