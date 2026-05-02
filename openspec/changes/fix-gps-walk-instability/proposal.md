## Why

執行 GPS 模擬器的「走路」功能時，每次生成的路徑偏移方向都不同（因為使用 `Random()` 每次都是新實例，seed 每次都不同），導致位置會「跳到很遠的地方再跳回來」。此外 accuracy 固定 1m 太過精確，與實際走路 GPS 行為不符。修正這三個問題讓走路模擬更穩定。

## What Changes

- **route_interpolator.dart**:
  - 固定 Random seed，讓同樣的路徑每次生成結果一致
  - 將偏移範圍從 ±8m 縮小到 ±2m，減少點偏離原路徑的距離
- **GpsMockService.kt**:
  - 將 accuracy 從 1.0f 改為 8.0f，更接近真實走路 GPS 誤差不會大於 10m

## Capabilities

### Modified Capabilities
- `gps-walk-simulation`: 修正走路模擬的不穩定行為

## Impact

- `lib/features/gps_simulator/services/route_interpolator.dart`
- `android/app/src/main/java/com/willy/appcenter/app_center/GpsMockService.kt`