## 1. Fix route_interpolator.dart

- [ ] 1.1 固定 Random seed: 將 `final random = Random()` 改為使用固定 seed 值（例如 42），或將 seed 作為參數傳入
- [ ] 1.2 縮小偏移範圍: 將 `clamp(-8.0, 8.0)` 改為 `clamp(-2.0, 2.0)`

## 2. Fix GpsMockService.kt

- [ ] 2.1 提高 accuracy: 將 `accuracy = 1.0f` 改為 `accuracy = 8.0f`

## 3. Verify

- [ ] 3.1 執行走路測試多次，確認每次路徑一致
- [ ] 3.2 觀察位置跳動幅度是否在合理範圍內