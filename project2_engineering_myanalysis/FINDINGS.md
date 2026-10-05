# Manufacturing Quality Analytics — My Findings

## Business Problem
This analysis looks at production-run data across multiple lines and
machines to answer: which machines are statistically underperforming,
and what's actually causing defective batches?

## Data Cleaning
The raw data had two known issues, fixed in Power Query:
- Duplicate run_id rows, removed via Remove Duplicates
- ~150 missing vibration_mm_s sensor readings, filled using Fill Down
  (each blank filled with the nearest real reading above it — a
  reasonable choice for a continuous sensor stream, though a per-machine
  average would be a more refined alternative worth exploring later)

## Key Findings

**1. Plant-wide defect rate**
Overall defect rate across the whole plant: 1%.

**2. LINE-C is the worst-performing line**
LINE-C's defect rate (~0.55%) is clearly the highest of the four lines —
roughly double LINE-A, the best performer.

**3. The problem traces to one specific machine**
MC-007 has the highest defect rate of any individual machine — and it
belongs to LINE-C, meaning the line-level problem isn't spread across
multiple machines, it's concentrated in one.

**4. Temperature is the dominant driver (Key Influencers, no-code AI)**
Power BI's Key Influencers visual identified Sum of temperature_c as the
top factor: defective-batch likelihood increases sharply once
temperature exceeds ~193.74, with defect probability approaching 0.5 in
that highest bin — compared to a 0.13 average across all temperature
bins. Vibration, pressure, and cycle time are secondary factors, in that
order.

## What I'd Recommend
Prioritize a direct inspection of MC-007 on LINE-C for a temperature
control or cooling issue — this single machine is driving a
disproportionate share of the plant's defects, and the Key Influencers
result points specifically at excess heat as the mechanism, not a
general process problem across the whole line.

## Tools Used
Power BI Desktop only — Power Query for cleaning (Remove Duplicates,
Fill Down), one DAX measure for Defect Rate, drag-and-drop visuals
(Clustered Column Chart, Card), and the built-in Key Influencers visual
as a no-code substitute for a coded machine learning model.
