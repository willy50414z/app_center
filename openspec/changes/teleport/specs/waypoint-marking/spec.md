## ADDED Requirements

### Requirement: Display map center crosshair
系統 SHALL 在地圖畫面中央顯示固定的準心（十字游標）疊加層，不隨地圖平移移動。

#### Scenario: Crosshair always visible
- **WHEN** 使用者在任何狀態下開啟 GPS 路線模擬器頁面
- **THEN** 準心 SHALL 顯示於地圖畫面正中央
- **THEN** 準心 SHALL 不受地圖平移、縮放影響（固定在 Widget 層）

#### Scenario: Crosshair hidden during active teleport or walk
- **WHEN** 傳送或走路正在進行中（TELEPORTING / WALKING 狀態）
- **THEN** 準心 SHALL 仍保持可見（使用者可預覽下一個可能的標記位置）

### Requirement: Record waypoint via 標記 button
使用者 SHALL 能透過點擊「標記」按鈕，將當前地圖中心座標記錄為一個路點。

#### Scenario: Mark button records map center
- **WHEN** 使用者平移地圖使準心對準目標位置，並點擊「標記」按鈕
- **THEN** 系統 SHALL 將當前 `MapController.camera.center` 座標加入路點列表
- **THEN** 地圖 SHALL 顯示新增的編號標記（如已有 2 個標記則顯示 ③）

#### Scenario: Mark button disabled during active session
- **WHEN** 傳送或走路正在進行中（TELEPORTING / WALKING 狀態）
- **THEN** 「標記」按鈕 SHALL 顯示為停用狀態

### Requirement: Display numbered waypoint markers on map
系統 SHALL 在地圖上以編號標記（①②③…）顯示所有已記錄的路點。

#### Scenario: Markers shown in recording order
- **WHEN** 使用者已標記 N 個路點
- **THEN** 地圖 SHALL 以數字 1~N 順序顯示對應標記，標記外觀應可辨認（含數字或顏色區分）

#### Scenario: Markers persist after walk completes
- **WHEN** 走路模擬完成或使用者按下停止
- **THEN** 所有路點標記 SHALL 繼續顯示於地圖上

### Requirement: Clear all waypoints
使用者 SHALL 能一鍵清除所有已記錄的路點。

#### Scenario: Clear all button removes all markers
- **WHEN** 使用者點擊「清除全部」按鈕
- **THEN** 路點列表 SHALL 清空
- **THEN** 地圖上所有編號標記 SHALL 移除
- **THEN** 系統狀態 SHALL 回到 IDLE

#### Scenario: Clear all button disabled when no waypoints
- **WHEN** 路點列表為空
- **THEN** 「清除全部」按鈕 SHALL 顯示為停用狀態

#### Scenario: Clear all disabled during active session
- **WHEN** 傳送或走路正在進行中
- **THEN** 「清除全部」按鈕 SHALL 顯示為停用狀態
