## ADDED Requirements

### Requirement: TELEPORT mode — persistent single-location injection
系統 SHALL 支援 TELEPORT 模式，持續將 GPS 定位固定至指定座標，直到明確停止。

#### Scenario: Start teleport
- **WHEN** Flutter 層呼叫 `teleport(lat, lng)` method channel（`mode: "teleport"`）
- **THEN** GpsMockService SHALL 啟動（或複用已啟動的 Service）
- **THEN** Service SHALL 立即注入指定座標至 `LocationManager.setTestProviderLocation()`
- **THEN** Service SHALL 啟動 Handler，每 1000 ms 重新注入相同座標（防止定位過期）
- **THEN** Service SHALL 不自動停止（無 `stopSelf()`）

#### Scenario: Teleport continues in background
- **WHEN** 使用者切換至其他 App，TELEPORT 模式正在運作
- **THEN** Foreground Service SHALL 持續每秒重新注入座標
- **THEN** 目標 App 的 GPS 位置 SHALL 保持固定在傳送座標

#### Scenario: Teleport stopped explicitly
- **WHEN** 使用者點擊「停止」按鈕
- **THEN** Flutter 層呼叫 `stop()` method channel
- **THEN** Service SHALL 停止 Handler，移除 test provider，停止 Foreground Service

## MODIFIED Requirements

### Requirement: Stop GPS mock
系統 SHALL 允許使用者停止 GPS 模擬（WALK 或 TELEPORT 模式），回到標記狀態。

#### Scenario: Stop during walk
- **WHEN** 使用者在走路模擬進行中點擊「停止」按鈕
- **THEN** Service SHALL 停止並移除 test provider
- **THEN** Foreground Service SHALL 停止，通知列通知消失
- **THEN** 介面 SHALL 回到 MARKED 狀態，路點標記保留

#### Scenario: Stop during teleport
- **WHEN** 使用者在傳送進行中點擊「停止」按鈕
- **THEN** Service SHALL 停止持續注入 Handler，並移除 test provider
- **THEN** Foreground Service SHALL 停止，通知列通知消失
- **THEN** 介面 SHALL 回到 MARKED 狀態，路點標記保留

## REMOVED Requirements

### Requirement: Pause and resume GPS mock
**Reason**: 新操作模型（傳送/走路/停止）移除暫停功能，簡化 UX。走路中途停止後路點仍保留，使用者可重新開始走路。
**Migration**: 使用「停止」後重新點擊「走路」代替暫停/繼續流程。

### Requirement: Speed multiplier control
**Reason**: 走路固定以 1.4 m/s（真實步行速度）執行，不提供速度倍率選項。
**Migration**: 無替代方案；速度固定為步行速度。
