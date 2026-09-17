# Capstone 3: HR People Analytics

**Tools (combined pipeline):** SQL Server → Python (scipy, scikit-learn) → Power BI (with drill-through)
**Category:** Combined capstone (Phase 2 of 3, final)

## The Business Problem

389 employees, 33.2% overall attrition. Leadership has a gut feeling about *why* people
leave, but no statistically defensible answer — and separately, an unexamined question
about whether pay is equitable. This capstone answers both with actual significance
testing, not just percentages that might be noise, then builds a dashboard a department
head can click into for their own team's detail.

## The Pipeline

```
SQL Server (Employees table)
        ↓
Python — scipy (chi-square / t-tests for real significance) + scikit-learn (risk model)
        ↓
Power BI — department summary page  →  drill-through  →  employee detail page
```

## Files in This Project

| File | Layer | Purpose |
|---|---|---|
| `01_schema.sql` | SQL | Creates `PeopleAnalytics` DB, loads 389 employee records |
| `02_analysis_queries.sql` | SQL | 5 queries: department summary, employee drill-down, pay gap, overtime x WLB, promotion flight-risk |
| `employees.csv` | Data | Same data, portable format |
| `statistical_analysis.py` | Python | Significance testing + predictive risk model |
| `analysis_output.txt` | Output | Full console output — every test statistic and p-value |
| `employee_risk_scores.csv` | Output | Current employees ranked by predicted attrition risk |
| `chart1-3_*.png` | Output | Supporting visuals |
| `HR_People_Analytics_Report.docx` | Deliverable | Written findings + recommendations |

## Layer 1 — SQL: Store It, and Query for Drill-Through

Run `01_schema.sql`, then `02_analysis_queries.sql`. Q1 is the department-level summary
(the "top" page of the dashboard); Q2 is the same idea filtered to one department (the
"drill-through target" page) — in Power BI these become one summary visual and one
drill-through page instead of two separate queries, but writing them separately first in
SQL is how you confirm the logic is right before building the visual layer on top of it.

## Layer 2 — Python: Real Statistical Testing, Not Just Percentages

Run `statistical_analysis.py`. This is what separates this project from Project 3
(the single-tool PivotTable version): every claimed "driver" of attrition is backed by an
actual significance test, not just an eyeballed percentage difference.

**What's statistically significant (p < 0.05):**
- Job satisfaction (t-test, p=0.017)
- Distance from home (t-test, p=0.006)
- Lack of promotion among 3+ year tenured staff (chi-square, p=0.042)

**What's NOT significant on its own:**
- OverTime alone (chi-square, p=0.316) — but it still shows up as a real contributor in
  the multivariate predictive model. **This is a genuinely important distinction to be
  able to explain in an interview:** a bivariate test asks "does this one thing matter by
  itself?"; a multivariate model asks "does this matter once everything else is accounted
  for?" — they can disagree, and both answers are correct at what they're actually testing.

**Pay equity check:** a t-test per job role comparing average male vs female pay. 7 of 12
roles show a statistically significant gap — always in the same direction, which is the
strongest evidence in the whole analysis, because a real systemic issue produces a
consistent pattern; random noise wouldn't.

**Predictive model:** logistic regression, AUC 0.678, ranking job satisfaction, work-life
balance, and distance from home as the strongest predictors — reported honestly rather than
oversold, same principle as Capstone 1.

## Layer 3 — Power BI: Department Summary → Drill-Through to Employee Detail

Connect Power BI to the `PeopleAnalytics` SQL Server database.

**Page 1 — Department Summary:**
- Bar chart: Attrition Rate by Department
- KPI cards: Overall Attrition Rate, Avg Job Satisfaction, Avg Monthly Income
- Table: Pay gap by role (from Q3)

**Page 2 — Employee Detail (drill-through target):**
`Visualizations` pane on Page 2 → drag `Department` into the **Drill through** filters
box. Build a table of individual employees (JobRole, YearsAtCompany, OverTime,
JobSatisfaction, Attrition) on this page.

**Wire it up:** right-click any department bar on Page 1 → `Drill through` → jumps to
Page 2, automatically filtered to that department. This is the dashboard feature that
turns "here's a chart" into "here's a tool a department head actually uses" — they click
their own department and see their own people, without an analyst running a custom query
for them.

**DAX measures:**
```dax
Attrition Rate := DIVIDE(CALCULATE(COUNTROWS(Employees), Employees[Attrition]="Yes"), COUNTROWS(Employees))
Avg Job Satisfaction := AVERAGE(Employees[JobSatisfaction])
Pay Gap % := DIVIDE([Avg Male Income] - [Avg Female Income], [Avg Male Income])
```

## How to Build Your Own Version

Same drill-through pattern works for any hierarchical business question: regional sales
summary drilling into store detail, or a fleet-wide dashboard (tying back to your
background) drilling from depot-level summary into individual vehicle detail. The
statistical-testing layer generalizes too — any "is this really a driver, or just noise"
question benefits from a chi-square or t-test instead of an eyeballed percentage gap.

## What to Say About This in an Interview

"I ran statistical significance tests rather than just reporting percentages, which
mattered — overtime looked like it might not be a real driver on its own, but the pay
equity check showed a gap that was statistically significant in 7 of 12 roles, always in
the same direction, which is the kind of consistent pattern that's hard to explain away as
chance. I built the Power BI dashboard with a drill-through so any department head could
click into their own team's detail without needing me to run a custom report each time."
