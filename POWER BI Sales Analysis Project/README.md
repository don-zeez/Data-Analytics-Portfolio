# Power BI Sales Analytics Project

**Author:** Akande Abdulazeez O.
**File:** `POWER_BI_PROJECT_by_AKANDE_ABDULAZEEZ_O___2_.pbix`
**Tool:** Microsoft Power BI (report built in the Power BI service / Desktop, release 2026.06)

A single-page interactive sales dashboard that summarises revenue, cost, profit and customer activity, and breaks those figures down by product attributes, customer demographics and time.

---

## Data model

Three tables in a star-style layout, with `Sales` as the fact table:

| Table | Role | Fields used in the report |
|---|---|---|
| `Sales` | Fact | `TotalPurchase`, `SaleYear`, `SaleMonthName` |
| `ProductsTbl` | Dimension | `Brand`, `Color` |
| `Customers` | Dimension | `Region`, `IncomeLevel` |

`ProductsTbl` and `Customers` each relate to `Sales`, so slicing on a customer or product attribute filters every measure on the page.

### Measures

Four measures defined on the `Sales` table drive the KPI cards and most charts:

- **Total Revenue**
- **Total Cost**
- **Total Profit**
- **Total Customers**

`TotalPurchase` is used as a column-level `SUM` rather than a stored measure.

---

## Report page

**Page 1** — canvas 1280 × 720, title *"POWER BI PROJECT"*, built on the Power BI `CY26SU05` base theme.

### KPI cards (top row)

| Card | Measure |
|---|---|
| Total Revenue | `Sales[Total Revenue]` |
| Total Cost | `Sales[Total Cost]` |
| Total Profit | `Sales[Total Profit]` |
| Total Customers | `Sales[Total Customers]` |

### Charts (bottom row)

| Visual | Type | Axis | Value |
|---|---|---|---|
| Brand by Profit | Clustered column | `ProductsTbl[Brand]` | Total Profit |
| Color by Total Purchase | Clustered column | `ProductsTbl[Color]` | Sum of `Sales[TotalPurchase]` |
| Yearly Revenue | Clustered column | `Sales[SaleYear]` | Total Revenue |
| Monthly Customers | Clustered column | `Sales[SaleMonthName]` | Total Customers |
| Income level by Profit | Column | `Customers[IncomeLevel]` | Total Profit |

### Slicers

- **Region** (`Customers[Region]`)
- **Income Level** (`Customers[IncomeLevel]`)

Both sit in the header area and cross-filter every visual on the page. No page-level or report-level filters are applied, so the dashboard opens on the full dataset.

---

## Questions the dashboard answers

- How much revenue, cost and profit did the business generate, and how many customers did it serve?
- Which brands contribute the most profit?
- Which product colours attract the highest purchase volume?
- How has revenue moved year over year?
- Which months bring in the most customers (seasonality)?
- How does customer income level relate to profitability?
- How do all of the above change for a given region or income band?

---

## How to use

1. Install [Power BI Desktop](https://powerbi.microsoft.com/desktop/) (free).
2. Open `POWER_BI_PROJECT_by_AKANDE_ABDULAZEEZ_O___2_.pbix`.
3. Use the **Region** and **Income Level** slicers to filter the page; click any column in a chart to cross-highlight the rest.
4. To refresh against your own source, go to **Home → Transform data** and repoint the `Sales`, `ProductsTbl` and `Customers` queries.

The data is imported into the model, so the file opens and is fully interactive without a live connection to the source.

---

## Possible next steps

- Add a dedicated `Date` table with a proper date hierarchy so month names sort chronologically rather than alphabetically.
- Add profit-margin and average-order-value measures alongside the existing totals.
- Split the report into multiple pages (overview, product detail, customer detail) as the visual count grows.
- Add tooltips and drill-through from brand or region into transaction-level detail.
