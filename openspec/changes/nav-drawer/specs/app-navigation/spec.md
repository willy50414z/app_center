## ADDED Requirements

### Requirement: ShellPage 主框架
系統 SHALL 提供 `ShellPage` 作為 app 的 home，包含：AppBar（左側漢堡選單圖示）、Drawer（`AppDrawer`）、Body（動態顯示目前選中功能的 Widget）。

#### Scenario: 初始狀態
- **WHEN** app 啟動
- **THEN** ShellPage 顯示預設首頁（`HomePage`），AppBar 標題為目前功能名稱，Drawer 關閉

#### Scenario: 開啟 Drawer
- **WHEN** 使用者點選 AppBar 左側漢堡選單圖示
- **THEN** AppDrawer 從左側滑入顯示

---

### Requirement: AppDrawer 功能列表
`AppDrawer` SHALL 顯示來自 `FeatureRegistry.categories` 的所有分類與功能，每個分類使用 `ExpansionTile` 呈現，預設全部展開。

#### Scenario: 顯示分類與功能
- **WHEN** Drawer 開啟
- **THEN** 每個 FeatureCategory 顯示為一個可收縮的群組，群組內列出所有 FeatureItem

#### Scenario: 收縮分類
- **WHEN** 使用者點選已展開的分類標頭
- **THEN** 該分類的功能列表收起，標頭的展開箭頭旋轉為收縮狀態

#### Scenario: 展開分類
- **WHEN** 使用者點選已收縮的分類標頭
- **THEN** 該分類的功能列表展開顯示

---

### Requirement: 功能選擇與頁面切換
使用者點選功能項目後，系統 SHALL 關閉 Drawer、更新 AppBar 標題為功能名稱、Body 切換為對應功能的 Widget。

#### Scenario: 選擇功能
- **WHEN** 使用者點選 Drawer 中的某個 FeatureItem
- **THEN** Drawer 自動關閉，ShellPage body 替換為該功能的 page widget，AppBar 標題更新為功能 title

#### Scenario: 選中狀態標示
- **WHEN** 某功能已被選中
- **THEN** 該功能的 ListTile 在 Drawer 中顯示選中樣式（背景色高亮）

---

### Requirement: Drawer 頂部搜尋框
`AppDrawer` SHALL 在功能列表上方提供搜尋框，使用者輸入時即時過濾顯示的功能列表。

#### Scenario: 輸入搜尋關鍵字
- **WHEN** 使用者在搜尋框輸入文字
- **THEN** 功能列表即時更新，只顯示名稱包含關鍵字的功能（不分大小寫），符合條件的分類自動展開

#### Scenario: 清除搜尋
- **WHEN** 使用者清空搜尋框
- **THEN** 功能列表恢復顯示所有功能與分類

#### Scenario: 搜尋無結果
- **WHEN** 搜尋關鍵字無任何功能符合
- **THEN** 功能列表區域顯示「找不到相關功能」提示文字

---

### Requirement: Material 3 視覺風格
導航元件 SHALL 使用 Material 3 設計語言，包含：圓角卡片、ColorScheme 色彩系統、適當的 elevation 與 surface tones。

#### Scenario: 主題套用
- **WHEN** app 使用 `ThemeData` with `useMaterial3: true`
- **THEN** Drawer、AppBar、ListTile 等元件自動套用 Material 3 樣式
