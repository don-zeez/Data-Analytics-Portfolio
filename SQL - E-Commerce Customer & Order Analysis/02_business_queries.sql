-- ============================================================
-- Project 5: E-Commerce Customer & Order Analysis
-- Business-Question Queries (SQL Server / T-SQL)
-- Run 01_schema_and_load.sql first.
-- ============================================================
USE EcommerceAnalytics;
GO

-- ------------------------------------------------------------
-- Q1: Top 10 customers by total revenue (Completed orders only)
-- Business question: "Who are our highest-value customers?"
-- ------------------------------------------------------------
SELECT TOP 10
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Region,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM dbo.Customers c
JOIN dbo.Orders o        ON o.CustomerID = c.CustomerID
JOIN dbo.OrderItems oi   ON oi.OrderID = o.OrderID
WHERE o.Status = 'Completed'
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Region
ORDER BY TotalRevenue DESC;
GO

-- ------------------------------------------------------------
-- Q2: Repeat purchase rate
-- Business question: "What % of customers who ordered at least once came back?"
-- ------------------------------------------------------------
WITH OrderCounts AS (
    SELECT CustomerID, COUNT(*) AS NumOrders
    FROM dbo.Orders
    WHERE Status = 'Completed'
    GROUP BY CustomerID
)
SELECT
    COUNT(*) AS CustomersWithOrders,
    SUM(CASE WHEN NumOrders >= 2 THEN 1 ELSE 0 END) AS RepeatCustomers,
    CAST(SUM(CASE WHEN NumOrders >= 2 THEN 1 ELSE 0 END) AS DECIMAL(10,4))
        / COUNT(*) AS RepeatPurchaseRate
FROM OrderCounts;
GO

-- ------------------------------------------------------------
-- Q3: Monthly revenue trend
-- Business question: "Is revenue growing month over month?"
-- ------------------------------------------------------------
SELECT
    FORMAT(o.OrderDate, 'yyyy-MM') AS OrderMonth,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    SUM(oi.Quantity * oi.UnitPrice) AS MonthlyRevenue
FROM dbo.Orders o
JOIN dbo.OrderItems oi ON oi.OrderID = o.OrderID
WHERE o.Status = 'Completed'
GROUP BY FORMAT(o.OrderDate, 'yyyy-MM')
ORDER BY OrderMonth;
GO

-- ------------------------------------------------------------
-- Q4: Revenue and margin-relevant performance by product category
-- Business question: "Which categories drive the most revenue?"
-- ------------------------------------------------------------
SELECT
    p.Category,
    COUNT(DISTINCT oi.OrderID) AS OrdersContaining,
    SUM(oi.Quantity) AS UnitsSold,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
FROM dbo.OrderItems oi
JOIN dbo.Products p ON p.ProductID = oi.ProductID
JOIN dbo.Orders o   ON o.OrderID = oi.OrderID
WHERE o.Status = 'Completed'
GROUP BY p.Category
ORDER BY TotalRevenue DESC;
GO

-- ------------------------------------------------------------
-- Q5: Churned customers (no completed order in the 90 days before
--     the most recent order date in the dataset)
-- Business question: "Who needs a win-back campaign?"
-- Note: uses MAX(OrderDate) from the data itself as the reference
-- point, not GETDATE() — so results are reproducible regardless of
-- when you actually run this query.
-- ------------------------------------------------------------
WITH RefDate AS (
    SELECT MAX(OrderDate) AS MostRecentOrderDate FROM dbo.Orders
),
LastOrderPerCustomer AS (
    SELECT CustomerID, MAX(OrderDate) AS LastOrderDate
    FROM dbo.Orders
    WHERE Status = 'Completed'
    GROUP BY CustomerID
)
SELECT
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Region,
    l.LastOrderDate,
    DATEDIFF(DAY, l.LastOrderDate, r.MostRecentOrderDate) AS DaysSinceLastOrder
FROM LastOrderPerCustomer l
JOIN dbo.Customers c ON c.CustomerID = l.CustomerID
CROSS JOIN RefDate r
WHERE DATEDIFF(DAY, l.LastOrderDate, r.MostRecentOrderDate) > 90
ORDER BY DaysSinceLastOrder DESC;
GO

-- ------------------------------------------------------------
-- Q6: Customers who signed up but NEVER ordered
-- Business question: "Who needs an onboarding nudge, not a win-back?"
-- ------------------------------------------------------------
SELECT c.CustomerID, c.FirstName + ' ' + c.LastName AS CustomerName, c.SignupDate
FROM dbo.Customers c
LEFT JOIN dbo.Orders o ON o.CustomerID = c.CustomerID
WHERE o.OrderID IS NULL;
GO
