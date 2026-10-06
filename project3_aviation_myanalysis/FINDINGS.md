# Flight On-Time Performance: My Findings

## Business problem
This analysis looks at about 13,000 flights across 8 routes (March 2023 to August 2024) to answer: which routes run late, what drives delays, and how well can delay minutes be predicted?

## Data cleaning
- **35 duplicate `flight_id` rows** removed (12,989 to 12,954 rows)
- **131 cancelled flights** excluded from on-time calculations, leaving **12,823 operated flights**
- **140 missing `actual_turnaround_min` values** left as they are, because that column is not used in the models

## Key findings

**1. Overall on-time performance is 90.3%**
A flight is on time if it is less than 15 minutes late.

**2. Route C is the worst, in both directions**
HUB-SPK-C (85.4%) and SPK-C-HUB (85.5%) are clearly below the other six routes (90.9% to 93.2%). The best route is HUB-SPK-D at 93.2%. Route C flights lose about 10.4 minutes on average, against 7.8 to 8.9 minutes on the other routes. In SQL, both route C directions fall in the slowest delay quartile. Month by month, route C's on-time performance was below the other routes in all 18 months, by about 6 percentage points on average.

**3. Weather and turnaround do not explain route C**
About 4% of flights on every route are weather-affected, and scheduled turnaround is about 37 minutes on every route. Because both directions are affected, the cause is probably tied to airport C, but this data cannot identify it.

**4. Weather is the biggest driver of delay**
The 525 weather-affected flights lose 22.8 minutes on average (8.3 otherwise). Only 40.4% of them are on time, against 92.4% of the rest.

**5. Predicting delayed or not (logistic regression)**
ROC-AUC is 0.65, so the model separates delayed from on-time flights only modestly. Odds ratios per one standard deviation: weather 1.79, scheduled turnaround 1.31, distance 0.87. Weather raises the odds of a delay the most, and longer scheduled turnaround is also linked to more delays.

**6. Predicting delay minutes**

| Model | MAE (minutes) | R² |
|---|--:|--:|
| Random Forest | 3.84 | 0.211 |
| Gradient Boosting | 3.85 | 0.209 |
| Ridge | 3.90 | 0.189 |
| Always predict the average | 4.04 | 0 |

The three models are close together and only about 5% better than the average guess, so these features explain only about a fifth of the variation in delay. In the Ridge model, a weather event adds about 3 minutes of delay, and each extra standard deviation of scheduled turnaround adds about 0.5 minutes.

**7. Unusual flights**
Isolation Forest flagged 255 flights (2%). The most extreme is FL-0006838 on HUB-SPK-B with a 137-minute delay.

**8. Excel, SQL and Python agree**
The de-duplicated SQL matches Python exactly. The Excel sheet and the raw SQL include the 35 duplicates, so their route on-time figures differ by up to 0.05 percentage points (for example 85.42% against 85.44% on HUB-SPK-C).

## What I'd recommend
1. Investigate route C on both directions, starting with ground handling and turnaround at airport C.
2. Plan for weather: on-time performance falls to about 40% when weather hits, so add buffer or ground resources on those days.
3. Do not rely on these three features alone for delay prediction. Add data such as airport congestion or aircraft rotation.

## Limitations
- The dataset is synthetic, so the findings demonstrate the method rather than a real airline.
- The weather flag is a simple yes or no, with no severity.
- The models explain only about 20% of delay variation, so predictions are rough.
- The cause of the route C problem cannot be identified from the columns available.

## Tools used
Python (pandas, scikit-learn: LogisticRegression, IsolationForest, RandomForest, GradientBoosting, Ridge; Seaborn), SQL (`CASE WHEN`, `LAG`, `NTILE`, `ROW_NUMBER`), and Excel (structured table, `COUNTIFS`, chart).
