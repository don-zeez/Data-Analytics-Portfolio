🚛 Fleet Analytics Dashboard

A 7-page, DAX-driven Power BI dashboard built on a 14-table logistics/fleet operations dataset (drivers, trucks, trailers, customers, facilities, routes, loads, trips, fuel purchases, maintenance records, delivery events, safety incidents, and monthly driver/truck metrics).

## 📊 Dashboard Preview

![Fleet Analytics Dashboard](Fleet_Analytics_Dashboard_Bold.png)

## 📥 Download

**[⬇️ Download the .pbix file](https://raw.githubusercontent.com/don-zeez/Data-Analytics-Portfolio/main/fleet-analytics-powerbi/FLEET%20ANALYTICS.pbix)** — open it in [Power BI Desktop](https://www.microsoft.com/en-us/power-platform/products/power-bi/downloads) (free) to explore the full interactive report.

> Note: GitHub can't render a live preview of `.pbix` files in the browser — that's a GitHub limitation, not an issue with the file. Download it and open it in Power BI Desktop to interact with it, or just browse the screenshot above for a quick look.

## 🗃️ Data source & scope

Practice/synthetic logistics operations data spanning **14 related tables** and **Jan 2022 – early 2025** (~85,400 loads and trips, ~196,000 fuel purchases, 120 trucks, 150 drivers). Built for a data analytics training exercise — not real company data.

## 🔍 Key findings

- **Revenue:** $262.5M total revenue across the period, with a 61% gross margin. Columbus is the top-performing origin city by revenue; the top 4 customers alone account for over $26M combined.
- **On-time delivery sits at 56%** — the clearest improvement opportunity surfaced by the dashboard, well below a typical 90%+ industry target.
- **Fuel is the single largest cost driver**, at 36% of total revenue ($95.6M). Average diesel price fell from ~$4.20/gal to ~$3.90/gal over the three years, which helped offset rising volumes.
- **Maintenance cost per mile is low ($0.05)** and the monthly maintenance cost trend declined gradually over the period, suggesting effective upkeep relative to fleet size (120 active trucks, 72.2K total downtime hours).
- **Safety incidents trended down**, from roughly 10/month early in the dataset to about 5/month by the end. 38% of the 170 total incidents were flagged preventable, and 54 were at-fault — together pointing to a specific driver-coaching opportunity.
- **Driver turnover is 17%**, with an average of 13.5 years of experience per driver and $2.1M in revenue generated per driver.

## 🗂️ What's inside

A custom **Date table** plus a dedicated **`_Measures`** table holding ~44 DAX measures, organized into display folders by theme:

- **Revenue & Loads** — Total Revenue, Revenue YoY %, Revenue Running Total, and more
- **Trips & Delivery** — Total Miles, On-Time Delivery Rate, Revenue per Mile
- **Fuel** — Total Fuel Cost, Avg MPG, Fuel Cost % of Revenue
- **Maintenance & Fleet** — Maintenance Cost per Mile, Truck Utilization Rate
- **Safety** — Preventable Incident Rate, Incidents per 100k Miles
- **Drivers** — Revenue per Driver, Driver Turnover Rate
- **Profitability** — Gross Margin, Gross Margin %

## 📑 Report pages

| Page | What it covers |
|---|---|
| **Executive Summary** | Top-line KPIs, revenue trend vs. prior year, operating cost trend, revenue by customer type |
| **Revenue & Customers** | Customer × year revenue matrix, revenue by route, revenue by load type over time |
| **Fleet & Maintenance** | Maintenance cost by truck make, cost trend, cost vs. truck age |
| **Driver Performance** | Driver leaderboard, on-time delivery rate, revenue per driver |
| **Fuel & Efficiency** | Fuel price trend, MPG by truck make, efficiency vs. trip distance |
| **Safety & Compliance** | Incidents by type and over time, preventable vs. non-preventable split |
| **Network Map** | Facility locations plotted geographically |

## 🛠️ Tools used

Power BI Desktop · DAX · Power Query (M) · Data modeling (star-schema-style relationships across 14 tables) · [Tabular Editor](https://tabulareditor.com/) (C# scripting for bulk DAX measure creation)

## 📁 Files in this folder

- `FLEET ANALYTICS.pbix` — the full Power BI project file
- `Fleet_Analytics_Dashboard_Bold.png` — static preview image of all 7 pages
- `create_all_measures.csx` — Tabular Editor C# script that bulk-creates and organizes all ~44 DAX measures into themed display folders
- `README.md` — this file

---
⬅️ [Back to main portfolio](https://github.com/don-zeez/Data-Analytics-Portfolio)
