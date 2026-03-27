## Context

app_center 是一個全新的 Flutter 專案，目前只有預設的 counter demo。目標是作為多功能工具箱 app，預期容納 10~20 個彼此獨立的功能，運行平台為純手機（Android/iOS），UI 風格採用 Material 3。

現有 `lib/main.dart` 中只有 `MyApp` + `MyHomePage` (counter)，沒有任何導航結構。

## Goals / Non-Goals

**Goals:**
- 建立可擴充的導航框架，新增功能不需修改導航層程式碼
- 實作 Material 3 NavigationDrawer，含可收縮分類群組（ExpansionTile）
- 頂部搜尋框即時過濾功能名稱
- 集中式 FeatureRegistry 作為唯一的功能清單來源
- 以 2 個 placeholder 功能示範接入方式

**Non-Goals:**
- 不實作任何實際功能（DNS、JSON formatter 等）
- 不引入狀態管理套件（Provider/Riverpod），此階段用 StatefulWidget 即可
- 不做持久化（記住上次選中的功能）
- 不支援巢狀超過兩層的導航

## Decisions

### D1：使用 Flutter 內建 Drawer，不用套件

**決定**：直接用 `Drawer` + `ExpansionTile` + `ListTile` 組合，不引入 `flutter_adaptive_scaffold` 或其他導航套件。

**理由**：10~20 個功能的規模不需要複雜套件；保持依賴最小化；Material 3 內建元件已足夠。

**替代方案考慮**：`NavigationDrawer`（Material 3 官方元件）雖然語意更正確，但不原生支援 ExpansionTile 群組，需要 workaround；直接用 `Drawer` + 自定義內容更靈活。

---

### D2：FeatureRegistry 使用靜態 List，不用反射或自動掃描

**決定**：`FeatureRegistry` 是一個靜態常數 List，開發者手動加入每個 `FeatureItem`。

**理由**：Flutter 沒有執行時反射；靜態清單在 compile time 可驗證型別安全；閱讀性高，一個地方看到所有功能。

**替代方案考慮**：用 `Map<String, WidgetBuilder>` 加動態路由，但失去型別安全與分類結構。

---

### D3：搜尋過濾在 Drawer 內部處理，不提升到全域狀態

**決定**：搜尋關鍵字的 state 保存在 `AppDrawer` 的 `StatefulWidget` 內。

**理由**：搜尋只影響 Drawer 的顯示，不需要跨 widget 共享；避免過早引入狀態管理。

---

### D4：頁面切換用 setState 更新 selectedPage，不用路由

**決定**：`ShellPage` 用 `setState` 維護目前選中的 `Widget`，點選功能時直接替換 body。

**理由**：功能之間完全獨立，不需要 back stack；避免路由複雜度；符合簡單工具箱的使用模式。

## 檔案結構

```
lib/
├── main.dart                        ← 修改：home 改為 ShellPage
├── app.dart                         ← 新增：MaterialApp + theme 設定
├── core/
│   └── navigation/
│       ├── feature_registry.dart    ← 新增：FeatureCategory, FeatureItem, 靜態清單
│       └── app_drawer.dart          ← 新增：Drawer widget
├── features/
│   ├── home/
│   │   └── home_page.dart           ← 新增：預設首頁（app 啟動時顯示）
│   └── placeholder/
│       └── placeholder_page.dart    ← 新增：示範用 placeholder 功能頁
└── shell_page.dart                  ← 新增：主框架（AppBar + Drawer + Body）
```

## Risks / Trade-offs

- **[Risk] StatefulWidget 管理 selectedPage 在功能增多後可能難以維護** → Mitigation：此架構設計成易於遷移到 Riverpod/Provider，`ShellPage` 的 state 邏輯集中，未來只需抽出到 provider 即可
- **[Risk] Drawer 內的搜尋用 setState，每次輸入都重建整個 Drawer** → Mitigation：功能清單最多 20 項，重建成本可忽略；若未來效能有問題再加 `ValueNotifier`
