"""
Capstone 1: Fleet Operations Intelligence
Layer 2 — Python: feature engineering + predictive downtime-risk scoring.

In production this would connect directly to the SQL Server database via pyodbc/SQLAlchemy:

    import pyodbc, pandas as pd
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};SERVER=localhost;"
        "DATABASE=FleetOpsIntelligence;Trusted_Connection=yes;"
    )
    vehicles = pd.read_sql("SELECT * FROM dbo.Dim_Vehicle", conn)
    monthly  = pd.read_sql("SELECT * FROM dbo.Fact_VehicleMonthly", conn)

For this portfolio project, the CSVs (the exact same data that was loaded into SQL Server
via 01_schema.sql) are read directly, so the analysis logic below is identical either way.
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score, classification_report

pd.set_option("display.width", 120)

vehicles = pd.read_csv("Dim_Vehicle.csv")
monthly = pd.read_csv("Fact_VehicleMonthly.csv")

df = monthly.merge(vehicles, on="VehicleID")
df["VehicleAge"] = 2025 - df["PurchaseYear"]
df["OverspeedRate"] = df["OverspeedingIncidents"] / df["TripCount"]
df["FuelEfficiency"] = df["TotalDistanceKM"] / df["TotalFuelUsedL"]
df["Month_dt"] = pd.to_datetime(df["Month"])
df = df.sort_values(["VehicleID", "Month_dt"])

# ============================================================
# TARGET: will this vehicle have a high-downtime month NEXT month?
# "High downtime" = above the fleet's 75th percentile for that month.
# This is what a maintenance team actually wants to know in advance.
# ============================================================
threshold = df["DowntimeHours"].quantile(0.75)
df["HighDowntime"] = (df["DowntimeHours"] > threshold).astype(int)

# Shift the target back one month per vehicle so features from month N predict month N+1
df["NextMonthHighDowntime"] = df.groupby("VehicleID")["HighDowntime"].shift(-1)
model_df = df.dropna(subset=["NextMonthHighDowntime"]).copy()

features = ["VehicleAge", "OverspeedRate", "FuelEfficiency", "TripCount", "TotalDistanceKM"]
X = model_df[features]
y = model_df["NextMonthHighDowntime"].astype(int)

print(f"Training rows: {len(X)}  |  Positive rate (high-downtime next month): {y.mean():.1%}")

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)

model = LogisticRegression(max_iter=1000)
model.fit(X_train, y_train)

y_pred_proba = model.predict_proba(X_test)[:, 1]
auc = roc_auc_score(y_test, y_pred_proba)
print(f"\nModel AUC on held-out test set: {auc:.3f}")
print("\n(AUC of 0.5 = random guessing, 1.0 = perfect separation. "
      "Above ~0.7 means the model is finding a real, usable signal.)")

print("\nFeature coefficients (positive = raises downtime risk):")
for feat, coef in sorted(zip(features, model.coef_[0]), key=lambda x: -abs(x[1])):
    print(f"  {feat:<18} {coef:+.3f}")

# ============================================================
# Score every vehicle's most recent month to produce an actionable risk list
# ============================================================
latest = df.sort_values("Month_dt").groupby("VehicleID").tail(1).copy()
latest["DowntimeRiskScore"] = model.predict_proba(latest[features])[:, 1]
latest = latest.sort_values("DowntimeRiskScore", ascending=False)

risk_report = latest[["VehicleID", "VehicleType", "Depot", "VehicleAge", "OverspeedRate",
                       "FuelEfficiency", "DowntimeRiskScore"]].round(3)
risk_report.to_csv("vehicle_risk_scores.csv", index=False)

print("\n" + "=" * 70)
print("TOP 10 HIGHEST-RISK VEHICLES (predicted high downtime next month)")
print("=" * 70)
print(risk_report.head(10).to_string(index=False))

# ============================================================
# Supporting EDA + charts
# ============================================================
fig, ax = plt.subplots(figsize=(8, 5))
df.groupby("VehicleType")["DowntimeHours"].mean().sort_values(ascending=False).plot(
    kind="bar", ax=ax, color="#C0392B", edgecolor="white")
ax.set_title("Average Monthly Downtime by Vehicle Type", fontsize=13, fontweight="bold")
ax.set_ylabel("Downtime Hours"); ax.set_xlabel("Vehicle Type")
plt.xticks(rotation=0); plt.tight_layout()
plt.savefig("chart1_downtime_by_type.png", dpi=150); plt.close()

fig, ax = plt.subplots(figsize=(8, 6))
ax.scatter(df["VehicleAge"], df["DowntimeHours"], alpha=0.35, color="#1F4E78", s=25)
z = np.polyfit(df["VehicleAge"], df["DowntimeHours"], 1)
xs = np.linspace(df["VehicleAge"].min(), df["VehicleAge"].max(), 50)
ax.plot(xs, np.poly1d(z)(xs), color="#C0392B", linewidth=2, label="Trend")
ax.set_title("Vehicle Age vs Monthly Downtime", fontsize=13, fontweight="bold")
ax.set_xlabel("Vehicle Age (years)"); ax.set_ylabel("Downtime Hours"); ax.legend()
plt.tight_layout(); plt.savefig("chart2_age_vs_downtime.png", dpi=150); plt.close()

fig, ax = plt.subplots(figsize=(9, 5))
risk_report.head(10).set_index("VehicleID")["DowntimeRiskScore"].plot(
    kind="barh", ax=ax, color="#E67E22", edgecolor="white")
ax.set_title("Top 10 Vehicles by Predicted Downtime Risk (Next Month)", fontsize=13, fontweight="bold")
ax.set_xlabel("Predicted Probability of High Downtime")
ax.invert_yaxis(); plt.tight_layout()
plt.savefig("chart3_top10_risk_vehicles.png", dpi=150); plt.close()

print("\n3 charts saved. vehicle_risk_scores.csv saved (feeds the Power BI dashboard in Layer 3).")
