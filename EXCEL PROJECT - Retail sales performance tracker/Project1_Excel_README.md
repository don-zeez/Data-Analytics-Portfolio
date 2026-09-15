# Project 1: Retail Sales Performance Tracker (Excel)

**Tool:** Microsoft Excel — formulas, conditional formatting, KPI dashboard, native charts
**Tool category in portfolio:** Single-tool mastery (Phase 1 of 7)

## The Business Problem

A retail chain with 6 stores across Nigeria has no fast way to answer the question every
regional manager asks every month: **"Which stores are hitting target, and by how much?"**
Sales data sits in raw transaction exports. Nobody wants to scroll 288 rows to find out.

This workbook turns that raw export into a live, self-updating performance tracker that
flags underperforming stores instantly — no manual recalculation needed when new data lands.

## What's Inside

| Sheet | Purpose |
|---|---|
| **Raw Data** | 288 rows of monthly sales by store, category, units, actual vs target (FY2025) |
| **Store Summary** | `SUMIFS`-driven aggregation by store, with variance $ / % and an `IF`-based status flag |
| **Dashboard** | 4 KPI cards + a bar chart, all formula-linked to Store Summary — nothing hardcoded |

**Every number on Dashboard and Store Summary is a live formula.** If you update Raw Data
(new month, corrected figure), everything downstream recalculates automatically. That's the
difference between a "report" and a "tool" — and it's the first thing a hiring manager checks
when they open your file.

## Key Techniques Demonstrated

- `SUMIFS` for multi-criteria aggregation instead of manual filtering
- `IFERROR` to guard against divide-by-zero
- `INDEX`/`MATCH` to dynamically find the top-performing store (avoids fragile `VLOOKUP`)
- Conditional formatting: a color scale on variance %, and rule-based fill on status text
- A dashboard built entirely from formula references — the visual layer never touches raw data directly
- Cell comments documenting what a formula means, for anyone auditing the sheet later

## Step-by-Step: How This Was Built (Recreate It Yourself)

1. **Define the business question first.** Before touching Excel: "Which stores beat target,
   and by how much?" Every formula in this workbook exists to answer that one question.
2. **Structure raw data as a proper table.** One row per transaction/record, consistent
   columns, no merged cells, no blank rows. This is what makes `SUMIFS` possible at all —
   messy raw data is the #1 reason Excel formulas break.
3. **Build the aggregation layer (Store Summary).**
   - `=SUMIFS(sales_range, store_range, criteria)` to total sales per store
   - Repeat for target
   - Variance = Actual − Target; Variance % = Variance / Target (wrapped in `IFERROR`)
   - `IF` formula to convert variance into a plain-English status
4. **Add conditional formatting** so the eye goes straight to the outliers — color scales for
   continuous values (variance %), fill rules for categorical flags (status).
5. **Build the Dashboard last, and only with formulas that point at Store Summary** — never
   re-type or hardcode a number that already exists elsewhere in the workbook.
6. **Add a chart** referencing the summary table so it updates automatically with the data.
7. **Stress-test it.** Change one number in Raw Data, confirm the Dashboard updates. If it
   doesn't, a formula is hardcoded somewhere — find it and fix it before calling it done.

## How to Build Your Own Version

Swap the domain: use call-center data (agent vs ticket-resolution target), a university
(department vs graduation-rate target), or your own GPC Energy fleet data (vehicle vs
downtime target). The structure is identical — one raw table, one `SUMIFS` aggregation layer,
one formula-only dashboard. That structure is the reusable skill, not the retail numbers.

## What to Say About This in an Interview

"I built a self-updating performance tracker so managers didn't have to manually recalculate
variance every month — every KPI on the dashboard is a live formula chained back to raw data,
so it stays accurate as new data comes in."
