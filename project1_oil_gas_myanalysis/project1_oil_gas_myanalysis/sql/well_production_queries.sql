-- SQL Server (T-SQL) syntax. Tables: wells_production, downtime_events.
USE wells_db;
GO

-- 1. Prove the duplicate-row problem exists (expect 25 rows)
SELECT date, well_id, COUNT(*) AS n
FROM wells_production
GROUP BY date, well_id
HAVING COUNT(*) > 1;

-- 2. Field totals on the RAW table (what the original query returned).
--    These are 0.16% to 0.20% higher than Python and Excel because the duplicates are counted twice.
SELECT field_name, SUM(oil_bbl) AS total_oil_raw
FROM wells_production
GROUP BY field_name
ORDER BY total_oil_raw DESC;

-- 3. Deduplicated view. The 25 duplicates are exact copies, so keeping one row per (date, well_id) loses nothing.
GO
CREATE VIEW wells_production_clean AS
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY date, well_id ORDER BY (SELECT NULL)) AS rn
    FROM wells_production
)
SELECT date, well_id, field_id, field_name, oil_bbl, gas_mcf, water_bbl, water_cut_pct,
       choke_size_64th, wellhead_pressure_psi, downtime_hours, downtime_reason, artificial_lift
FROM ranked
WHERE rn = 1;
GO

-- 4. Field totals on the CLEAN view (matches Python and the Excel PivotTable), with well counts.
--    Fields have different numbers of wells, so oil per well is the fairer comparison.
SELECT field_name,
       COUNT(DISTINCT well_id)                         AS wells,
       SUM(oil_bbl)                                    AS total_oil,
       SUM(oil_bbl) / COUNT(DISTINCT well_id)          AS oil_per_well
FROM wells_production_clean
GROUP BY field_name
ORDER BY total_oil DESC;

-- 5. Which wells have the most downtime hours logged?
SELECT TOP 10 well_id, SUM(downtime_hours) AS total_downtime
FROM wells_production_clean
GROUP BY well_id
ORDER BY total_downtime DESC;

-- 6. Share of downtime hours that is planned work (Scheduled Maintenance and Workover)
SELECT 100.0 * SUM(CASE WHEN downtime_reason IN ('Scheduled Maintenance', 'Workover')
                        THEN downtime_hours ELSE 0 END) / SUM(downtime_hours) AS planned_pct
FROM wells_production_clean;

-- 7. Unplanned downtime hours by well (planned work excluded)
SELECT TOP 10 well_id, SUM(downtime_hours) AS unplanned_downtime
FROM wells_production_clean
WHERE downtime_reason IS NOT NULL
  AND downtime_reason NOT IN ('Scheduled Maintenance', 'Workover')
GROUP BY well_id
ORDER BY unplanned_downtime DESC;

-- 8. Maintenance cost by downtime reason
SELECT reason,
       COUNT(*)                                                     AS events,
       SUM(maintenance_cost_usd)                                    AS total_cost,
       ROUND(100.0 * SUM(maintenance_cost_usd)
             / SUM(SUM(maintenance_cost_usd)) OVER (), 1)           AS share_pct
FROM downtime_events
GROUP BY reason
ORDER BY total_cost DESC;