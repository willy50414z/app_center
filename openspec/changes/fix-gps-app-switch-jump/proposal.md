## Why

切換到其他 app（如 Google Maps）時，模擬走路定位會不規律跳動。根本原因是：更新頻率過低（5 km/h 時每 3.6 秒才注入一次）導致 Android Fused Location Provider 在兩次注入之間依感應器做死算推算，推算偏差加上注入點的落差就形成跳動；同時 Location 物件未帶 `speed` 與 `bearing`，FLP 無從得知移動方向，加劇了推算誤差。

## What Changes

- **GpsMockService.kt**：注入 `Location` 時同步填入 `speed`（m/s）與 `bearing`（度），讓 FLP 能正確推算兩次注入之間的位置
- **route_interpolator.dart**：將路徑點最大間距從 5 m 縮小至 1.5 m，並對應調整 `computeWalkingIntervalMs` 基準，使更新頻率接近 1 Hz

## Capabilities

### New Capabilities
- `gps-walk-simulation`: 走路模擬的路徑生成與 GPS 注入行為規格

### Modified Capabilities

## Impact

- `lib/features/gps_simulator/services/route_interpolator.dart`
- `android/app/src/main/java/com/willy/appcenter/app_center/GpsMockService.kt`
