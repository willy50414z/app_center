## ADDED Requirements

### Requirement: FeatureItem 資料模型
系統 SHALL 定義 `FeatureItem` 類別，包含 `title`（功能名稱）、`icon`（IconData）、`page`（Widget，lazy 建立）三個必填欄位。

#### Scenario: 建立 FeatureItem
- **WHEN** 開發者建立一個 `FeatureItem`
- **THEN** 必須提供 title、icon、page 三個欄位，缺少任一欄位應在 compile time 報錯

---

### Requirement: FeatureCategory 資料模型
系統 SHALL 定義 `FeatureCategory` 類別，包含 `title`（分類名稱）、`icon`（IconData）、`items`（List\<FeatureItem\>）三個必填欄位。

#### Scenario: 建立 FeatureCategory
- **WHEN** 開發者建立一個 `FeatureCategory`
- **THEN** 必須提供 title、icon、items 三個欄位；items 可以是空 list

---

### Requirement: 靜態功能清單
系統 SHALL 在 `FeatureRegistry` 中提供一個靜態常數 `categories`，型別為 `List<FeatureCategory>`，作為整個 app 的唯一功能來源。

#### Scenario: 讀取功能清單
- **WHEN** 任何 widget 需要顯示功能列表
- **THEN** 應從 `FeatureRegistry.categories` 讀取，不應有其他分散的功能定義

---

### Requirement: 搜尋過濾支援
系統 SHALL 支援對 `categories` 進行關鍵字過濾，回傳只包含名稱符合關鍵字的 `FeatureItem` 的過濾後 `List<FeatureCategory>`（空分類應被移除）。

#### Scenario: 搜尋有結果
- **WHEN** 使用者輸入關鍵字且有功能名稱包含該字串（不分大小寫）
- **THEN** 回傳只包含符合項目的分類列表，不符合的功能與空分類不出現

#### Scenario: 搜尋無結果
- **WHEN** 使用者輸入的關鍵字沒有任何功能名稱符合
- **THEN** 回傳空 list

#### Scenario: 關鍵字為空
- **WHEN** 搜尋關鍵字為空字串
- **THEN** 回傳完整的 `categories`，與未搜尋時相同
