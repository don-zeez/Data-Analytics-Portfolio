# Project 5: E-Commerce Customer & Order Analysis (SQL)

**Tool:** SQL Server / T-SQL (in SSMS — the same environment you already set up)
**Tool category in portfolio:** Single-tool mastery (Phase 1 of 7)

## The Business Problem

An e-commerce store has 150 customers, 18 products across 5 categories, and 467 orders
over 12 months. Leadership wants real answers, not a gut feeling: **Who are our best
customers? What % of buyers actually come back? Is revenue growing? Which customers went
quiet and need a win-back email before we lose them for good?**

This is the single most common SQL interview scenario for a data analyst role — a
relational schema plus a handful of business questions that only SQL (not a spreadsheet)
can answer cleanly at scale.

## Files in This Project

| File | Purpose |
|---|---|
| `01_schema_and_load.sql` | Creates the database, 4 tables with proper foreign keys, loads all 1,827 rows |
| `02_business_queries.sql` | 6 business-question queries, each with a comment explaining what it answers |
| `answer_key_output.txt` | Expected results, computed independently in Python — use this to verify your SSMS output |
| `customers.csv`, `products.csv`, `orders.csv`, `order_items.csv` | Same data, portable format |

## The Schema

```
Customers ──< Orders ──< OrderItems >── Products
```

- **Customers**: CustomerID, FirstName, LastName, Email, Region, SignupDate
- **Products**: ProductID, ProductName, Category, UnitPrice
- **Orders**: OrderID, CustomerID, OrderDate, Status (Completed/Cancelled)
- **OrderItems**: OrderItemID, OrderID, ProductID, Quantity, UnitPrice — this is the
  junction table that makes Orders-to-Products a proper many-to-many relationship

## Step-by-Step: Run This Yourself in SSMS

### 1. Run the schema + load script
Open `01_schema_and_load.sql` in SSMS (connected to your `localhost` instance from
earlier) → `Execute`. This creates the `EcommerceAnalytics` database, 4 tables with
foreign key constraints, and loads all rows. Should complete in a few seconds.

**Verify it worked:** expand `Databases` → `EcommerceAnalytics` → `Tables` in Object
Explorer. You should see all 4 tables. Right-click `Orders` → `Select Top 1000 Rows` to
confirm data loaded.

### 2. Run the business queries one at a time
Open `02_business_queries.sql`. Run each query separately (highlight it, then `Execute`
or F5) so you can inspect each result set before moving to the next. Each has a comment
explaining the business question it answers.

### 3. Compare against the answer key
Open `answer_key_output.txt`. Your SSMS results should match these numbers exactly:

- **Repeat purchase rate: 68.3%** (86 of 126 customers who ordered came back for more)
- **Revenue roughly doubled** from NGN 2.0M (Sept 2024) to NGN 4.0M (July 2025)
- **Electronics is the top category** at NGN 10.86M, more than 3x Beauty (the lowest)
- **58 customers have churned** (no order in 90+ days from the dataset's most recent order)
- Notably: **Kelechi Chukwu and Yusuf Nwosu appear in both the Top 10 revenue list AND
  the churned list** — these are exactly the customers worth a personal win-back call,
  not a generic email. That's the kind of insight a good SQL analysis surfaces that a
  dashboard alone wouldn't flag.

## Key Techniques Demonstrated

- Proper relational schema design with `PRIMARY KEY` / `FOREIGN KEY` constraints
- Multi-table `JOIN`s (3-table joins for revenue calculations)
- Aggregate functions (`SUM`, `COUNT`, `COUNT(DISTINCT ...)`) with `GROUP BY`
- `CTE`s (Common Table Expressions) for readable multi-step logic (Q2, Q5)
- `CASE WHEN` inside an aggregate for conditional counting
- `LEFT JOIN ... WHERE ... IS NULL` — the standard pattern for "find records with no match"
- Computing a reference date **from the data itself** (`MAX(OrderDate)`) instead of
  `GETDATE()`, so results are reproducible no matter when you run the query — a subtlety
  that matters a lot in real production analysis

## How to Build Your Own Version

Same schema shape works for almost any transactional business: a SaaS product (Users,
Subscriptions, Invoices), a fleet operator (Vehicles, Trips, MaintenanceRecords — a
natural extension of your GPC Energy background), or a school (Students, Enrollments,
Courses). The reusable pattern is always: one core entity table, a transaction table, a
junction table if there's a many-to-many relationship, then business-question queries
layered on top.

## What to Say About This in an Interview

"I built a normalized e-commerce schema in SQL Server and wrote queries to find our
repeat purchase rate, revenue trend, and — most usefully — customers who used to be
high-value but've gone quiet for 90+ days, so the business could prioritize win-back
outreach instead of guessing who to target."
