## Context

現有 GPS 路線模擬器採用「OSRM 長按起訖點」模型：使用者長按兩次地圖，系統呼叫外部 OSRM API 計算駕車路線後開始播放。此模型對定點測試流程繁瑣（需兩個點才能運作），且完全依賴外部 API 可用性。

此次改版目標：讓使用者能自由在地圖上標記任意個座標點，然後選擇「瞬移至最後標記點」或「依步行速度沿標記點移動」。

## Goals / Non-Goals

**Goals:**
- 地圖中央固定準心，按「標記」記錄當前中心座標
- 「傳送」：瞬移 GPS 至最後一個標記點，持續保持直到停止
- 「走路」：沿所有標記點以步行速度（~1.4 m/s）移動，路徑加隨機曲線
- 「清除全部」重設所有標記點
- Android Service 新增 TELEPORT 持續注入模式

**Non-Goals:**
- 不保留 OSRM API 整合
- 不提供暫停功能（簡化操作模型）
- 不提供速度倍率選擇（走路固定 1.4 m/s）
- 不支援標記點個別刪除（使用清除全部）
- 不保留「設定引導卡片」互動（setup guide card 保留顯示，但行為不變）

## Decisions

### 1. 準心而非點擊地圖加標記

**選擇**：固定準心 + 按鈕觸發，而非點擊 / 長按地圖加標記。

**理由**：
- 準心讓使用者先平移地圖精確對準目標，再按按鈕確認，比點擊更精準
- 避免點擊地圖與地圖平移手勢衝突（行動裝置上難以區分）
- 按鈕觸發讓「標記」動作有明確的視覺回饋

**實作**：`Stack` widget 在 `SimulatorMap` 上疊加一個 `Center` 的十字準心 Icon，`_mapController.camera.center` 取得當前中心座標。

---

### 2. 傳送目標為最後一個標記點

**選擇**：`_marks.last` 固定為傳送目標。

**理由**：不需要「選取標記」的 UI，使用流程更簡單—使用者自然會把想去的位置設為最後一個標記。

---

### 3. 步行路徑：直線 + 隨機橫向擾動

**選擇**：不呼叫 OSRM，改用本地演算法生成帶擾動的直線路徑。

**演算法（每段 A → B）**：
```
1. 計算 A→B 方向向量 (dLat, dLng)，正規化
2. 垂直方向 = (-dLng, dLat)（旋轉 90°）
3. 每隔 25m 在路徑上插入一個控制點
4. 對每個控制點加上 ±(3~8m) 的垂直方向隨機偏移
   偏移量 = Random(seed).nextDouble() * 10 - 5（公尺換算成經緯度）
5. 以 RouteInterpolator 以 5m 間隔加密整條路徑
```

**理由**：不依賴外部 API，離線可用；隨機擾動讓 GPS 軌跡看起來不像機器人走直線，更自然。

**步行速度插值**：
```
interval_ms = (5m / 1.4 m/s) * 1000 ≈ 3571 ms per point
```

---

### 4. Android TELEPORT 模式

**選擇**：在 `GpsMockService` 加入 `EXTRA_MODE` Intent Extra（值：`"walk"` | `"teleport"`），TELEPORT 模式下以 Handler 每秒重新注入同一座標。

**理由**：
- Android mock location 若長時間不更新會被系統判斷為過期
- 以 1 秒間隔重注入確保定位維持有效
- 乾淨的模式分支，比傳入 N 個相同點的 hack 更清楚

**Walk 模式**（保留現有行為）：走完自動 `stopSelf()`，傳回 `completed` 事件。
**Teleport 模式**：永不自動停止，只響應 `stop()` 呼叫。

---

### 5. Flutter 層新增 `teleport()` method channel 呼叫

**選擇**：`gps_mock_channel.dart` 新增 `teleport(LatLng point)` 方法，透過既有 `gps_mock/control` MethodChannel 呼叫，傳入 `mode: "teleport"` 參數。

**理由**：重用現有 channel，不需在 `MainActivity.kt` 新增額外 channel，只需多處理一個 method case。

## Risks / Trade-offs

- **隨機擾動不沿道路** → 可能穿越建築物。接受此限制：目標是「自然感」而非「地圖吻合」，使用者已知這是模擬座標。
- **步行速度固定 1.4 m/s** → 無法模擬跑步或其他速度。未來可再加速度選項，此次不在範圍內。
- **TELEPORT 持續注入耗電** → 1 秒間隔對前景 Service 影響可接受；通知列已顯示常駐提示。
- **移除暫停** → 走路中途無法暫停，只能停止後重新走。可接受，使用情境下暫停需求低。

## Migration Plan

1. `gps_simulator_page.dart` 重寫（移除 `_origin`、`_destination`、OSRM 呼叫，加入 `_marks`）
2. `simulator_map.dart` 加準心 overlay 與編號標記渲染
3. `playback_controls.dart` 改為新按鈕布局
4. `gps_mock_channel.dart` 新增 `teleport()` 方法
5. `route_interpolator.dart` 擴充隨機曲線邏輯
6. `GpsMockService.kt` 加 TELEPORT 模式分支
7. `MainActivity.kt` 處理 teleport method channel
8. 移除 `route_status_bar.dart` 的引用（可保留檔案，停止使用）

無資料庫 / API contract 異動，無需 migration script。回滾即 git revert。

## Open Questions

- 走路只有一個標記點時，`走路` 按鈕要 disable 還是按下去顯示提示？（建議 disable，灰色）
- 地圖上的編號標記點擊是否需要任何互動（目前設計：無）？
