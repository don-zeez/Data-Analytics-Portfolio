/* ============================================================================
   LOGISTICS FLEET ANALYTICS
   ----------------------------------------------------------------------------
   Author      : Akande Abdulazeez O.
   Project     : Data Analytics Capstone, TS Academy
   Database    : FleetAnalytics (SQL Server)
   Description : Answers the 8 analytical use cases in the project brief --
                 driver performance, route profitability, fleet utilisation,
                 maintenance, fuel efficiency, customer analysis, safety, and
                 seasonal patterns -- using the 14 imported source tables.

   How to use  : Open in SSMS, connect to FleetAnalytics, and run each section
                 top to bottom, or highlight a single query and press F5 to
                 run just that one.
   ============================================================================ */


/* ============================================================================
   SECTION 0 -- DATA INTEGRITY CHECK
   ----------------------------------------------------------------------------
   Confirms every table imported correctly before any analysis is trusted.
   Expected row counts are noted in the comment beside each line.
   ============================================================================ */

SELECT 'loads'                      AS table_name, COUNT(*) AS row_count FROM loads                      -- ~85,410
UNION ALL SELECT 'trips',                          COUNT(*) FROM trips                                   -- ~85,410
UNION ALL SELECT 'drivers',                        COUNT(*) FROM drivers                                 -- 150
UNION ALL SELECT 'trucks',                         COUNT(*) FROM trucks                                  -- 120
UNION ALL SELECT 'trailers',                       COUNT(*) FROM trailers                                -- 180
UNION ALL SELECT 'customers',                      COUNT(*) FROM customers                                -- 200
UNION ALL SELECT 'routes',                         COUNT(*) FROM routes                                   -- 58
UNION ALL SELECT 'facilities',                     COUNT(*) FROM facilities                                -- 50
UNION ALL SELECT 'fuel_purchases',                 COUNT(*) FROM fuel_purchases                           -- ~196,442
UNION ALL SELECT 'maintenance_records',            COUNT(*) FROM maintenance_records                      -- 2,920
UNION ALL SELECT 'delivery_events',                COUNT(*) FROM delivery_events                          -- ~170,820
UNION ALL SELECT 'safety_incidents',               COUNT(*) FROM safety_incidents                          -- 170
UNION ALL SELECT 'driver_monthly_metrics',         COUNT(*) FROM driver_monthly_metrics                    -- 4,464
UNION ALL SELECT 'truck_utilization_metrics',      COUNT(*) FROM truck_utilization_metrics;                -- 3,312


/* ============================================================================
   SECTION 1 -- HEADLINE KPIs
   ----------------------------------------------------------------------------
   The four top-line numbers every stakeholder asks for first: how much did
   we make, how many loads did we move, what did it cost to keep the fleet
   running, and how fuel-efficient is the fleet overall.
   ============================================================================ */

-- Total revenue across every load
SELECT SUM(revenue) AS total_revenue
FROM loads;

-- Total trips completed
SELECT COUNT(*) AS total_trips
FROM trips;

-- Total maintenance spend across the fleet
SELECT SUM(total_cost) AS total_maintenance_cost
FROM maintenance_records;

-- Fleet-wide average fuel economy
-- NOTE: uses AVG, not SUM -- average_mpg is a rate, not something to add up
SELECT AVG(average_mpg) AS avg_fleet_mpg
FROM trips;


/* ============================================================================
   SECTION 2 -- ROUTE PROFITABILITY
   ----------------------------------------------------------------------------
   Business question: which cities / lanes generate the most revenue, and
   where should pricing or capacity decisions be focused?
   ============================================================================ */

SELECT
    r.origin_city,
    COUNT(*)          AS total_loads,
    SUM(l.revenue)    AS total_revenue,
    AVG(l.revenue)    AS avg_revenue_per_load
FROM loads l
JOIN routes r ON l.route_id = r.route_id
GROUP BY r.origin_city
ORDER BY total_revenue DESC;


