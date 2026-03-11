#  Healthcare Claim Denial Prediction

> End-to-end data science project on 50,000 healthcare claims — statistical testing, cohort analysis, bias auditing, and ML model pipeline to predict and prevent claim denials.

---

##  Business Problem

U.S. healthcare providers lose **$262B+ annually** to claim denials. A denied claim means delayed or lost revenue, extra administrative work, and in many cases the patient never gets reimbursed.

This project builds a production-style ML pipeline that **predicts which claims will be denied before submission** — so billing teams can fix documentation issues in time, reducing the $197.7M in denied revenue found in this dataset.



---

##  Project Structure

```
healthcare-claim-denial-prediction/
│
├── README.md
├── requirements.txt
│
├── data/
│   └── Healthcare_Claims_Dataset.csv
│
├── notebooks/
│   └── Claim_Denial_Prediction.ipynb
│
└── sql/
    └── claims_analysis.sql
```

---

##  Dataset Overview

| Property | Value |
|---|---|
| Total Claims | 50,000 |
| Features | 21 |
| Date Range | FY 2022 |
| Payers | 7 (Medicare, Medicaid, BlueCross, UnitedHealth, Aetna, Cigna, Humana) |
| States | 10 |
| Providers | 500 |
| Diagnosis Groups | 8 |
| Claim Types | 6 |
| **Target: is_denied** | **7,938 denied (15.9%)** |

---

##  Key Findings

| Finding | Detail |
|---|---|
| Strongest denial driver | Claim type (p<0.001) |
| Highest denial rate | Emergency claims — 21.1% |
| Lowest denial rate | Lab/Pathology — 13.6% |
| Payer bias flagged | Medicaid exceeds EEOC 1.25 DI threshold |
| Medicaid vs baseline | 26.8% higher denial rate than BlueCross |
| Highest-risk cohort | Medicaid + Mental Health — 21.1% denial rate |
| Cost pattern | Denial rate rises Q1 to Q4 — payer cost-avoidance behavior |

---

##  Notebook Walkthrough

### 1. EDA
- Denial rate by payer, claim type, diagnosis group
- Denial reason breakdown — volume and financial impact
- Distribution comparison: denied vs approved claims

### 2. Statistical Hypothesis Testing

| Test | Variables | Result |
|---|---|---|
| Chi-Square | Claim Type vs Denial | Significant |
| Chi-Square | Payer vs Denial | Significant |
| Chi-Square | Diagnosis vs Denial | Not significant |
| Mann-Whitney U | Billed Amount (denied vs approved) | Significant, negligible effect |
| Kruskal-Wallis | Processing Days by Payer | Not significant |
| One-Way ANOVA | Billed Amount by Diagnosis | Significant |
| Point-Biserial | Patient Age vs Denial | Not predictive |
| Post-hoc Chi-Square | All payer pairs (Bonferroni corrected) | Medicaid different from all others |
| Wilson 95% CI | Denial rate by payer | Medicaid CI has zero overlap with commercial payers |

### 3. Feature Engineering
12 domain-specific features engineered including payment_ratio, discount_rate, copay_ratio, is_emergency, is_medicaid, is_high_cost, is_elderly, provider_denial_rate, and provider_claim_count.

### 4. Cohort Analysis
- Age cohorts (0-18, 19-35, 36-50, 51-65, 65+) across denial rate, avg billed, avg paid, LOS, readmission rate
- Cost quartile cohorts (Q1-Q4) — denial rate rises monotonically with cost
- 56-combination payer x diagnosis cross-cohort — identifies highest-risk claim segments

### 5. Bias & Disparity Analysis
- Disparate Impact (EEOC 4/5ths rule) on payer, state, and age group
- Medicaid flagged — exceeds 1.25 bias threshold at DI=1.268
- No age-based bias detected — positive equity finding

### 6. Machine Learning Pipeline

| Model | Notes |
|---|---|
| Logistic Regression | Interpretable baseline |
| Random Forest | Best single model |
| Gradient Boosting | Strong on structured data |
| Extra Trees | Fast ensemble |
| Stacking Ensemble | Production-grade final model |

- Imbalance handling: class_weight='balanced' + minority oversampling
- Tuning: RandomizedSearchCV with StratifiedKFold (5-fold)
- Primary metrics: ROC-AUC and PR-AUC (not accuracy)

### 7. Model Interpretability
- Gini feature importance (tree-based)
- Permutation importance (model-agnostic)
- Top predictors: payment_ratio, provider_denial_rate, is_medicaid

### 8. Business Impact
- Claims scored above P(denial) > 0.40 routed to pre-submission review
- Medicaid compliance risk recommendation under CMS value-based contract terms

---

##  SQL Analysis

`sql/claims_analysis.sql` contains 8 queries covering denial rate by payer, claim type, and diagnosis; top denial reasons by volume and revenue; payer x diagnosis cross-analysis; age group cohort breakdown; processing time equity; state-level performance; and full financial summary.

---

##  How to Run

```bash
# 1. Clone the repo
git clone https://github.com/rnehareddy74/healthcare-claims-denial-prediction
cd healthcare-claims-denial-prediction

# 2. Install dependencies
pip install -r requirements.txt

# 3. Launch notebook
jupyter notebook notebooks/Healthcare_Claim_Denial_Prediction.ipynb
```

Place `Healthcare_Claims_Dataset.csv` in the `data/` folder before running.

---

##  Tech Stack

| Category | Tools |
|---|---|
| Language | Python 3.10 |
| Data manipulation | Pandas, NumPy |
| Statistical testing | SciPy |
| Machine learning | scikit-learn |
| Visualization | Matplotlib, Seaborn |
| Database | SQL (PostgreSQL / SQLite compatible) |

---



