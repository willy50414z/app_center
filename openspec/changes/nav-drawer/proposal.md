## Why

新建的 Flutter app_center 專案目前只有 default counter，沒有任何導航結構。為了支撐後續將多個獨立功能塞入同一個 app，需要先建立一個可擴充的現代化導航框架，讓每個新功能都能輕鬆接入而不需要修改導航層的程式碼。

## What Changes

- 新增 `FeatureRegistry`：集中管理所有功能分類與功能項目的清單，未來新增功能只需在此加一行
- 新增 `AppDrawer`：Material 3 風格的 NavigationDrawer，內含可收縮的 ExpansionTile 分類群組與頂部搜尋框
- 新增 `ShellPage`：作為 app 的主框架頁面，包含 AppBar（漢堡選單）、Drawer、以及動態顯示選中功能的 body 區域
- 移除預設的 counter demo，以 ShellPage 取代 MyHomePage 作為 home

## Capabilities

### New Capabilities

- `feature-registry`: 集中式功能目錄，定義 FeatureCategory 與 FeatureItem 資料模型，以及所有功能的靜態清單
- `app-navigation`: Material 3 NavigationDrawer 導航外殼，包含可收縮分類、搜尋過濾、選中狀態管理

### Modified Capabilities

## Impact

- `lib/main.dart`：移除 MyHomePage，改用新的 ShellPage
- 新增 `lib/core/navigation/` 目錄
- 新增 `lib/features/` 目錄結構（含 placeholder 功能頁）
- 不需要新增 pub 套件，使用 Flutter 內建 Material 3 元件
