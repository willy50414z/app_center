## MODIFIED Requirements

### Requirement: Display interactive map
系統 SHALL 在 GPS 路線模擬器頁面顯示基於 OpenStreetMap 的互動地圖，支援縮放與平移。

#### Scenario: Map loads on page open
- **WHEN** 使用者開啟 GPS 路線模擬器頁面
- **THEN** 地圖 SHALL 顯示，預設中心點為台灣（緯度 23.5, 經度 121.0），縮放層級 7

#### Scenario: Long press on map is ignored
- **WHEN** 使用者長按地圖任意位置
- **THEN** 系統 SHALL 不執行任何動作（長按互動已移除）

## REMOVED Requirements

### Requirement: Set origin via long press
**Reason**: 地圖互動模型改為「準心 + 標記按鈕」，不再使用長按設定起點。
**Migration**: 使用準心對準目標位置後按「標記」按鈕取代。

### Requirement: Set destination via long press
**Reason**: 目的地概念移除，改以多個標記路點取代起訖點模型。
**Migration**: 使用準心標記多個路點，最後一個路點作為傳送目標。

### Requirement: Fetch and display route from OSRM
**Reason**: 移除外部 OSRM API 依賴，路徑改以本地直線加隨機擾動演算法生成。
**Migration**: 走路模式使用本地 `WalkingPathGenerator`（`RouteInterpolator` 擴充）計算路徑，不需網路連線。

### Requirement: Linear interpolation of route points
**Reason**: 插值邏輯已移至 `waypoint-walking` capability，並整合隨機曲線擾動功能。
**Migration**: 參見 `waypoint-walking` spec 中的路徑生成需求。
