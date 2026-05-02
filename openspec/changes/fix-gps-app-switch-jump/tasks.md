## 1. Fix route_interpolator.dart

- [x] 1.1 將 `generateWalkingPath` 末尾的 `interpolate(controlPoints, maxSegmentMeters: 5)` 改為 `maxSegmentMeters: 1.5`
- [x] 1.2 將 `computeWalkingIntervalMs` 的基準距離從 `5.0` 改為 `1.5`

## 2. Fix GpsMockService.kt

- [x] 2.1 新增 `prevLat`、`prevLng` 兩個 nullable Double 欄位，用於記錄前一個注入點
- [x] 2.2 在 `injectLocation` 中計算 bearing（atan2 or `Location.bearingTo`）與 speed（距離 / 間隔秒），寫入 `location.bearing` 與 `location.speed`
- [x] 2.3 在每次 walk 模擬重置時（`onStartCommand`）清空 `prevLat`/`prevLng`

## 3. Verify

- [ ] 3.1 以 5 km/h 啟動走路模擬，確認相鄰兩次注入間隔 ≤ 1100 ms（可用 logcat 計時）
- [ ] 3.2 切換到 Google Maps 或其他使用定位的 app，觀察位置跳動是否明顯改善
- [ ] 3.3 確認路徑整體形狀與感知移動速度未改變