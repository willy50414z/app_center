## Context

GPS 模擬器的走路功能使用 `Random()` 生成路徑偏移，每次執行都會產生不同的偏移方向。此外 accuracy 固定 1m 過於精確。這導致：
- 同一段路徑多次執行時，路徑形狀不一致
- 位置跳動幅度過大，模擬體驗不佳

## Goals / Non-Goals

**Goals:**
- 固定 Random seed，讓同樣座標每次走路生成的路徑一致
- 縮小偏移範圍從 ±8m 到 ±2m，減少路徑偏離原線的程度
- 提高 accuracy 至 8m，更接近真實走路 GPS 行為

**Non-Goals:**
- 不修改路徑規劃演算法邏輯
- 不增加新的 GPS Provider 支援

## Decisions

### Decison 1: 固定 Random seed 機制
**選擇：** 在 `generateWalkingPath` 新增可選的 seed 參數，預設使用固定值

- **考慮過的替代方案：**
  - 使用時間 seed → 每次仍不同，達不到穩定性
  - 使用 UUID → 需要外部傳入，不夠方便
  - 完全移除隨機偏移 → 失去模擬真實走路的自然感

- **理由：** 固定 seed 可在不影響 API 的情況下，確保同樣輸入產生同樣輸出。若未來需要每次不同的隨機性，可從外部傳入自訂 seed。

### Decision 2: 偏移範圍從 ±8m 縮小至 ±2m
**理由：** 
- 實際 GPS 走路誤差不會超過 10m
- ±8m 的偏移範圍在市區可能讓點偏離道路太遠
- ±2m 更接近實際 GPS 誤差不確定性

### Decision 3: Accuracy 從 1.0f 改為 8.0f
**理由：**
- 實際手機 GPS 在市區 accuracy 通常在 3-15m
- 1m 的 accuracy 太過精確，看起來像假的
- 8m 更接近真實走路情境

## Risks / Trade-offs

| 風險 | 說明 | 緩解 |
|------|------|------|
| 路徑看起來太直 | 移除偏移後路徑變成直線 | 保留 ±2m 小範圍偏移維持自然感 |

## Risks / Trade-offs

- **Trade-off:** 小偏移範圍可能讓路徑看起來較直，但 ±2m 足以維持自然感
- **Risk:** 若未來需要不同隨機性，需要修改 API 傳入 seed