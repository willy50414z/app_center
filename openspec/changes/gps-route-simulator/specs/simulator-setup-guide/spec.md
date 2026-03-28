## ADDED Requirements

### Requirement: Display setup guide on first use
系統 SHALL 在使用者首次開啟 GPS 路線模擬器時顯示設定引導，說明如何啟用 Android 開發者選項並設定模擬位置應用程式。

#### Scenario: First launch shows setup guide
- **WHEN** 使用者首次開啟 GPS 路線模擬器頁面（本機無「已完成設定」紀錄）
- **THEN** 系統 SHALL 在地圖頁面上方顯示可關閉的引導卡片

#### Scenario: Setup guide not shown after dismissal
- **WHEN** 使用者點擊「我已完成設定，開始使用」
- **THEN** 系統 SHALL 以 SharedPreferences 記錄「已完成設定」
- **THEN** 下次開啟頁面時 SHALL 不再顯示引導卡片

### Requirement: Setup guide content
設定引導 SHALL 包含清楚的步驟說明，引導使用者完成必要的 Android 設定。

#### Scenario: Guide displays correct steps
- **WHEN** 引導卡片顯示
- **THEN** SHALL 顯示步驟一：「開啟開發人員選項 — 設定 → 關於手機 → 連續點擊版本號 7 次」
- **THEN** SHALL 顯示步驟二：「選擇模擬位置應用程式 — 開發人員選項 → 選取模擬位置應用程式 → 選擇 App Center」
- **THEN** SHALL 顯示「我已完成設定，開始使用」確認按鈕

### Requirement: Error-triggered setup reminder
系統 SHALL 在偵測到 mock 權限錯誤時，主動顯示設定提醒。

#### Scenario: SecurityException triggers setup reminder
- **WHEN** GPS 模擬啟動時收到 `SecurityException`（未設定為模擬位置 App）
- **THEN** 系統 SHALL 顯示 SnackBar 或對話框，提示「請先在開發人員選項中將 App Center 設為模擬位置應用程式」
- **THEN** 提示 SHALL 包含「查看設定步驟」按鈕，點擊後顯示設定引導卡片
