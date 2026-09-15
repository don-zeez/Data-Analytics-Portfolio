# Project 6: Fleet Operations Data Cleaning & EDA (Python)

**Tool:** Python — `pandas`, `numpy`, `matplotlib`
**Tool category in portfolio:** Single-tool mastery (Phase 1 of 7)

## The Business Problem

A 25-vehicle fleet generates 965 raw trip logs over 6 months, exported straight from the
telematics system — meaning it's full of the exact junk real sensor/logging data always has:
mixed date formats, inconsistent vehicle-type casing, missing fuel readings, sensor error
codes disguised as real values, negative downtime (a physical impossibility, so clearly a
data entry bug), and duplicate rows. Nobody can answer **"where is fuel and time being
wasted?"** until this is cleaned — and at 965 rows, this is past the point where Excel
formulas stay maintainable. This is exactly why Python exists in an analyst's toolkit.

## Files in This Project

| File | Purpose |
|---|---|
| `analysis.py` | The full pipeline: clean → EDA → 4 charts, fully commented |
| `fleet_logs_raw.csv` | Raw messy data (your practice input, if you want to run this yourself) |
| `fleet_logs_clean.csv` | Output after cleaning |
| `data_quality_log.txt` | Every fix made, and why (same audit-trail principle as Project 2) |
| `chart1-4_*.png` | The 4 visualizations produced by the script |

## Step-by-Step: What the Script Does, and Why

### 1. Load
`pd.read_csv()` — straightforward, but this is the last "easy" step; everything after
this is dealing with the mess.

### 2. Clean — six distinct real-world problems, six distinct fixes
- **Duplicates:** `df.drop_duplicates()` — removed 15 exact-duplicate rows (a known export
  glitch pattern)
- **Inconsistent casing:** naively calling `.str.title()` on `"SUV"` produces `"Suv"` —
  title-case doesn't know SUV is an acronym. Fixed with an **explicit mapping** instead,
  which is the safer pattern whenever your categories include acronyms or abbreviations.
- **Mixed date formats:** some rows were `YYYY-MM-DD`, others `DD/MM/YYYY` in the same
  column. A single `pd.to_datetime()` call would silently misparse one of the two formats.
  Solved with a small function that tries both formats explicitly.
- **Missing values:** 59 rows had no `FuelUsedLiters` reading (sensor dropout). Rather than
  dropping those rows entirely (losing valid downtime/speed data) or guessing a fill value,
  they're excluded *only* from fuel-efficiency calculations — the row stays useful for
  everything else. This distinction — "missing for one metric" vs "missing entirely" — is a
  common real-world judgment call.
- **Sensor error codes:** `MaxSpeedKmh = 999` is a known telematics error code, not a real
  reading. Converted to `NaN` rather than treated as a genuine (impossible) speed.
- **Impossible negative values:** downtime hours can't be negative — these were data-entry
  sign errors, not fabricated records, so the fix is `.abs()`, not deletion.

Every fix is written to `data_quality_log.txt` — **an analysis with an invisible cleaning
step is not trustworthy**, and a hiring manager who sees a documented log knows you think
this way by default.

### 3. EDA — four real business questions
- Fuel efficiency by vehicle type (`groupby` + `.agg()`)
- Monthly downtime and maintenance cost trend
- Top drivers by overspeeding incidents (company policy: > 100 km/h)
- Correlation between downtime hours and maintenance cost

### 4. Visualize
Four matplotlib charts, each answering one of the EDA questions directly — a bar chart, a
trend line, a ranked horizontal bar, and a scatter plot with the correlation coefficient in
the title.

## What the Data Actually Shows

- **Sedans are 3.2x more fuel-efficient than trucks** (12.8 vs 4.0 km/L) — expected, but now
  quantified, which matters when deciding fleet composition for new routes.
- **Downtime and maintenance cost are almost perfectly correlated (r = 0.94)** — meaning
  downtime hours are a very reliable proxy for cost, so reducing downtime is close to a
  direct cost lever, not just an efficiency one.
- **A small group of drivers (DRV-02, 03, 04, 05) account for a disproportionate share of
  overspeeding incidents** — a targeted coaching conversation with 4 people, not a
  fleet-wide policy memo, is the higher-leverage fix.
- **Fleet-wide: 217,746 km covered, 1,471 downtime hours, NGN 36M in maintenance cost, 20%
  of trips involved overspeeding** — the kind of top-line numbers that open an exec summary.

## How to Build Your Own Version

Swap the domain, keep the pipeline: customer support ticket logs (response time, resolution
category), e-commerce return data, or warehouse inventory movement. The reusable skeleton is
always: load → document every cleaning decision → groupby-based EDA → 3-4 charts that each
answer one specific question, not a chart dump.

## What to Say About This in an Interview

"I built a Python pipeline that cleaned 965 raw fleet telematics logs — mixed date formats,
sensor error codes, data entry mistakes — with every fix logged for auditability, then found
that downtime and maintenance cost are almost perfectly correlated, and that overspeeding is
concentrated in a handful of drivers rather than spread evenly across the fleet, which
reframes the fix from a blanket policy to targeted coaching."
