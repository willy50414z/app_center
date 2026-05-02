## ADDED Requirements

### Requirement: 走路模擬更新頻率接近 1 Hz
路徑點間距 SHALL ≤ 1.5 m，使 `computeWalkingIntervalMs` 在任何支援速度下產生不超過 1100 ms 的注入間隔（以最低速 5 km/h 為基準）。

#### Scenario: 5 km/h 時注入間隔不超過 1100 ms
- **WHEN** 使用者以 5 km/h 速度啟動走路模擬
- **THEN** 相鄰兩次 GPS 注入的間隔 SHALL ≤ 1100 ms

#### Scenario: 更高速度時間隔更短
- **WHEN** 使用者以 10 km/h 速度啟動走路模擬
- **THEN** 相鄰兩次 GPS 注入的間隔 SHALL ≤ 600 ms

### Requirement: 注入的 Location 物件包含 speed 與 bearing
每次注入 GPS 位置時，Location 物件 SHALL 帶有根據前後點計算出的 `speed`（m/s）與 `bearing`（度）。

#### Scenario: 非首個點帶有速度與方向
- **WHEN** 注入第 2 個（含）以後的路徑點
- **THEN** location.speed SHALL 等於相鄰點距離除以注入間隔秒數
- **THEN** location.bearing SHALL 等於從前一點指向目前點的方位角（0–360 度）

#### Scenario: 第一個點使用預設值
- **WHEN** 注入路徑的第一個點（無前驅點）
- **THEN** location.speed SHALL 為 0.0f
- **THEN** location.bearing SHALL 為 0.0f
