-- ============================================================
-- Capstone 2: Stockout Risk, Overstock, and Reorder Analysis
-- Run 01_schema.sql first.
-- ============================================================
USE SupplyChainAnalytics;
GO

-- ------------------------------------------------------------
-- Q1: Average weekly demand per product/warehouse (last 26 weeks)
-- Foundation for every other query below.
-- ------------------------------------------------------------
WITH AvgDemand AS (
    SELECT WarehouseID, ProductID, AVG(CAST(UnitsSold AS DECIMAL(10,2))) AS AvgWeeklyDemand
    FROM dbo.Fact_Sales
    GROUP BY WarehouseID, ProductID
)
SELECT * FROM AvgDemand ORDER BY WarehouseID, ProductID;
GO

-- ------------------------------------------------------------
-- Q2: Days of Supply per product/warehouse, with supplier lead time joined in
-- Business question: "How many days until we run out, and is that longer or
-- shorter than it takes to get more stock?"
-- ------------------------------------------------------------
WITH AvgDemand AS (
    SELECT WarehouseID, ProductID, AVG(CAST(UnitsSold AS DECIMAL(10,2))) / 7.0 AS AvgDailyDemand
    FROM dbo.Fact_Sales
    GROUP BY WarehouseID, ProductID
)
SELECT
    w.WarehouseName,
    p.ProductName,
    p.Category,
    i.CurrentStock,
    ROUND(d.AvgDailyDemand, 2) AS AvgDailyDemand,
    s.SupplierName,
    s.LeadTimeDays,
    CASE WHEN d.AvgDailyDemand > 0
         THEN ROUND(i.CurrentStock / d.AvgDailyDemand, 1)
         ELSE NULL END AS DaysOfSupply,
    CASE
        WHEN d.AvgDailyDemand = 0 THEN 'No Recent Demand'
        WHEN (i.CurrentStock / d.AvgDailyDemand) < s.LeadTimeDays THEN 'STOCKOUT RISK'
        WHEN (i.CurrentStock / d.AvgDailyDemand) > s.LeadTimeDays * 4 THEN 'OVERSTOCKED'
        ELSE 'Healthy'
    END AS StockStatus
FROM dbo.Fact_Inventory i
JOIN dbo.Dim_Warehouse w ON w.WarehouseID = i.WarehouseID
JOIN dbo.Dim_Product p   ON p.ProductID = i.ProductID
JOIN dbo.Dim_Supplier s  ON s.SupplierID = p.SupplierID
JOIN AvgDemand d         ON d.WarehouseID = i.WarehouseID AND d.ProductID = i.ProductID
ORDER BY DaysOfSupply ASC;
GO

-- ------------------------------------------------------------
-- Q3: Stockout-risk products — days of supply less than the supplier's lead time
-- Business question: "What needs a purchase order TODAY?"
-- ------------------------------------------------------------
WITH AvgDemand AS (
    SELECT WarehouseID, ProductID, AVG(CAST(UnitsSold AS DECIMAL(10,2))) / 7.0 AS AvgDailyDemand
    FROM dbo.Fact_Sales
    GROUP BY WarehouseID, ProductID
)
SELECT
    w.WarehouseName, p.ProductName, i.CurrentStock,
    ROUND(i.CurrentStock / d.AvgDailyDemand, 1) AS DaysOfSupply,
    s.LeadTimeDays,
    s.SupplierName
FROM dbo.Fact_Inventory i
JOIN dbo.Dim_Warehouse w ON w.WarehouseID = i.WarehouseID
JOIN dbo.Dim_Product p   ON p.ProductID = i.ProductID
JOIN dbo.Dim_Supplier s  ON s.SupplierID = p.SupplierID
JOIN AvgDemand d         ON d.WarehouseID = i.WarehouseID AND d.ProductID = i.ProductID
WHERE d.AvgDailyDemand > 0 AND (i.CurrentStock / d.AvgDailyDemand) < s.LeadTimeDays
ORDER BY DaysOfSupply ASC;
GO

-- ------------------------------------------------------------
-- Q4: Overstocked products — capital tied up in excess inventory
-- Business question: "Where is cash sitting on a shelf instead of in the bank?"
-- ------------------------------------------------------------
WITH AvgDemand AS (
    SELECT WarehouseID, ProductID, AVG(CAST(UnitsSold AS DECIMAL(10,2))) / 7.0 AS AvgDailyDemand
    FROM dbo.Fact_Sales
    GROUP BY WarehouseID, ProductID
)
SELECT
    w.WarehouseName, p.ProductName,
    i.CurrentStock,
    ROUND(i.CurrentStock / NULLIF(d.AvgDailyDemand, 0), 1) AS DaysOfSupply,
    p.UnitCostNGN,
    i.CurrentStock * p.UnitCostNGN AS CapitalTiedUpNGN
FROM dbo.Fact_Inventory i
JOIN dbo.Dim_Warehouse w ON w.WarehouseID = i.WarehouseID
JOIN dbo.Dim_Product p   ON p.ProductID = i.ProductID
JOIN dbo.Dim_Supplier s  ON s.SupplierID = p.SupplierID
JOIN AvgDemand d         ON d.WarehouseID = i.WarehouseID AND d.ProductID = i.ProductID
WHERE d.AvgDailyDemand > 0 AND (i.CurrentStock / d.AvgDailyDemand) > s.LeadTimeDays * 4
ORDER BY CapitalTiedUpNGN DESC;
GO

-- ------------------------------------------------------------
-- Q5: Fleet-wide capital tied up in overstock vs total inventory value
-- Business question: "What % of our inventory investment is actually excess?"
-- ------------------------------------------------------------
WITH AvgDemand AS (
    SELECT WarehouseID, ProductID, AVG(CAST(UnitsSold AS DECIMAL(10,2))) / 7.0 AS AvgDailyDemand
    FROM dbo.Fact_Sales
    GROUP BY WarehouseID, ProductID
),
Valued AS (
    SELECT
        i.CurrentStock * p.UnitCostNGN AS InventoryValue,
        CASE WHEN d.AvgDailyDemand > 0 AND (i.CurrentStock / d.AvgDailyDemand) > s.LeadTimeDays * 4
             THEN i.CurrentStock * p.UnitCostNGN ELSE 0 END AS OverstockValue
    FROM dbo.Fact_Inventory i
    JOIN dbo.Dim_Product p  ON p.ProductID = i.ProductID
    JOIN dbo.Dim_Supplier s ON s.SupplierID = p.SupplierID
    JOIN AvgDemand d        ON d.WarehouseID = i.WarehouseID AND d.ProductID = i.ProductID
)
SELECT
    SUM(InventoryValue) AS TotalInventoryValueNGN,
    SUM(OverstockValue) AS OverstockValueNGN,
    CAST(SUM(OverstockValue) AS DECIMAL(10,4)) / SUM(InventoryValue) AS OverstockPct
FROM Valued;
GO
