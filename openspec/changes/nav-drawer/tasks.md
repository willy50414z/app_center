## 1. 專案基礎設定

- [x] 1.1 修改 `lib/main.dart`：移除 counter demo，改用 `App` widget（從 `app.dart` import）
- [x] 1.2 新增 `lib/app.dart`：建立 `MaterialApp`，設定 `useMaterial3: true`，theme 使用 `ColorScheme.fromSeed`，home 設為 `ShellPage`

## 2. FeatureRegistry 資料層

- [x] 2.1 新增 `lib/core/navigation/feature_registry.dart`：定義 `FeatureItem`（title, icon, page）與 `FeatureCategory`（title, icon, items）資料類別
- [x] 2.2 在 `FeatureRegistry` 加入靜態 `categories` 清單，加入 2 個示範分類，每個分類各含 1~2 個 placeholder 功能
- [x] 2.3 在 `FeatureRegistry` 實作 `search(String keyword)` 靜態方法，回傳過濾後的 `List<FeatureCategory>`

## 3. Placeholder 功能頁

- [x] 3.1 新增 `lib/features/home/home_page.dart`：app 啟動時的預設首頁（簡單顯示 app 名稱與說明文字）
- [x] 3.2 新增 `lib/features/placeholder/placeholder_page.dart`：通用 placeholder 頁面，接收 `title` 參數，顯示「功能開發中」訊息

## 4. AppDrawer 導航元件

- [x] 4.1 新增 `lib/core/navigation/app_drawer.dart`：建立 `AppDrawer` StatefulWidget 骨架，接收 `selectedTitle` 與 `onFeatureSelected` callback
- [x] 4.2 實作 Drawer 頂部搜尋框（TextField），state 內維護 `_searchQuery`，輸入時呼叫 `setState`
- [x] 4.3 實作功能列表：用 `FeatureRegistry.search(_searchQuery)` 取得分類，用 `ExpansionTile` 渲染分類，用 `ListTile` 渲染功能項目
- [x] 4.4 實作選中功能高亮：ListTile 根據 `selectedTitle` 決定是否套用 `selected: true` 樣式
- [x] 4.5 實作搜尋無結果提示：當過濾後清單為空時，顯示「找不到相關功能」文字

## 5. ShellPage 主框架

- [x] 5.1 新增 `lib/shell_page.dart`：建立 `ShellPage` StatefulWidget，state 維護 `_currentPage`（Widget）與 `_currentTitle`（String）
- [x] 5.2 實作 `Scaffold`：AppBar 含漢堡 `IconButton`（呼叫 `Scaffold.of(context).openDrawer()`），drawer 設為 `AppDrawer`，body 設為 `_currentPage`
- [x] 5.3 實作 `onFeatureSelected` handler：接收 `FeatureItem`，呼叫 `setState` 更新 `_currentPage` 與 `_currentTitle`，關閉 Drawer

## 6. 驗收測試

- [ ] 6.1 確認 app 啟動顯示 HomePage，AppBar 顯示正確標題
- [ ] 6.2 確認 Drawer 開啟後顯示所有分類（ExpansionTile 預設展開）
- [ ] 6.3 確認點選功能後 Drawer 關閉、Body 更新、AppBar 標題更新
- [ ] 6.4 確認搜尋框可即時過濾功能列表
- [ ] 6.5 確認搜尋無結果時顯示提示文字
