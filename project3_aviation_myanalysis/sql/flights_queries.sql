-- Flight On-Time Performance: SQL queries (SQL Server / T-SQL)
-- Table: flights (one row per flight; 12,989 raw rows, 35 of them duplicates)
-- On-time = delay under 15 minutes, measured on flights that were not cancelled.

-- 1. Prove the duplicate-row problem exists
SELECT flight_id, COUNT(*) AS n
FROM flights
GROUP BY flight_id
HAVING COUNT(*) > 1;

-- 2. On-time % by route (CASE WHEN), on de-duplicated data
WITH numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY flight_id ORDER BY [date]) AS rn
    FROM flights
),
clean AS (
    SELECT * FROM numbered WHERE rn = 1
)
SELECT route,
       100.0 * SUM(CASE WHEN delay_minutes < 15 AND cancelled = 0 THEN 1 ELSE 0 END)
             / SUM(CASE WHEN cancelled = 0 THEN 1 ELSE 0 END) AS otp_pct
FROM clean
GROUP BY route
ORDER BY otp_pct;

-- 3. Monthly on-time % by route with month-over-month change (LAG window function)
WITH numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY flight_id ORDER BY [date]) AS rn
    FROM flights
),
clean AS (
    SELECT * FROM numbered WHERE rn = 1
),
monthly AS (
    SELECT route,
           CONVERT(char(7), [date], 120) AS [month],
           100.0 * SUM(CASE WHEN delay_minutes < 15 AND cancelled = 0 THEN 1 ELSE 0 END)
                 / SUM(CASE WHEN cancelled = 0 THEN 1 ELSE 0 END) AS otp_pct
    FROM clean
    GROUP BY route, CONVERT(char(7), [date], 120)
)
SELECT route, [month], otp_pct,
       otp_pct - LAG(otp_pct) OVER (PARTITION BY route ORDER BY [month]) AS mom_change
FROM monthly
ORDER BY route, [month];

-- 4. Rank routes into delay quartiles (NTILE): quartile 4 = slowest routes
WITH numbered AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY flight_id ORDER BY [date]) AS rn
    FROM flights
),
clean AS (
    SELECT * FROM numbered WHERE rn = 1
),
route_delay AS (
    SELECT route, AVG(delay_minutes) AS avg_delay
    FROM clean
    WHERE cancelled = 0
    GROUP BY route
)
SELECT route, avg_delay,
       NTILE(4) OVER (ORDER BY avg_delay) AS delay_quartile
FROM route_delay
ORDER BY avg_delay;