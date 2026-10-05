# Manufacturing Quality Analytics

A fully no-code manufacturing quality dashboard built entirely in Power
BI Desktop — Power Query for cleaning, one DAX measure, drag-and-drop
visuals, and the built-in Key Influencers visual standing in for a
coded machine learning model.

## Business Problem

Quality engineering needs to know: which lines/machines are
underperforming on defect rate, and what's actually driving defects —
not just which machine, but *why*.

## Data

Production-run level data across 4 lines and multiple machines —
process sensor readings (temperature, pressure, vibration, cycle time)
and a defective-batch flag per run.

## Methodology

1. **Power Query cleaning** — duplicate `run_id` rows removed via
   **Remove Duplicates**; ~150 missing `vibration_mm_s` readings filled
   via **Fill Down** (nearest prior real reading — a standard, simple
   approach for a continuous sensor stream).
2. **One DAX measure** — `Defect Rate = DIVIDE(SUM(defect_units),
   SUM(units_produced))`, since this ratio isn't a built-in aggregation.
3. **Drag-and-drop visuals** — a plant-wide KPI card, a defect-rate-by-
   line chart, and a defect-rate-by-machine chart, all built without
   typing a single additional formula.
4. **Key Influencers (no-code AI)** — Power BI's built-in visual
   analyzed which sensor readings are most associated with a defective
   batch, entirely through drag-and-drop field selection — no model
   training code written.

## Tech Stack

Power BI Desktop (Power Query, DAX, Key Influencers visual) — no Python,
no SQL, no external code for this project, by design.

## Key Findings

1. **Plant-wide defect rate: 1%**
2. **LINE-C is the worst-performing line** (~0.55% defect rate), roughly
   double the best-performing line.
3. **MC-007 (on LINE-C) is the single worst machine** — the line-level
   problem traces to one specific machine, not a spread-out issue.
4. **Temperature is the dominant driver**, per Key Influencers: defect
   probability jumps from a 0.13 average to nearly 0.5 once
   `temperature_c` exceeds ~193.74. Vibration, pressure, and cycle time
   are secondary factors.

## Recommendation

Prioritize a direct inspection of MC-007 for a temperature control or
cooling issue — the evidence points at a specific, fixable mechanical
cause rather than a plant-wide process problem.

Full write-up: [`FINDINGS.md`](FINDINGS.md)

## Repository Structure

```
project2_engineering_myanalysis/
├── README.md
├── FINDINGS.md
├── .gitignore
├── data/
│   ├── production_runs.csv
│   ├── machines_master.csv
│   └── downtime_events.csv
└── powerbi/
    └── Manufacturing_Quality_MYWORK.pbix
```

## How to Reproduce

Open `powerbi/Manufacturing_Quality_MYWORK.pbix` in Power BI Desktop —
all cleaning steps, the DAX measure, and every visual are saved inside
the file and will render immediately.
