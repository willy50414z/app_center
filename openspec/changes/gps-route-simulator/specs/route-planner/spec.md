## ADDED Requirements

### Requirement: Display interactive map
系統 SHALL 在 GPS 路線模擬器頁面顯示基於 OpenStreetMap 的互動地圖，支援縮放與平移。

#### Scenario: Map loads on page open
- **WHEN** 使用者開啟 GPS 路線模擬器頁面
- **THEN** 地圖 SHALL 顯示，預設中心點為台灣（緯度 23.5, 經度 121.0），縮放層級 7

### Requirement: Set origin via long press
系統 SHALL 允許使用者透過長按地圖設定起點。

#### Scenario: First long press sets origin
- **WHEN** 使用者在地圖上長按且目前無起點
- **THEN** 系統 SHALL 在該座標放置綠色起點標記，並顯示「起點已設定」的短暫提示

#### Scenario: Long press when route is active replaces origin
- **WHEN** 使用者在地圖上長按且目前已有完整路線（起點 + 終點）
- **THEN** 系統 SHALL 顯示 BottomSheet，提供「設為新起點」與「設為新終點」兩個選項

#### Scenario: Long press ignored during playback
- **WHEN** GPS 模擬正在播放中，使用者長按地圖
- **THEN** 系統 SHALL 忽略此長按，不改變任何狀態

### Requirement: Set destination via long press
系統 SHALL 允許使用者透過長按地圖設定終點。

#### Scenario: Second long press sets destination and triggers routing
- **WHEN** 使用者在地圖上長按且目前已有起點但無終點
- **THEN** 系統 SHALL 在該座標放置紅色終點標記，並立即呼叫 OSRM API 計算路線

### Requirement: Fetch and display route from OSRM
系統 SHALL 呼叫 OSRM 公開端點取得駕車路線，並在地圖上顯示。

#### Scenario: Successful route fetch
- **WHEN** 起點與終點均已設定
- **THEN** 系統 SHALL 呼叫 `https://router.project-osrm.org/route/v1/driving/{lng1},{lat1};{lng2},{lat2}?overview=full&geometries=geojson`
- **THEN** 地圖 SHALL 以藍色折線顯示完整路線
- **THEN** 介面 SHALL 顯示路線總距離（公里）與預估行駛時間

#### Scenario: OSRM request fails
- **WHEN** OSRM API 呼叫失敗（網路錯誤或非 200 回應）
- **THEN** 系統 SHALL 顯示錯誤訊息「無法取得路線，請檢查網路連線後重試」
- **THEN** 終點標記 SHALL 保留，播放按鈕 SHALL 維持停用狀態

#### Scenario: Route loading indicator
- **WHEN** OSRM API 呼叫進行中
- **THEN** 系統 SHALL 在地圖上顯示載入指示器，播放按鈕 SHALL 停用

### Requirement: Linear interpolation of route points
系統 SHALL 對 OSRM 回傳的 sparse 路線點執行線性插值，使相鄰點間距不超過 15 公尺。

#### Scenario: Sparse segment interpolation
- **WHEN** OSRM 回傳兩相鄰點距離超過 15 公尺
- **THEN** 系統 SHALL 在兩點間插入均勻分布的中間點，使每段距離 ≤ 15 公尺
