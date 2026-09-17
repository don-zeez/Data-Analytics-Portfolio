# Capstone 2: Retail/Supply Chain Inventory Health

**Tools (combined pipeline):** Excel/Power Query → Power Pivot → SQL Server → Power BI
**Category:** Combined capstone (Phase 2 of 3)

## The Business Problem

A distributor with 5 warehouses and 10 products has two problems that look opposite but
share one root cause — poor visibility into inventory relative to actual demand: some
products are about to run out, while others have far more stock than anyone will sell
before it ties up cash for months. This capstone builds the full pipeline to see both
problems on one screen and know exactly what to do about each.

## The Pipeline

```
Power Query (clean 2 messy inventory exports)
        ↓
Power Pivot / SQL Server (star schema: sales velocity + inventory + supplier lead time)
        ↓
Power BI (live dashboard: stockout risk + overstock by warehouse)
```

## Files in This Project

| File | Layer | Purpose |
|---|---|---|
| `inventory_system1_lagos_ibadan.csv`, `inventory_system2_other_dcs.csv` | Power Query | Raw messy inventory exports from 2 different warehouse systems |
| `power_query_data_quality_log.txt` | Power Query | What was cleaned, merged, and — importantly — what had to be excluded |
| `Fact_Inventory_clean.csv`, `Fact_Sales.csv`, `Dim_*.csv` | Data model | The clean star schema (5 tables) |
| `01_schema.sql`, `02_analysis_queries.sql` | SQL | Database creation, load, and the 5 core reorder/stockout queries |
| `answer_key_output.txt` | Verification | Independently computed results to check your queries against |
| `chart1-2_*.png` | Output | Supporting visuals |
| `Supply_Chain_Recommendation_Report.docx` | Deliverable | The written findings + recommendations |

## Layer 1 — Power Query: Merge Two Inconsistent Inventory Systems

The two warehouses use different inventory systems, exporting in incompatible formats:

| | System 1 (Lagos, Ibadan) | System 2 (PH, Abuja, Kano) |
|---|---|---|
| Headers | `Warehouse ID`, `Product ID`, `Stock On Hand` | `site_id`, `item_name`, `qty_available` |
| Product reference | By ID | By name (needs a lookup to Product ID) |
| Date format | `YYYY-MM-DD` | `DD/MM/YYYY` |
| Data quality | Clean | 3 rows have missing stock values (sync glitch) |

**In Power BI/Excel Power Query:** load both as separate queries, rename System 2's
columns to match System 1's schema, use a Merge Query (against `Dim_Product`) to convert
System 2's product names into ProductIDs, standardize the date format, then `Append
Queries` to combine into one `Fact_Inventory` table. **Do not silently drop the 3 rows
with missing stock** — flag them (as `power_query_data_quality_log.txt` does) so whoever
owns those warehouses knows a manual stock count is needed. Silently dropping bad data is
a worse mistake than the bad data itself.

## Layer 2 — Power Pivot / SQL: The Reorder-Point Data Model

`01_schema.sql` builds a proper star schema in SQL Server: `Dim_Supplier` (with lead
times), `Dim_Product`, `Dim_Warehouse`, `Fact_Sales` (26 weeks of weekly demand),
`Fact_Inventory` (the cleaned snapshot from Layer 1).

The core insight this model is built to compute — **Days of Supply vs Supplier Lead
Time** — only works because the schema relates all four dimensions to both fact tables.
Run `02_analysis_queries.sql` for the actual business questions:
- **Q2:** Days of supply for every product/warehouse, flagged Stockout Risk / Healthy / Overstocked
- **Q3:** Just the stockout-risk items — what needs a purchase order today
- **Q4:** Just the overstocked items, ranked by capital tied up
- **Q5:** Fleet-wide: what % of total inventory value is excess

Compare your results against `answer_key_output.txt`. If you're using Power Pivot instead
of/alongside SQL, the equivalent DAX measure for Days of Supply is:
```dax
Days of Supply := DIVIDE([Current Stock], [Avg Daily Demand], 0)
Stock Status :=
VAR DoS = [Days of Supply]
VAR Lead = SELECTEDVALUE(Dim_Supplier[LeadTimeDays])
RETURN IF(DoS < Lead, "Stockout Risk", IF(DoS > Lead * 4, "Overstocked", "Healthy"))
```

## Layer 3 — Power BI: The Live Dashboard

Connect to the `SupplyChainAnalytics` SQL Server database (same pattern as Capstone 1).
Build:
- KPI cards: Total Inventory Value, Overstock Value, Overstock %, Count of Stockout-Risk Items
- **Table with conditional formatting:** every product/warehouse combo, colored by
  StockStatus (red/green/orange) — the single visual a warehouse manager actually uses
- Bar chart: Top overstocked items by capital tied up
- Slicers: Warehouse, Category

## What the Data Actually Shows

- **63.1% of total inventory value (NGN 61.4M of NGN 97.4M) is overstock** — a striking
  number for a written recommendation to open with.
- **Shock Absorbers are overstocked at all 5 warehouses simultaneously** — that pattern
  only becomes visible once the data is combined across warehouses; from any single
  warehouse's perspective it just looks like "a bit of extra stock."
- **14 product/warehouse pairs are at real stockout risk**, concentrated in products with
  long supplier lead times (Radiator Coolant, Timing Belt at 28 days) and thin buffers.

## How to Build Your Own Version

Any inventory-vs-demand problem fits: a pharmacy chain (stock vs prescription demand), a
restaurant supply chain (ingredient stock vs usage rate), or spare-parts inventory for
your own automotive/fleet background. The reusable pattern is always: clean multi-source
inventory data → relate it to demand and supplier lead time in a proper data model →
compute a days-of-supply-vs-lead-time flag → surface it as an actionable, color-coded list.

## What to Say About This in an Interview

"I combined inventory data from two incompatible warehouse systems, built a SQL Server
data model relating stock levels to sales velocity and supplier lead times, and found that
63% of inventory value was overstock concentrated in one product across every warehouse —
a policy-level fix, not a per-warehouse one — while flagging 14 items at genuine stockout
risk that needed purchase orders immediately."
