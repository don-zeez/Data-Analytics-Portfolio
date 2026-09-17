# Project 3: HR Attrition Analysis (PivotTable & PivotChart)

**Tool:** Excel PivotTable + PivotChart, with Slicers
**Tool category in portfolio:** Single-tool mastery (Phase 1 of 7)

## The Business Problem

196 employees across 6 departments. Company-wide attrition is running at ~36% — high enough
that leadership is asking: **"Where exactly is this coming from, and what's driving it?"**
Is it one department? Junior staff? People doing unpaid overtime? Poor performers, or
actually your good people leaving?

A flat spreadsheet can't answer that fast. A PivotTable can answer it in under 2 minutes,
interactively, for any manager who wants to slice it a different way.

## Files in This Project

| File | Purpose |
|---|---|
| `HR_Attrition_Workbook.xlsx` | Sheet 1: raw employee data (as a proper Excel Table). Sheet 2: an independently-calculated answer key |
| `hr_attrition_data.csv` | Same raw data, portable format |

**Why "Employee Data" is an Excel Table, not just a range:** PivotTables built on a Table
auto-expand when you add rows later — no "update data source range" maintenance step.

## Step-by-Step: Build the PivotTable & PivotChart Yourself

Open `HR_Attrition_Workbook.xlsx` in desktop Excel.

### 1. Insert the PivotTable
Click anywhere inside the `Employee Data` table → `Insert` → `PivotTable` → confirm it's
using the `EmployeeData` table as source → place it on a **new worksheet**.

### 2. Build "Attrition Rate by Department"
- Drag **Department** → `Rows`
- Drag **Attrition** → `Values` (it will default to `Count of Attrition`)
- Drag **Attrition** → `Values` **again** (yes, twice — this second copy becomes your %)
- On the second `Attrition` value field: click it → `Value Field Settings` →
  `Show Values As` → `% of Column Total`... actually for a Yes/No field, the cleaner method:
  right-click the pivot → filter the field, or better — drag **Attrition** to `Filters` and
  set it to **Yes only**, then your `Count of Attrition` in Values, divided into headcount,
  gives you the raw count of leavers per department. Compare this count against the
  **Headcount** column in the Answer Key sheet to compute the rate, or add a calculated
  field (`PivotTable Analyze` → `Fields, Items & Sets` → `Calculated Field`) named
  `Attrition Rate` = `Attrition_Count / Headcount_Count` — this is the professional way to
  do it and matches exactly what the Answer Key sheet computed with `COUNTIFS`.

### 3. Cross-check against the Answer Key
Compare your PivotTable's numbers against the `Answer Key` sheet's "Attrition Rate by
Department" table. If Sales isn't showing ~48.6%, something's off in your field setup —
debug it before moving on. **This cross-check habit is what separates analysts who trust
their own dashboards from ones who don't.**

### 4. Repeat for Tenure Band and OverTime
Same pattern, swapping `Rows` field:
- **Tenure Band** → Rows (this is why the helper column exists — pivoting raw decimal years
  directly would need manual "Group" ranges; the formula column does it cleanly)
- **OverTime** → Rows

You should see: attrition sharply higher in the `0-1 yrs` and `1-3 yrs` bands, and higher
among employees marked `OverTime = Yes`.

### 5. Add a PivotChart
Select your PivotTable → `PivotTable Analyze` → `PivotChart` → choose **Clustered Column**.
This chart updates live with any PivotTable field changes — that's the whole value of it
over a static chart.

### 6. Add Slicers for interactivity
`PivotTable Analyze` → `Insert Slicer` → check **Department**, **Gender**, **Salary Band**.
Now anyone opening this file can click a slicer button and instantly re-filter every
Pivot Table/Chart connected to it — this is what makes a workbook feel like a real tool
instead of a static report.

### 7. Cross-tab it (department × reason for leaving)
Build a second PivotTable: **Department** in Rows, **Reason for Leaving** in Columns,
**Count of Employee ID** in Values. This answers the *why*, not just the *where* — and is
usually the chart that gets the most attention in a real stakeholder meeting.

## Key Techniques Demonstrated

- Building a PivotTable from a structured Table (not a raw range)
- Calculated Fields for rate/percentage metrics, not just raw counts
- A helper column (`Tenure Band`) that turns a continuous variable into a clean pivot field
- PivotCharts linked live to PivotTable field changes
- Slicers for interactive, no-formula-required filtering
- Cross-tabulation (department × reason) to move from "where" to "why"

## How to Build Your Own Version

Same skeleton works for any categorical-driver analysis: customer churn by plan tier and
tenure, product returns by category and reason, or fleet vehicle downtime by depot and
maintenance type (a natural fit for your automotive background). The pattern is always:
one clean fact table → helper columns for anything continuous you need banded →
PivotTable → Calculated Field for rate → PivotChart → Slicers.

## What to Say About This in an Interview

"I built an interactive attrition dashboard using PivotTables and Slicers so any manager
could filter by department or tenure themselves, instead of requesting a custom report each
time — it surfaced that early-tenure employees doing overtime were leaving at nearly 3x the
rate of everyone else, which reframed the retention conversation entirely."
