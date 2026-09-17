-- ============================================================
-- Capstone 3: HR People Analytics — Department & Employee Drill-Through Queries
-- Run 01_schema.sql first.
-- ============================================================
USE PeopleAnalytics;
GO

-- ------------------------------------------------------------
-- Q1: Department-level attrition summary (the "top" drill-through page)
-- ------------------------------------------------------------
SELECT
    Department,
    COUNT(*) AS Headcount,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Left_,
    CAST(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS DECIMAL(10,4)) / COUNT(*) AS AttritionRate,
    AVG(CAST(MonthlyIncomeNGN AS DECIMAL(10,2))) AS AvgMonthlyIncome
FROM dbo.Employees
GROUP BY Department
ORDER BY AttritionRate DESC;
GO

-- ------------------------------------------------------------
-- Q2: Employee-level detail for a given department (the "drill-through" target page)
-- In Power BI this becomes a drill-through page filtered by whichever department
-- the user clicks on the summary page.
-- ------------------------------------------------------------
SELECT EmployeeID, JobRole, Gender, Age, YearsAtCompany, OverTime,
       JobSatisfaction, WorkLifeBalance, PromotedLast3Years, Attrition
FROM dbo.Employees
WHERE Department = 'Finance'   -- swap this for any department when drilling through manually
ORDER BY Attrition DESC, YearsAtCompany ASC;
GO

-- ------------------------------------------------------------
-- Q3: Gender pay gap by job role (equal-pay check)
-- Business question: "Are men and women paid the same for the same role?"
-- ------------------------------------------------------------
SELECT
    JobRole,
    SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) AS MaleCount,
    AVG(CASE WHEN Gender = 'Male' THEN CAST(MonthlyIncomeNGN AS DECIMAL(10,2)) END) AS AvgMaleIncome,
    SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) AS FemaleCount,
    AVG(CASE WHEN Gender = 'Female' THEN CAST(MonthlyIncomeNGN AS DECIMAL(10,2)) END) AS AvgFemaleIncome,
    (AVG(CASE WHEN Gender = 'Male' THEN CAST(MonthlyIncomeNGN AS DECIMAL(10,2)) END)
     - AVG(CASE WHEN Gender = 'Female' THEN CAST(MonthlyIncomeNGN AS DECIMAL(10,2)) END))
     / AVG(CASE WHEN Gender = 'Male' THEN CAST(MonthlyIncomeNGN AS DECIMAL(10,2)) END) AS PayGapPct
FROM dbo.Employees
GROUP BY JobRole
ORDER BY PayGapPct DESC;
GO

-- ------------------------------------------------------------
-- Q4: Attrition rate by OverTime and WorkLifeBalance combined
-- Business question: "Is it overtime alone, or overtime + poor work-life balance together?"
-- ------------------------------------------------------------
SELECT
    OverTime,
    WorkLifeBalance,
    COUNT(*) AS Headcount,
    CAST(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS DECIMAL(10,4)) / COUNT(*) AS AttritionRate
FROM dbo.Employees
GROUP BY OverTime, WorkLifeBalance
ORDER BY AttritionRate DESC;
GO

-- ------------------------------------------------------------
-- Q5: "No promotion in 3+ years" flight-risk list among tenured employees
-- Business question: "Who's overdue for a promotion conversation before they leave?"
-- ------------------------------------------------------------
SELECT EmployeeID, Department, JobRole, YearsAtCompany, PerformanceRating, JobSatisfaction
FROM dbo.Employees
WHERE PromotedLast3Years = 'No' AND YearsAtCompany > 3 AND Attrition = 'No'
ORDER BY PerformanceRating DESC, YearsAtCompany DESC;
GO
