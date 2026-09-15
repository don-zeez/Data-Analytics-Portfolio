# Project 4: Automotive Parts Distributor — Multi-Year Sales Data Model (Power Pivot / DAX)

**Tool:** Excel Power Pivot (Data Model) + DAX measures
**Tool category in portfolio:** Single-tool mastery (Phase 1 of 7)

## The Business Problem

An automotive parts distributor sells 8 product lines across 5 branches, with 3 years of
transaction history (2023–2025). Leadership wants to know: **Is growth accelerating or
slowing? Which product categories actually make money after cost? And which year-over-year
comparisons matter for the board deck?**

A single flat sheet with 1,159 rows and a wall of VLOOKUPs would work, technically — but it
breaks the moment someone adds a new branch or product, and every "new measure" means editing
formulas across the whole sheet. **This is exactly the problem Power Pivot's data model
exists to solve**: build the relationships once, then every measure is reusable and the model
scales without rework.

## Files in This Project

| File | Purpose |
|---|---|
| `Automotive_Parts_Sales_Model.xlsx` | 4 normalized tables (1 Fact, 3 Dimensions) + an Answer Key sheet |
| `Fact_Sales.csv`, `Dim_Date.csv`, `Dim_Branch.csv`, `Dim_Product.csv` | Same tables, portable format |

**This is a star schema** — the standard data-modeling pattern in BI:

```
        Dim_Date
            |
Dim_Branch — Fact_Sales — Dim_Product
```

`Fact_Sales` holds the numbers (Units Sold, Revenue, Cost) and foreign keys only. Everything
descriptive (branch name, region, product name, category, year, quarter) lives in the
Dimension tables. This is deliberate — it's what makes the model relate correctly and what
every real BI tool (Power BI, Tableau, Looker) expects.

## Step-by-Step: Build the Data Model Yourself

Open `Automotive_Parts_Sales_Model.xlsx` in desktop Excel (Power Pivot must be enabled:
`File` → `Options` → `Add-ins` → `COM Add-ins` → check `Microsoft Power Pivot for Excel`).

### 1. Add each table to the Data Model
Click inside each table (`FactSales`, `DimDate`, `DimBranch`, `DimProduct`) → `Power Pivot`
tab → `Add to Data Model`. Do this for all 4.

### 2. Build the relationships
In the Power Pivot window: `Design` → `Manage Relationships` → `Create`:
- `Fact_Sales[DateKey]` → `Dim_Date[DateKey]`
- `Fact_Sales[BranchID]` → `Dim_Branch[BranchID]`
- `Fact_Sales[ProductID]` → `Dim_Product[ProductID]`

All three are **many-to-one** (many fact rows relate to one dimension row) — Power Pivot
usually detects this automatically. Confirm the diagram view shows all 4 tables connected
in a star.

### 3. Write your base DAX measures
In the Power Pivot window, click into the calculation area below `Fact_Sales` and add:

```dax
Total Revenue := SUM(Fact_Sales[Revenue])
Total Cost := SUM(Fact_Sales[Cost])
Gross Profit := [Total Revenue] - [Total Cost]
Gross Margin % := DIVIDE([Gross Profit], [Total Revenue], 0)
```

`DIVIDE(...,...,0)` is used instead of `/` — it returns 0 instead of a `#DIV/0!` error when
the denominator is empty. This is a DAX best practice, not optional polish.

### 4. Write the Year-over-Year growth measure
Because `Dim_Date` only has one row per **month** (not a full daily calendar), standard
time-intelligence functions like `SAMEPERIODLASTYEAR` won't behave reliably — they expect a
contiguous daily date table. Use this pattern instead, which works correctly at month grain:

```dax
Prior Year Revenue :=
VAR CurrentYear = MAX(Dim_Date[Year])
RETURN
CALCULATE(
    [Total Revenue],
    FILTER(ALL(Dim_Date), Dim_Date[Year] = CurrentYear - 1)
)

YoY Growth % := DIVIDE([Total Revenue] - [Prior Year Revenue], [Prior Year Revenue], 0)
```

### 5. Cross-check against the Answer Key
Build a PivotTable from the Data Model (`Power Pivot` → `PivotTable`), drag `Dim_Date[Year]`
to Rows and your 4 measures to Values. Compare against the `Answer Key` sheet:
- 2023 Revenue: NGN 346,326,100
- 2024 Revenue: NGN 389,168,200 (YoY +12.4%)
- 2025 Revenue: NGN 475,080,200 (YoY +22.1%)

If your numbers don't match, the relationship or filter direction is likely wrong — check
`Manage Relationships` before touching the DAX again.

### 6. Add category-level margin
New PivotTable: `Dim_Product[Category]` to Rows, `Gross Margin %` to Values. You should see
Fluids highest (~52%) and Electrical lowest (~30%) — matches the Answer Key.

### 7. Add a running total (optional, advanced)
```dax
Running Total Revenue :=
CALCULATE(
    [Total Revenue],
    FILTER(ALL(Dim_Date), Dim_Date[DateKey] <= MAX(Dim_Date[DateKey]))
)
```
Drop this in a PivotTable with `Dim_Date[DateKey]` on Rows to see cumulative revenue build
month by month — this is the DAX pattern behind every "YTD" or "running total" chart you've
ever seen in a BI dashboard.

## Key Techniques Demonstrated

- Star schema design: fact table + dimension tables, not one flat sheet
- Data Model relationships (the Power Pivot alternative to VLOOKUP)
- DAX measures: `SUM`, `DIVIDE` (safe division), `CALCULATE`, `FILTER`, `ALL`
- A YoY growth pattern that works without a full daily calendar table
- Building PivotTables directly from the Data Model instead of a single sheet

## How to Build Your Own Version

Any multi-year, multi-dimension business question fits this pattern: retail sales by store
and category, subscription revenue by plan and region, or — tying to your background —
fleet maintenance cost by vehicle type and depot over multiple years. The reusable skill is
star-schema design + DAX measures, not the automotive numbers specifically.

## What to Say About This in an Interview

"I modeled 3 years of multi-branch sales data as a proper star schema in Power Pivot instead
of a flat sheet, then wrote DAX measures for gross margin and year-over-year growth that
scale automatically as new months of data are added — no formula rewrites needed when the
business grows."
