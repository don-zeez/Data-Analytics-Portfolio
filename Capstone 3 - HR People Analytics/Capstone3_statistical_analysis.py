"""
Capstone 3: HR People Analytics
Layer 2 — Python: statistical significance testing + predictive attrition risk scoring.

Connects conceptually to the same SQL Server database as 01_schema.sql (PeopleAnalytics);
this script reads the identical data from CSV for portability.
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import roc_auc_score

pd.set_option("display.width", 120)
df = pd.read_csv("employees.csv")
df["AttritionFlag"] = (df["Attrition"] == "Yes").astype(int)
df["OverTimeFlag"] = (df["OverTime"] == "Yes").astype(int)
df["PromotedFlag"] = (df["PromotedLast3Years"] == "Yes").astype(int)

print(f"Total employees: {len(df)}  |  Overall attrition rate: {df['AttritionFlag'].mean():.1%}\n")

# ============================================================
# PART 1: Statistical significance testing (not just descriptive %s)
# ============================================================
print("=" * 70)
print("PART 1: STATISTICAL SIGNIFICANCE OF ATTRITION DRIVERS")
print("=" * 70)

# --- Chi-square test: OverTime vs Attrition ---
ct = pd.crosstab(df["OverTime"], df["Attrition"])
chi2, p_ot, dof, expected = stats.chi2_contingency(ct)
print(f"\nOverTime vs Attrition (Chi-square test):")
print(ct)
print(f"chi2 = {chi2:.2f}, p-value = {p_ot:.5f}  "
      f"{'*** SIGNIFICANT (p<0.05)' if p_ot < 0.05 else 'not significant'}")

# --- Chi-square test: PromotedLast3Years vs Attrition (tenured employees only) ---
tenured = df[df["YearsAtCompany"] > 3]
ct2 = pd.crosstab(tenured["PromotedLast3Years"], tenured["Attrition"])
chi2b, p_promo, _, _ = stats.chi2_contingency(ct2)
print(f"\nPromotion (3+ yr tenure) vs Attrition (Chi-square test):")
print(ct2)
print(f"chi2 = {chi2b:.2f}, p-value = {p_promo:.5f}  "
      f"{'*** SIGNIFICANT (p<0.05)' if p_promo < 0.05 else 'not significant'}")

# --- t-test: JobSatisfaction, stayed vs left ---
left = df[df["Attrition"] == "Yes"]["JobSatisfaction"]
stayed = df[df["Attrition"] == "No"]["JobSatisfaction"]
t_stat, p_sat = stats.ttest_ind(left, stayed)
print(f"\nJob Satisfaction, Left (mean={left.mean():.2f}) vs Stayed (mean={stayed.mean():.2f}) — t-test:")
print(f"t = {t_stat:.2f}, p-value = {p_sat:.5f}  "
      f"{'*** SIGNIFICANT (p<0.05)' if p_sat < 0.05 else 'not significant'}")

# --- t-test: DistanceFromHome, stayed vs left ---
left_d = df[df["Attrition"] == "Yes"]["DistanceFromHomeKM"]
stayed_d = df[df["Attrition"] == "No"]["DistanceFromHomeKM"]
t_stat_d, p_dist = stats.ttest_ind(left_d, stayed_d)
print(f"\nDistance From Home, Left (mean={left_d.mean():.1f}km) vs Stayed (mean={stayed_d.mean():.1f}km) — t-test:")
print(f"t = {t_stat_d:.2f}, p-value = {p_dist:.5f}  "
      f"{'*** SIGNIFICANT (p<0.05)' if p_dist < 0.05 else 'not significant'}")

# ============================================================
# PART 2: Gender pay equity check
# ============================================================
print("\n" + "=" * 70)
print("PART 2: GENDER PAY EQUITY CHECK (t-test per role)")
print("=" * 70)
sig_gap_roles = []
for role in sorted(df["JobRole"].unique()):
    sub = df[df["JobRole"] == role]
    m = sub[sub["Gender"] == "Male"]["MonthlyIncomeNGN"]
    f = sub[sub["Gender"] == "Female"]["MonthlyIncomeNGN"]
    if len(m) < 3 or len(f) < 3:
        continue
    t, p = stats.ttest_ind(m, f)
    gap_pct = (m.mean() - f.mean()) / m.mean()
    flag = "*** SIGNIFICANT" if p < 0.05 else ""
    print(f"  {role:<20} M avg: {m.mean():>9,.0f}  F avg: {f.mean():>9,.0f}  "
          f"Gap: {gap_pct:>6.1%}  p={p:.4f}  {flag}")
    if p < 0.05:
        sig_gap_roles.append(role)

overall_gap = (df[df.Gender=="Male"]["MonthlyIncomeNGN"].mean() - df[df.Gender=="Female"]["MonthlyIncomeNGN"].mean()) / df[df.Gender=="Male"]["MonthlyIncomeNGN"].mean()
print(f"\nCompany-wide average pay gap (Male vs Female, all roles pooled): {overall_gap:.1%}")
print(f"Roles with a statistically significant gap (p<0.05): {len(sig_gap_roles)} of {df['JobRole'].nunique()}")

# ============================================================
# PART 3: Predictive attrition risk model
# ============================================================
print("\n" + "=" * 70)
print("PART 3: PREDICTIVE ATTRITION RISK MODEL")
print("=" * 70)

features = ["Age", "YearsAtCompany", "DistanceFromHomeKM", "JobSatisfaction",
            "WorkLifeBalance", "OverTimeFlag", "PerformanceRating", "PromotedFlag"]
X = df[features]
y = df["AttritionFlag"]

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.25, random_state=42, stratify=y)
model = LogisticRegression(max_iter=1000)
model.fit(X_train, y_train)
auc = roc_auc_score(y_test, model.predict_proba(X_test)[:, 1])
print(f"Model AUC on held-out test set: {auc:.3f}")

print("\nStandardized coefficients (larger magnitude = stronger predictor):")
for feat, coef in sorted(zip(features, model.coef_[0]), key=lambda x: -abs(x[1])):
    direction = "raises" if coef > 0 else "lowers"
    print(f"  {feat:<20} {coef:+.3f}  ({direction} attrition risk)")

# Score every current employee
df["AttritionRiskScore"] = model.predict_proba(X_scaled)[:, 1]
at_risk = df[df["Attrition"] == "No"].sort_values("AttritionRiskScore", ascending=False)
at_risk[["EmployeeID", "Department", "JobRole", "AttritionRiskScore"]].head(15).to_csv(
    "employee_risk_scores.csv", index=False)

print("\nTop 10 current employees by predicted attrition risk:")
print(at_risk[["EmployeeID", "Department", "JobRole", "YearsAtCompany", "OverTime",
                "JobSatisfaction", "AttritionRiskScore"]].head(10).round(3).to_string(index=False))

# ============================================================
# Charts
# ============================================================
fig, ax = plt.subplots(figsize=(8, 5))
dept_attr = df.groupby("Department")["AttritionFlag"].mean().sort_values(ascending=False)
dept_attr.plot(kind="bar", ax=ax, color="#C0392B", edgecolor="white")
ax.set_title("Attrition Rate by Department", fontsize=13, fontweight="bold")
ax.set_ylabel("Attrition Rate"); ax.set_xlabel("")
plt.xticks(rotation=30, ha="right"); plt.tight_layout()
plt.savefig("chart1_attrition_by_dept.png", dpi=150); plt.close()

fig, ax = plt.subplots(figsize=(8, 5))
gap_data = []
for role in sorted(df["JobRole"].unique()):
    sub = df[df["JobRole"] == role]
    m = sub[sub["Gender"] == "Male"]["MonthlyIncomeNGN"].mean()
    f = sub[sub["Gender"] == "Female"]["MonthlyIncomeNGN"].mean()
    gap_data.append((role, (m - f) / m))
gap_df = pd.DataFrame(gap_data, columns=["Role", "Gap"]).sort_values("Gap", ascending=False)
ax.barh(gap_df["Role"], gap_df["Gap"], color="#8E44AD", edgecolor="white")
ax.set_title("Gender Pay Gap by Role (Male avg vs Female avg)", fontsize=13, fontweight="bold")
ax.set_xlabel("Pay Gap %")
ax.axvline(0, color="black", linewidth=0.8)
ax.invert_yaxis(); plt.tight_layout()
plt.savefig("chart2_pay_gap_by_role.png", dpi=150); plt.close()

fig, ax = plt.subplots(figsize=(9, 5))
top_risk = at_risk.head(10).set_index("EmployeeID")["AttritionRiskScore"]
top_risk.plot(kind="barh", ax=ax, color="#E67E22", edgecolor="white")
ax.set_title("Top 10 Current Employees by Predicted Attrition Risk", fontsize=13, fontweight="bold")
ax.set_xlabel("Predicted Probability of Leaving")
ax.invert_yaxis(); plt.tight_layout()
plt.savefig("chart3_top10_attrition_risk.png", dpi=150); plt.close()

print("\n3 charts saved. employee_risk_scores.csv saved (feeds Power BI drill-through).")
