// ============================================================
// Bulk-creates every measure from the DAX Dashboard Build Guide
// into the "_Measures" table, organized into Display Folders
// by theme. Safe to re-run: won't overwrite existing measure
// expressions, but WILL (re)apply the correct folder to them.
//
// NOTE: These formulas reference 'date table'[Date]. If your
// date table is named something else, find-and-replace
// 'date table' below before running.
// ============================================================

// name -> (expression, folder)
var measures = new Dictionary<string, (string expr, string folder)>()
{
    // ---- Revenue & Loads ----
    {"Total Revenue", ("SUM ( loads[revenue] )", "Revenue & Loads")},
    {"Total Loads", ("COUNTROWS ( loads )", "Revenue & Loads")},
    {"Avg Revenue per Load", ("DIVIDE ( [Total Revenue], [Total Loads] )", "Revenue & Loads")},
    {"Total Accessorial Charges", ("SUM ( loads[accessorial_charges] )", "Revenue & Loads")},
    {"Revenue PY", ("CALCULATE ( [Total Revenue], SAMEPERIODLASTYEAR ( 'date table'[Date] ) )", "Revenue & Loads")},
    {"Revenue YoY %", ("DIVIDE ( [Total Revenue] - [Revenue PY], [Revenue PY] )", "Revenue & Loads")},
    {"Revenue MTD", ("TOTALMTD ( [Total Revenue], 'date table'[Date] )", "Revenue & Loads")},
    {"Revenue Running Total", ("CALCULATE ( [Total Revenue], FILTER ( ALLSELECTED ( 'date table' ), 'date table'[Date] <= MAX ( 'date table'[Date] ) ) )", "Revenue & Loads")},

    // ---- Trips & Delivery Performance ----
    {"Total Trips", ("COUNTROWS ( trips )", "Trips & Delivery")},
    {"Total Miles", ("SUM ( trips[actual_distance_miles] )", "Trips & Delivery")},
    {"Avg Trip Distance", ("AVERAGE ( trips[actual_distance_miles] )", "Trips & Delivery")},
    {"Avg Trip Duration (hrs)", ("AVERAGE ( trips[actual_duration_hours] )", "Trips & Delivery")},
    {"Revenue per Mile", ("DIVIDE ( [Total Revenue], [Total Miles] )", "Trips & Delivery")},
    {"Total Idle Hours", ("SUM ( trips[idle_time_hours] )", "Trips & Delivery")},
    {"Idle Time %", ("DIVIDE ( [Total Idle Hours], SUM ( trips[actual_duration_hours] ) )", "Trips & Delivery")},
    {"On-Time Deliveries", ("CALCULATE ( COUNTROWS ( delivery_events ), delivery_events[on_time_flag] = TRUE () )", "Trips & Delivery")},
    {"On-Time Delivery Rate", ("DIVIDE ( [On-Time Deliveries], COUNTROWS ( delivery_events ) )", "Trips & Delivery")},
    {"Avg Detention Minutes", ("AVERAGE ( delivery_events[detention_minutes] )", "Trips & Delivery")},

    // ---- Fuel ----
    {"Total Fuel Cost", ("SUM ( fuel_purchases[total_cost] )", "Fuel")},
    {"Total Gallons Purchased", ("SUM ( fuel_purchases[gallons] )", "Fuel")},
    {"Avg Price per Gallon", ("AVERAGE ( fuel_purchases[price_per_gallon] )", "Fuel")},
    {"Avg MPG", ("AVERAGE ( trips[average_mpg] )", "Fuel")},
    {"Fuel Cost per Mile", ("DIVIDE ( [Total Fuel Cost], [Total Miles] )", "Fuel")},
    {"Fuel Cost % of Revenue", ("DIVIDE ( [Total Fuel Cost], [Total Revenue] )", "Fuel")},

    // ---- Maintenance & Fleet ----
    {"Total Maintenance Cost", ("SUM ( maintenance_records[total_cost] )", "Maintenance & Fleet")},
    {"Maintenance Events", ("COUNTROWS ( maintenance_records )", "Maintenance & Fleet")},
    {"Avg Cost per Maintenance Event", ("DIVIDE ( [Total Maintenance Cost], [Maintenance Events] )", "Maintenance & Fleet")},
    {"Total Downtime Hours", ("SUM ( maintenance_records[downtime_hours] )", "Maintenance & Fleet")},
    {"Maintenance Cost per Mile", ("DIVIDE ( [Total Maintenance Cost], [Total Miles] )", "Maintenance & Fleet")},
    {"Active Trucks", ("DISTINCTCOUNT ( trucks[truck_id] )", "Maintenance & Fleet")},
    {"Maintenance Cost per Truck", ("DIVIDE ( [Total Maintenance Cost], [Active Trucks] )", "Maintenance & Fleet")},
    {"Avg Utilization Rate", ("AVERAGE ( truck_utilization_metrics[utilization_rate] )", "Maintenance & Fleet")},

    // ---- Safety ----
    {"Total Incidents", ("COUNTROWS ( safety_incidents )", "Safety")},
    {"Preventable Incidents", ("CALCULATE ( COUNTROWS ( safety_incidents ), safety_incidents[preventable_flag] = TRUE () )", "Safety")},
    {"Preventable Incident Rate", ("DIVIDE ( [Preventable Incidents], [Total Incidents] )", "Safety")},
    {"At-Fault Incidents", ("CALCULATE ( COUNTROWS ( safety_incidents ), safety_incidents[at_fault_flag] = TRUE () )", "Safety")},
    {"Total Claim Amount", ("SUM ( safety_incidents[claim_amount] )", "Safety")},
    {"Incidents per 100k Miles", ("DIVIDE ( [Total Incidents], [Total Miles] / 100000 )", "Safety")},

    // ---- Drivers ----
    {"Avg Years Experience", ("AVERAGE ( drivers[years_experience] )", "Drivers")},
    {"Revenue per Driver", ("DIVIDE ( [Total Revenue], DISTINCTCOUNT ( trips[driver_id] ) )", "Drivers")},
    {"Drivers with Termination", ("CALCULATE ( DISTINCTCOUNT ( drivers[driver_id] ), NOT ISBLANK ( drivers[termination_date] ) )", "Drivers")},
    {"Driver Turnover Rate", ("DIVIDE ( [Drivers with Termination], DISTINCTCOUNT ( drivers[driver_id] ) )", "Drivers")},

    // ---- Profitability ----
    {"Total Operating Cost", ("[Total Fuel Cost] + [Total Maintenance Cost]", "Profitability")},
    {"Gross Margin", ("[Total Revenue] - [Total Operating Cost]", "Profitability")},
    {"Gross Margin %", ("DIVIDE ( [Gross Margin], [Total Revenue] )", "Profitability")},
};

var measuresTable = Model.Tables["_Measures"];
int created = 0;
int foldered = 0;

foreach (var kv in measures)
{
    string name = kv.Key;
    string expr = kv.Value.expr;
    string folder = kv.Value.folder;

    if (!measuresTable.Measures.Contains(name))
    {
        measuresTable.AddMeasure(name, expr);
        created++;
    }

    measuresTable.Measures[name].DisplayFolder = folder;
    foldered++;
}

Info(created + " new measures created. " + foldered + " measures now have their Display Folder set.");
