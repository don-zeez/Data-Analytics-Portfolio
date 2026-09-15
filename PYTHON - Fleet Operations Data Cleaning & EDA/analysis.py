"""
Project 6: Fleet Operations Data Cleaning & EDA (Python)
Business problem: reduce vehicle downtime and fuel waste across a 25-vehicle fleet.
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

pd.set_option("display.width", 120)
plt.rcParams["font.size"] = 10

# ============================================================
# STEP 1: LOAD
# ============================================================
df = pd.read_csv("fleet_logs_raw.csv")
print(f"Raw rows loaded: {len(df)}")

# ============================================================
# STEP 2: CLEAN
# ============================================================
log = []  # data-quality log, same spirit as the Power Query project

# --- 2a. Remove exact duplicate rows ---
before = len(df)
df = df.drop_duplicates()
log.append(f"Removed {before - len(df)} exact duplicate rows")

# --- 2b. Standardize VehicleType casing ---
# Note: .str.title() alone would turn "SUV" into "Suv" — it doesn't know SUV is an acronym.
# Map explicitly instead, keyed on the case-insensitive stripped value.
canonical_types = {"truck": "Truck", "van": "Van", "suv": "SUV", "sedan": "Sedan"}
df["VehicleType"] = df["VehicleType"].str.strip().str.lower().map(canonical_types)
log.append("Standardized VehicleType via explicit mapping (fixed 'truck'/'TRUCK' AND "
           "'suv'/'Suv' — a plain .title() call would have mangled 'SUV' into 'Suv')")

# --- 2c. Parse mixed date formats (ISO and DD/MM/YYYY both present) ---
def parse_mixed_date(s):
    for fmt in ("%Y-%m-%d", "%d/%m/%Y"):
        try:
            return pd.to_datetime(s, format=fmt)
        except (ValueError, TypeError):
            continue
    return pd.NaT

df["Date"] = df["Date"].apply(parse_mixed_date)
unparsed = df["Date"].isna().sum()
log.append(f"Parsed mixed date formats (ISO + DD/MM/YYYY); {unparsed} rows failed to parse")

# --- 2d. Handle missing FuelUsedLiters ---
df["FuelUsedLiters"] = pd.to_numeric(df["FuelUsedLiters"], errors="coerce")
missing_fuel = df["FuelUsedLiters"].isna().sum()
log.append(f"Found {missing_fuel} rows with missing FuelUsedLiters (sensor dropout) — "
           f"excluded from fuel-efficiency calculations, kept for all other metrics")

# --- 2e. Fix sensor error speed readings (999 = known error code, not a real speed) ---
sensor_errors = (df["MaxSpeedKmh"] == 999.0).sum()
df.loc[df["MaxSpeedKmh"] == 999.0, "MaxSpeedKmh"] = np.nan
log.append(f"Flagged {sensor_errors} rows where MaxSpeedKmh = 999 (known sensor error code) as missing")

# --- 2f. Fix negative downtime (data entry errors — downtime cannot be negative) ---
neg_downtime = (df["DowntimeHours"] < 0).sum()
df.loc[df["DowntimeHours"] < 0, "DowntimeHours"] = df.loc[df["DowntimeHours"] < 0, "DowntimeHours"].abs()
log.append(f"Corrected {neg_downtime} rows with negative DowntimeHours (data entry error, sign flipped) — "
           f"took absolute value rather than dropping, since the trip record itself is otherwise valid")

# --- 2g. Derived columns ---
df["FuelEfficiency_KmPerL"] = df["DistanceKM"] / df["FuelUsedLiters"]
df["Overspeeding"] = df["MaxSpeedKmh"] > 100  # company policy limit
df["Month"] = df["Date"].dt.to_period("M").astype(str)

print("\n--- DATA QUALITY LOG ---")
for line in log:
    print(" -", line)

with open("data_quality_log.txt", "w") as f:
    f.write("\n".join(log))

df.to_csv("fleet_logs_clean.csv", index=False)
print(f"\nClean rows retained: {len(df)}")
print(f"Rows usable for fuel-efficiency analysis: {df['FuelEfficiency_KmPerL'].notna().sum()}")

# ============================================================
# STEP 3: EDA
# ============================================================
print("\n" + "=" * 70)
print("EDA: FUEL EFFICIENCY BY VEHICLE TYPE (km/L)")
print("=" * 70)
eff_by_type = df.groupby("VehicleType")["FuelEfficiency_KmPerL"].agg(["mean", "median", "std", "count"]).round(2)
eff_by_type = eff_by_type.sort_values("mean", ascending=False)
print(eff_by_type)

print("\n" + "=" * 70)
print("EDA: MONTHLY DOWNTIME & MAINTENANCE COST TREND")
print("=" * 70)
monthly = df.groupby("Month").agg(
    TotalDowntimeHours=("DowntimeHours", "sum"),
    TotalMaintenanceCost=("MaintenanceCostNGN", "sum"),
    TripCount=("LogID", "count"),
).round(1)
print(monthly)

print("\n" + "=" * 70)
print("EDA: TOP 10 DRIVERS BY OVERSPEEDING INCIDENTS")
print("=" * 70)
speeding = df[df["Overspeeding"] == True].groupby("DriverID").size().sort_values(ascending=False).head(10)
print(speeding)

print("\n" + "=" * 70)
print("EDA: CORRELATION — DOWNTIME HOURS vs MAINTENANCE COST")
print("=" * 70)
corr = df[["DowntimeHours", "MaintenanceCostNGN"]].corr().iloc[0, 1]
print(f"Pearson correlation: {corr:.3f}")

print("\n" + "=" * 70)
print("EDA: FLEET-WIDE SUMMARY")
print("=" * 70)
print(f"Total distance covered: {df['DistanceKM'].sum():,.0f} km")
print(f"Total fuel used: {df['FuelUsedLiters'].sum():,.0f} L")
print(f"Total downtime: {df['DowntimeHours'].sum():,.0f} hours")
print(f"Total maintenance cost: NGN {df['MaintenanceCostNGN'].sum():,.0f}")
print(f"Overspeeding incident rate: {df['Overspeeding'].mean():.1%} of trips")

# ============================================================
# STEP 4: VISUALIZATIONS
# ============================================================

# Chart 1: Fuel efficiency by vehicle type
fig, ax = plt.subplots(figsize=(8, 5))
eff_by_type["mean"].plot(kind="bar", ax=ax, color="#1F4E78", edgecolor="white")
ax.set_title("Average Fuel Efficiency by Vehicle Type", fontsize=13, fontweight="bold")
ax.set_ylabel("km per Liter")
ax.set_xlabel("Vehicle Type")
plt.xticks(rotation=0)
plt.tight_layout()
plt.savefig("chart1_fuel_efficiency_by_type.png", dpi=150)
plt.close()

# Chart 2: Monthly downtime trend
fig, ax = plt.subplots(figsize=(9, 5))
monthly["TotalDowntimeHours"].plot(kind="line", marker="o", ax=ax, color="#C0392B", linewidth=2)
ax.set_title("Total Fleet Downtime by Month", fontsize=13, fontweight="bold")
ax.set_ylabel("Downtime Hours")
ax.set_xlabel("Month")
ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig("chart2_monthly_downtime_trend.png", dpi=150)
plt.close()

# Chart 3: Top drivers by overspeeding incidents
fig, ax = plt.subplots(figsize=(9, 5))
speeding.plot(kind="barh", ax=ax, color="#E67E22", edgecolor="white")
ax.set_title("Top 10 Drivers by Overspeeding Incidents", fontsize=13, fontweight="bold")
ax.set_xlabel("Number of Incidents (> 100 km/h)")
ax.invert_yaxis()
plt.tight_layout()
plt.savefig("chart3_overspeeding_by_driver.png", dpi=150)
plt.close()

# Chart 4: Downtime vs Maintenance cost scatter
fig, ax = plt.subplots(figsize=(8, 6))
ax.scatter(df["DowntimeHours"], df["MaintenanceCostNGN"], alpha=0.4, color="#1F4E78", s=25)
ax.set_title(f"Downtime vs Maintenance Cost (r = {corr:.2f})", fontsize=13, fontweight="bold")
ax.set_xlabel("Downtime Hours")
ax.set_ylabel("Maintenance Cost (NGN)")
ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig("chart4_downtime_vs_cost.png", dpi=150)
plt.close()

print("\n4 charts saved: chart1-4 .png")
