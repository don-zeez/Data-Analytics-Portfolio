FLEET ANALYTICS CAPSTONE PROJECT
=================================

Author:   Akande Abdulazeez O.
Program:  Data Analytics, TS Academy
Dataset:  Logistics fleet operations, 2022-2024 (14 related tables)


WHAT THIS PROJECT DOES
-----------------------
This project analyzes three years of trucking fleet data to answer key
business questions: which routes and customers are most profitable, how
efficient the fleet is on fuel and maintenance, how drivers are performing,
and where safety incidents are concentrated.



WHAT'S IN THIS FOLDER
-----------------------

1. Fleet_Analytics_Queries.sql
   The same analysis, written as SQL queries, with plain-English comments
   explaining what each query does and why. Includes written findings at
   the bottom of the file. Open in SQL Server Management Studio or any
   SQL editor.

2. CSV_Data (folder)
   The 14 original source files this analysis is built from: customers,
   drivers, trucks, trailers, routes, facilities, loads, trips,
   fuel_purchases, maintenance_records, delivery_events, safety_incidents,
   driver_monthly_metrics, and truck_utilization_metrics.


HOW TO VIEW EACH FILE
-----------------------
- .sql file   -> Open with SQL Server Management Studio, Azure Data Studio,
                 or any text editor to read the queries and comments
- .csv files  -> Open with Excel, or import into any database tool


A NOTE ON THE SQL FILE
-----------------------
The SQL script assumes the 14 CSV files have already been imported into a
SQL Server database named FleetAnalytics, with each CSV imported as a table
matching its filename (e.g. loads.csv -> a table called loads). This can be
done using SQL Server Management Studio's built-in Import Flat File wizard
(right-click the database -> Tasks -> Import Flat File) for each of the
14 files.


THANK YOU FOR REVIEWING THIS PROJECT.