/* ============================================================================
   SECTION 3 -- FLEET UTILISATION & MAINTENANCE
   ----------------------------------------------------------------------------
   Business question: which truck brands are the most expensive to keep on
   the road, and how does that compare across the fleet?
   ============================================================================ */

SELECT
    t.make,
    COUNT(m.maintenance_id) AS maintenance_events,
    SUM(m.total_cost)       AS total_maintenance_cost,
    AVG(m.total_cost)       AS avg_cost_per_event
FROM maintenance_records m
JOIN trucks t ON m.truck_id = t.truck_id
GROUP BY t.make
ORDER BY total_maintenance_cost DESC;


/* ============================================================================
   SECTION 4 -- FUEL EFFICIENCY
   ----------------------------------------------------------------------------
   Business question: does truck brand meaningfully affect fuel economy?
   NOTE: uses AVG, not SUM, for the same reason as Section 1.
   ============================================================================ */

SELECT
    t.make,
    AVG(tr.average_mpg) AS avg_mpg,
    COUNT(*)             AS trips_recorded
FROM trips tr
JOIN trucks t ON tr.truck_id = t.truck_id
GROUP BY t.make
ORDER BY avg_mpg DESC;


/* ============================================================================
   SECTION 5 -- SAFETY METRICS
   ----------------------------------------------------------------------------
   Business question: what are the most frequent and most costly types of
   safety incident across the fleet?
   ============================================================================ */

SELECT
    incident_type,
    COUNT(*)             AS incident_count,
    SUM(claim_amount)    AS total_claim_cost,
    AVG(claim_amount)    AS avg_claim_cost
FROM safety_incidents
GROUP BY incident_type
ORDER BY incident_count DESC;


/* ============================================================================
   SECTION 6 -- DRIVER PERFORMANCE
   ----------------------------------------------------------------------------
   Business question: which drivers are running the most trips, and how does
   that compare across the workforce?
   ============================================================================ */

SELECT TOP 20
    d.first_name + ' ' + d.last_name AS driver_name,
    COUNT(*)                          AS trip_count,
    AVG(tr.average_mpg)                AS avg_mpg
FROM trips tr
JOIN drivers d ON tr.driver_id = d.driver_id
GROUP BY d.first_name, d.last_name
ORDER BY trip_count DESC;


/* ============================================================================
   SECTION 7 -- CUSTOMER ANALYSIS
   ----------------------------------------------------------------------------
   Business question: how much revenue comes from each type of customer
   relationship (Contract, Dedicated, Spot), and is one type more valuable
   than the others?
   ============================================================================ */

SELECT
    c.customer_type,
    COUNT(DISTINCT c.customer_id) AS num_customers,
    SUM(l.revenue)                  AS total_revenue,
    AVG(l.revenue)                  AS avg_revenue_per_load
FROM loads l
JOIN customers c ON l.customer_id = c.customer_id
GROUP BY c.customer_type
ORDER BY total_revenue DESC;


/* ============================================================================
   SECTION 8 -- SEASONAL PATTERNS
   ----------------------------------------------------------------------------
   Business question: does load volume or revenue shift meaningfully by
   month, indicating a seasonal pattern worth planning around?
   ============================================================================ */

SELECT
    FORMAT(load_date, 'yyyy-MM') AS month,
    COUNT(*)                      AS total_loads,
    SUM(revenue)                  AS total_revenue
FROM loads
GROUP BY FORMAT(load_date, 'yyyy-MM')
ORDER BY month;


/* ============================================================================
   KEY FINDINGS (fill in after running the queries above)
   ----------------------------------------------------------------------------
   1. Top revenue city:
   2. Most expensive truck brand to maintain:
   3. Fuel efficiency spread across brands:
   4. Most frequent safety incident type:
   5. Busiest driver by trip count:
   6. Most valuable customer type:
   7. Any seasonal pattern observed:
   ============================================================================ */