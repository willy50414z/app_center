## Context

GPS 走路模擬使用 `LocationManager.addTestProvider` 注入假位置。目前的注入物件只帶 `latitude`、`longitude`、`accuracy`，缺少 `speed` 與 `bearing`。路徑點間距固定 5 m，在 5 km/h 時注入間隔約 3.6 秒。

Android 的 **Fused Location Provider（FLP）** 在兩次注入之間會以感應器做 dead reckoning 補位。若注入間隔過長，或 Location 物件缺少速度方向資訊，FLP 推算出的補位會與下一次注入點有明顯落差，外部 app 就會看到跳動。

## Goals / Non-Goals

**Goals:**
- 使其他 app 透過 FLP 取得的模擬位置更新頻率接近 1 Hz
- 為每個注入的 Location 填入 `speed`（m/s）與 `bearing`（度），降低 FLP 補位誤差
- 不改變走路路徑的整體形狀與感知速度

**Non-Goals:**
- 不修改 NETWORK_PROVIDER（網路定位）的模擬
- 不引入 Kalman filter 或其他平滑演算法
- 不改動 teleport 模式

## Decisions

### Decision 1: 縮小路徑點間距至 1.5 m

**選擇：** 將 `RouteInterpolator.interpolate` 的 `maxSegmentMeters` 從 5 m 改為 1.5 m，並將 `computeWalkingIntervalMs` 基準距離從 5.0 m 改為 1.5 m。

- **效果：** 5 km/h 時注入間隔從 3,600 ms 降至 ~1,080 ms（接近 1 Hz）；10 km/h 時約 540 ms。
- **替代方案考慮：**
  - 固定 500ms 定時器，Kotlin 端做插值：更複雜，要在 Android 端重寫路徑邏輯
  - 只加 speed/bearing 不改頻率：改善有限，FLP 仍有 3.6 秒的補位空間
- **Trade-off：** 點數增加約 3.3x（5÷1.5），但路徑僅在使用者明確按下 Walk 時才計算，記憶體影響可接受。

### Decision 2: 在 GpsMockService 計算並注入 speed 與 bearing

**選擇：** 在 `GpsMockService` 保留前一個注入點（`prevLat`, `prevLng`），在每次 `injectLocation` 時計算：
- `bearing`：使用 `Location.bearingTo(previous, current)` 或手算 atan2
- `speed`：`distance(prev, current) / (intervalMs / 1000.0)` m/s

- **替代方案考慮：** 在 Dart 端預先算好 speed/bearing 隨 points 一起傳入 → 傳輸量倍增，且 Kotlin 端仍需解析額外陣列
- **理由：** Kotlin 端計算更自然，只需兩個額外 Double 欄位，不影響 channel 協議。

## Risks / Trade-offs

| 風險 | 說明 | 緩解 |
|------|------|------|
| 點數暴增影響低速設備 | 1.5m 間距使點數變 ~3x | 路徑僅在按下 Walk 時計算，不常態佔用記憶體 |
| 第一個點無前驅，bearing/speed 未知 | 無法算出第一點的方向 | 第一點使用 bearing=0、speed=0，FLP 會在第二點之後修正 |
| FLP 仍有可能混合真實 GPS | Mock 設備若有真實 GPS 訊號，FLP 在初始時可能短暫混合 | 屬 Android 系統行為，無法由 app 層控制 |
