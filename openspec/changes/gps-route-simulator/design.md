## Context

App Center 是一個 Flutter 多工具 App，以 `FeatureRegistry` 統一管理所有功能頁面。目前無任何地圖或位置相關功能。本次新增 GPS 路線模擬器，需要：Flutter 層的地圖 UI 與路線規劃、Android 原生層的 OS 級 GPS mock（Foreground Service + LocationManager），以及連接兩層的 Platform Channel。

## Goals / Non-Goals

**Goals:**
- 使用者長按地圖設定起訖點，自動呼叫 OSRM 計算路線
- 線性插值使移動軌跡平滑（約每 10m 一個點）
- Android Foreground Service 持續注入假 GPS，對所有 App 生效
- 播放/暫停/停止控制，支援 1x / 2x / 5x 速度
- 首次使用引導說明開發者選項設定

**Non-Goals:**
- iOS 支援（iOS 限制 OS 層 GPS mock）
- 地址文字搜尋 / Geocoding
- 路線歷史記錄
- 繞過 `isFromMockProvider()` 旗標（需 root，超出範圍）

## Decisions

### D1：地圖套件選 flutter_map（非 google_maps_flutter）
**理由**：OpenStreetMap 免費無 API Key 費用，flutter_map 已足夠支援標記與折線顯示。
**替代方案**：google_maps_flutter — 品質更高但需付費 API Key，超出此工具性功能的合理成本。

### D2：路線 API 選 OSRM 公開端點（非 Google Directions）
**理由**：`router.project-osrm.org` 免費可直接使用，不需 API Key，適合開發工具。
**替代方案**：Google Directions API — 精準但收費；OpenRouteService — 需申請 Key。
**風險**：公開端點有速率限制，正常使用不影響，但不適合高頻商業場景。

### D3：線性插值在 Flutter 層執行
OSRM 回傳 sparse 轉折點，在 Flutter 的 `RouteInterpolator` 中插值至每 ~10m 一點，再將完整座標陣列傳給 Android Service。
**理由**：邏輯集中在 Flutter 層易於測試，避免 Android 端重新計算。

### D4：Platform Channel 協議
- **MethodChannel** `gps_mock/control`：Flutter → Android 傳送指令（start/pause/resume/stop）
- **EventChannel** `gps_mock/progress`：Android → Flutter 推送進度事件
- start 指令攜帶完整座標陣列與 interval_ms，Service 不需要自己計算插值

```
Flutter                          Android Service
  │──start({points, intervalMs})──▶│
  │◀──{type:progress, index, total}─│  (每個點)
  │◀──{type:completed}──────────────│
  │──pause()───────────────────────▶│
  │──resume()──────────────────────▶│
  │──stop()────────────────────────▶│
```

### D5：Foreground Service 必要性
遊戲使用時 App Center 會切到背景，必須使用 Foreground Service + 常駐通知才能保持 GPS mock 持續運作。Android 11+ 需宣告 `foregroundServiceType="location"`。

### D6：速度控制透過調整 intervalMs 實現
固定每次前進一個插值點，透過調整 timer interval 控制速度：
- 1x → intervalMs = 基準值（依 OSRM duration 計算）
- 2x → intervalMs / 2
- 5x → intervalMs / 5

### D7：起點/終點長按狀態機
- 第一次長按 → 設為起點（綠色標記）
- 第二次長按 → 設為終點（紅色標記），自動觸發路線計算
- 第三次長按（已有完整路線）→ 彈出 BottomSheet 選擇「設為新起點」或「設為新終點」
- 播放中長按 → 忽略（避免誤觸）

## Risks / Trade-offs

- **`isFromMockProvider() = true`**：Android 自動標記 mock 位置，有反作弊機制的遊戲可能偵測到 → 這是 OS 設計限制，無法在不 root 的情況下解決，文件中說明。
- **OSRM 公開端點可用性**：依賴第三方免費服務，偶爾可能不可用 → UI 顯示明確錯誤訊息，建議使用者重試。
- **用戶未設定 Mock Location App**：`LocationManager.addTestProvider()` 會拋出 `SecurityException` → Service 捕獲例外，透過 EventChannel 回傳 `{type:error}`，Flutter 顯示引導提示。
- **大型路線座標陣列傳輸**：長路線插值後可能有數千個點，透過 MethodChannel 傳遞大 JSON → 實測通常 < 1MB，可接受；若有問題可改為分批傳送。

## Migration Plan

純新增功能，不修改現有程式碼邏輯（僅在 `feature_registry.dart` 新增條目）。無資料遷移需求，無需 rollback 計畫。

## Open Questions

- OSRM `driving` profile 的路線精確度是否符合預期測試場景？（可在實作後實測調整為 `cycling` 或 `walking`）
