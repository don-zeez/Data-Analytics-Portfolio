# 🚛 Fleet Analytics Dashboard

**A 7-page Power BI report that turns 3 years of trucking operations data into decisions on revenue, cost, drivers and safety.**

`Power BI` · `DAX` · `Data Modelling` · `KPI Design` · `Logistics`

![Fleet Analytics dashboard overview](Fleet_Analytics_Dashboard_Bold.png)

---

## 📌 At a glance

| 💰 Revenue | 📈 Gross margin | 🚚 Active trucks | ⏱️ On-time delivery | ⛽ Avg MPG |
|:---:|:---:|:---:|:---:|:---:|
| **262.53M** | **61%** | **120** | **56%** | **6.50** |

| ⛽ Fuel cost | 🔧 Maintenance cost | 🛑 Downtime | ⚠️ Incidents | 🧾 Claims |
|:---:|:---:|:---:|:---:|:---:|
| **95.59M** | **5.73M** | **72.2K hrs** | **170** | **2.65M** |

---

## 🎯 Business questions

1. How profitable is the fleet, and which customers, cities and load types drive revenue?
2. What do fuel and maintenance cost, and which truck makes are most expensive to run?
3. How do individual drivers perform on revenue and on-time delivery?
4. How many safety incidents happen, and how many were preventable?

---

## 💡 Key insights

- **On-time delivery is the biggest weakness.** Only **56%** of deliveries arrive on time, which makes it the clearest area for improvement.
- **Fuel is the largest cost.** Fuel is about **36% of revenue**, far above maintenance cost, so fuel price and MPG have the biggest effect on margin. The average price per gallon fell in steps from roughly $4.2 to about $3.7 over the period.
- **Maintenance cost varies by make.** Freightliner has the highest total maintenance cost and Kenworth the lowest.
- **Many incidents were avoidable.** About **38%** of the 170 incidents were flagged as preventable, and 54 were at-fault, so driver training is a practical way to cut claims.

---

## 🗂️ Report pages

| # | Page | What it answers |
|:---:|---|---|
| 1 | **Executive Summary** | Headline KPIs, monthly revenue vs prior year, fuel vs maintenance cost over time |
| 2 | **Revenue & Customers** | Revenue by customer and year, origin city and load type; revenue per mile |
| 3 | **Fleet & Maintenance** | Active trucks, maintenance cost by make and month, downtime hours |
| 4 | **Driver Performance** | Experience, revenue per driver, turnover rate, on-time delivery rate |
| 5 | **Fuel & Efficiency** | Fuel cost, price per gallon trend, MPG by make |
| 6 | **Safety & Compliance** | Incidents by type and month, preventable vs not, claim amounts |
| 7 | **Network Map** | Facility locations across North America |

---

## 🛠️ How it was built

- **Data model:** relational model with a dedicated **date table** and a **`_Measures` table** that holds all DAX measures
- **DAX:** 23 measures, including revenue vs prior year, gross margin %, on-time delivery rate, cost per mile, MPG, turnover rate and incident rates
- **Visuals:** KPI cards, line, bar and scatter charts, donut, gauge, matrix and map
- **Design:** custom dark theme for high contrast

<details>
<summary><b>See all 23 measures</b></summary>

| Area | Measures |
|---|---|
| Revenue | Total Revenue, Revenue PY, Revenue per Mile, Revenue per Driver, Gross Margin %, Total Trips, Total Miles |
| Fleet and maintenance | Active Trucks, Total Maintenance Cost, Maintenance Cost per Mile, Maintenance Cost per Truck, Total Downtime Hours |
| Fuel | Total Fuel Cost, Fuel Cost % of Revenue, Avg Price per Gallon, Avg MPG |
| Drivers | On-Time Delivery Rate, Avg Years Experience, Driver Turnover Rate |
| Safety | Total Incidents, At-Fault Incidents, Preventable Incident Rate, Total Claim Amount |

</details>

---

## 📊 Dataset

**Logistics Operations Database**: 14 related tables, about **550,000 rows**, covering **January 2022 to December 2024**.

👉 [Download the dataset here](https://drive.google.com/drive/folders/1Uk7U-DvssMWGyBxSaXHo-TqzanptUJZf?usp=drive_link)

The raw data is not stored in this repo because of its size (about 74 MB).

<details>
<summary><b>See the tables</b></summary>

| Table | Rows | Contents |
|---|--:|---|
| `fuel_purchases` | 196,442 | Fuel transactions, prices, locations |
| `delivery_events` | 170,820 | Pickup and delivery events, on-time flags |
| `loads` | 85,410 | Shipments, revenue, load type |
| `trips` | 85,410 | Distance, duration, fuel used, MPG |
| `driver_monthly_metrics` | 4,464 | Monthly driver performance |
| `truck_utilization_metrics` | 3,312 | Monthly truck miles, cost, downtime |
| `maintenance_records` | 2,920 | Service events and costs |
| `customers` | 200 | Accounts and contract types |
| `trailers` | 180 | Trailer inventory |
| `drivers` | 150 | Driver details and experience |
| `trucks` | 120 | Fleet equipment details |
| `routes` | 58 | Origin-destination pairs and rates |
| `facilities` | 50 | Terminals and warehouses with coordinates |
| `safety_incidents` | 170 | Incident type, fault, claim amount |

</details>

---

## 📁 Files in this folder

| File | Description |
|---|---|
| `FLEET_ANALYTICS.pbix` | The Power BI report (open with free Power BI Desktop) |
| `Fleet_Analytics_Dashboard_Bold.png` | Overview image of all 7 pages |

## ▶️ How to open

1. Download `FLEET_ANALYTICS.pbix` from this folder.
2. Open it in the free [Power BI Desktop](https://powerbi.microsoft.com/desktop/).
3. Use the page tabs at the bottom to move through the 7 pages.

---

## 👤 About me

Built by **Akande Abdulazeez Olanrewaju**, an automotive engineer moving into data analytics.

📍 Lagos, Nigeria · 🔗 [LinkedIn](https://www.linkedin.com/) · ✉️ abdazeez0607@gmail.com
