# Capstone 1: Fleet Operations Intelligence

**Tools (combined pipeline):** SQL Server → Python (pandas, scikit-learn) → Power BI
**Category:** Combined capstone (Phase 2 of 3)

## The Business Problem

A 25-vehicle fleet reacts to breakdowns instead of anticipating them — maintenance happens
after a vehicle is already off the road. This capstone builds the full pipeline a real
analytics team would use to flip that: **store the data properly, find the predictive
signal, and put it in front of decision-makers as a live dashboard.**

This is the first of 3 capstones that combine everything from Phase 1 into one realistic
end-to-end project — the kind of project that makes a hiring manager stop skimming and
start reading closely.

## The Pipeline

```
SQL Server (storage)  →  Python (feature engineering + predictive model)  →  Power BI (dashboard)
       ↓
01_schema.sql              predictive_analysis.py           Power BI build guide (below)
```

## Files in This Project

| File | Layer | Purpose |
|---|---|---|
| `01_schema.sql` | SQL | Creates `FleetOpsIntelligence` DB, 2 related tables, loads all data |
| `Dim_Vehicle.csv`, `Fact_VehicleMonthly.csv` | Data | Same data, portable format |
| `predictive_analysis.py` | Python | Feature engineering + logistic regression risk model |
| `vehicle_risk_scores.csv` | Output | Every vehicle's current downtime-risk score |
| `chart1-3_*.png` | Output | Supporting EDA visuals |
| `Fleet_Ops_Recommendation_Report.docx` | Deliverable | The written findings + recommendations — what you'd actually hand to leadership |

## Layer 1 — SQL: Store It Properly

Run `01_schema.sql` in SSMS. It creates two related tables: `Dim_Vehicle` (25 vehicles,
type, depot, purchase year) and `Fact_VehicleMonthly` (300 rows — one per vehicle per
month, with trip counts, distance, fuel, overspeeding incidents, downtime, and
maintenance cost). This is the system of record — the Python layer reads from here (or
from the identical CSV export, in this offline version).

## Layer 2 — Python: Find the Predictive Signal

Run `predictive_analysis.py`. This is the analytical core:

1. **Feature engineering:** vehicle age, overspeed rate (incidents ÷ trips), fuel
   efficiency — none of these exist in the raw table; they're derived.
2. **Target definition:** "will this vehicle have a high-downtime month **next** month?"
   — built by shifting each vehicle's downtime flag back one month, so the model is
   genuinely predicting forward, not describing the present.
3. **Model:** logistic regression, evaluated on a held-out test set via AUC-ROC.
4. **Result: AUC 0.64.** This is reported honestly, not inflated — 0.5 is random, 1.0 is
   perfect, and 0.64 means the model has found a real but moderate signal. **Vehicle age
   and overspeed rate are the two strongest predictors**, which matches what the EDA
   charts show independently — the model isn't inventing a pattern, it's confirming one
   visible in the raw data.
5. **Output:** every vehicle scored and ranked by predicted risk, saved to
   `vehicle_risk_scores.csv` — this feeds directly into the Power BI dashboard's risk table.

**Why report a "weak" 0.64 AUC instead of hiding it or tuning until it looks better?**
Because an honest, moderate model a stakeholder can trust is more valuable than an
inflated one that breaks in production — and being able to explain exactly what an AUC
means and why 0.64 is still useful is a stronger interview answer than pretending every
model is a home run.

## Layer 3 — Power BI: Build the Live Dashboard

Power BI Desktop → `Get Data` → `SQL Server` → server `localhost`, database
`FleetOpsIntelligence` → import `Dim_Vehicle` and `Fact_VehicleMonthly`. Also
`Get Data` → `Text/CSV` → import `vehicle_risk_scores.csv` (this one stays outside SQL
since it's a model output, refreshed each time you re-run the Python script).

**Relationships:** `Dim_Vehicle[VehicleID]` → `Fact_VehicleMonthly[VehicleID]` (1-to-many).
`vehicle_risk_scores` relates to `Dim_Vehicle[VehicleID]` too (1-to-1, since it's one row
per vehicle).

**DAX measures:**
```dax
Total Downtime Hours := SUM(Fact_VehicleMonthly[DowntimeHours])
Total Maintenance Cost := SUM(Fact_VehicleMonthly[MaintenanceCostNGN])
Avg Overspeed Rate := AVERAGE(Fact_VehicleMonthly[OverspeedingIncidents]) / AVERAGE(Fact_VehicleMonthly[TripCount])
```

**Visuals to build:**
- KPI cards: Total Downtime Hours, Total Maintenance Cost, Fleet Overspeed Rate
- Bar chart: Downtime by Vehicle Type
- Line chart: Monthly downtime trend
- **Table with conditional formatting:** `vehicle_risk_scores`, sorted by
  `DowntimeRiskScore` descending, with a color-scale background (red = high risk) — this
  is the single most useful visual in the whole dashboard, because it's the one a fleet
  manager acts on directly
- Slicers: Depot, VehicleType

**This is the payoff of the whole pipeline:** a fleet manager opens this dashboard Monday
morning, sees the risk table sorted red-to-green, and knows exactly which vehicles to
inspect first — without waiting for an analyst to run a report.

## The Written Recommendation

`Fleet_Ops_Recommendation_Report.docx` is the piece most portfolios skip, and it's the one
that makes a hiring manager believe you can operate at their level: it translates the
model into 4 concrete actions (which vehicles to inspect, a 6-year replacement trigger for
trucks, driver coaching for overspeeding, and a monthly model refresh plan) — the same
gap between "I built a model" and "I told leadership what to do about it" that separates a
junior analyst from someone ready for more responsibility.

## How to Build Your Own Version

Same pipeline shape for any "predict-then-act" problem: customer churn (SQL → Python
model → Power BI risk list → written retention plan) or equipment failure in any
industry with sensor/usage data. The reusable structure is: store properly → engineer
features → build an honestly-evaluated model → surface it as a ranked, actionable table
→ write down what to actually do about it.

## What to Say About This in an Interview

"I built a full pipeline from a SQL Server database through a Python predictive model to
a live Power BI dashboard, flagging which fleet vehicles were most likely to need
unplanned maintenance next month. I reported the model's AUC honestly at 0.64 rather than
overselling it, and translated the output into a written recommendation with specific
vehicles to inspect and a policy change — not just a chart."
