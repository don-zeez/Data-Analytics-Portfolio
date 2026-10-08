# Well Production Analytics: My Findings

## Business problem
This analysis looks at 2 years of daily production data (Jan 2023 to Dec 2024) across 18 wells in 3 fields, to answer: which wells are declining fastest, and where is downtime concentrated, and how much of it is unplanned?

## Data cleaning
The raw data had two known issues, confirmed independently in Excel, SQL and Python:
- **25 duplicate (date, well_id) rows**, all exact copies, removed in Python (11,413 to 11,388 rows). My SQL field totals are 0.16% to 0.20% higher than the Python results for this reason: SQL ran against the raw, not-yet-deduplicated table. The deduplicated SQL view matches Python exactly. It is a concrete example of why cleaning before analysing matters.
- **120 missing wellhead pressure readings**, left as they are because pressure was not used in this analysis

Other checks: every well has an unbroken daily record (no missing days between its first and last date), and downtime hours and downtime reasons agree row by row.

## Key findings

**1. Field production ranking**
Central Field produced the most oil (2,339,345 bbl in Python, 2,343,183 bbl in SQL before cleaning), narrowly ahead of North Field (2,302,404 / 2,307,038 bbl), only about 1.6% apart. South Field produced roughly half as much (1,147,794 / 1,149,962 bbl).

Fields have different numbers of wells: Central has 7, North has 6 and South has 5. Per well, North leads (383,734 bbl), ahead of Central (334,192) and South (229,559). So part of South's lower total is simply fewer wells.

All three fields rise steeply through early 2023 because wells came online on different dates between January and May, then peak in mid-2023 and decline steadily.

**2. Downtime hotspots**
WELL-012 has the most logged downtime (638 hours), followed by WELL-008 (544), WELL-007 (475), WELL-015 (463) and WELL-018 (459). Downtime is spread across several wells rather than concentrated in one outlier.

Not all of it is unplanned. Scheduled Maintenance and Workover are planned work and make up 22.6% of logged downtime hours (1,528 of 6,763). Excluding them, the top five are WELL-012 (531 hours), WELL-011 (410), WELL-008 (408), WELL-015 (399) and WELL-018 (392). WELL-007 drops to sixth (375).

**3. Fastest-declining wells (all 18 wells)**
Fitting a log-linear decline to every well (downtime days excluded, because oil output on those days is scaled down by the share of the day the well was offline), WELL-016 declines fastest at 0.217% per day, followed by WELL-001 (0.201%), WELL-007 (0.196%), WELL-014 (0.185%) and WELL-009 (0.183%). The fleet average is 0.154% per day, and the slowest wells are WELL-002 (0.109%), WELL-005 (0.111%) and WELL-003 (0.119%).

Both rod-pump wells (WELL-016 and WELL-007) are among the three fastest decliners, averaging 0.206% per day against 0.14 to 0.15% for ESP, gas lift and natural flow wells. With only two rod-pump wells this is a lead to investigate, not a conclusion.

**4. No reliable link between downtime and decline**
Across the 18 wells, downtime (as a share of recorded time) and decline rate show a weak negative relationship that is not statistically significant (Pearson r = -0.31, p = 0.21; Spearman rho = -0.24, p = 0.35). With 18 wells, this means the data gives no reliable evidence either way. It does not show that the two are unrelated.

Individual wells are still worth a look:
- **WELL-012 and WELL-008** have the most downtime but below-average decline (0.121% and 0.129% per day), which may point to equipment issues rather than reservoir depletion.
- **WELL-016 and WELL-001** decline fastest but have lower downtime (189 and 395 hours), which may point to natural decline.
- **WELL-007** has the third fastest decline and the third highest downtime, so it may have both problems.

**5. Pump failures are the biggest maintenance cost**
In the downtime-events table, pump failures account for 31 events costing $1,566,107, 25.3% of the $6,196,912 total, more than any other reason. Planned work (Scheduled Maintenance and Workover) accounts for another 22.6% of cost.

**6. Downtime is rare, lasts about 3 days, and rarely cascades (Markov chain)**
Treating each day's status as a state and counting day-to-day transitions across all wells (consecutive days only): a normal day is followed by another normal day 98.6% of the time, so about 1.4% of normal days start a downtime event. Every downtime reason has a 62% to 70% chance of continuing the next day, an average of 2.6 to 3.3 days, which matches the mean event duration in the events table (2.6 to 3.3 days). Only 4 of 490 downtime days switch straight to a different reason. The long-run share of normal days implied by the matrix (95.6%) matches the observed share (95.7%). WELL-012 and WELL-008 spend the largest share of days in downtime (6.8% and 6.6%). The reasons look almost identical in duration, which is typical of synthetic data.

## What I'd recommend
These are hypotheses to test, not proven causes:
1. **Send maintenance to inspect WELL-012 and WELL-008.** High downtime with below-average decline suggests a fixable mechanical issue.
2. **Evaluate WELL-016 and WELL-001 for a workover or artificial-lift upgrade.** Their decline is steep while downtime is lower, so more maintenance alone is unlikely to help.
3. **Look at WELL-007 for both,** and review rod-pump performance more broadly.

## Limitations
- The dataset is synthetic, so the findings demonstrate the method rather than a real field.
- A log-linear fit assumes exponential decline, which is a simplification of real reservoir behaviour.
- The downtime-versus-decline test uses only 18 wells and is not significant, and the rod-pump comparison uses 2.
- Downtime reasons suggest causes but do not prove them.
- The events table implies about 12,024 downtime hours (501 days x 24) against 6,763 logged in the production table. The two agree on days (501 vs 492), and the production table records an average of about 13.7 hours on a downtime day, so it logs partial-day outages.
- The Markov chain assumes tomorrow depends only on today's status.

## Tools used
Python (pandas, NumPy, SciPy, scikit-learn `LinearRegression`, Matplotlib, Markov chain transition matrices), SQL Server (duplicate check, deduplicated view with `ROW_NUMBER`, aggregation, window functions), and Excel (formula-based cross-check with `SUMIFS` and a chart).
