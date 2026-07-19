# Parkallan National Bank: Retail Analytics Platform

A full-stack retail banking analytics project simulating the data infrastructure and analytical capabilities of a Canadian retail bank. Built to demonstrate end-to-end data skills across data modelling, SQL analytics, cloud data warehousing, dbt-based transformation, and business intelligence.

---

## Project Overview

This project simulates the analytics environment of a Canadian retail bank called Parkallan National Bank. It covers the full data pipeline from raw data generation to executive dashboards, answering real business questions that analysts at institutions like TD, RBC, and Scotiabank work on daily.

The project was built entirely from scratch, including the data model design, synthetic data generation, cloud warehouse setup, a dbt Core transformation layer (staging → intermediate → marts), and a Power BI dashboard connected directly to the transformed output.

The transformation layer was deliberately rebuilt in dbt Core rather than left as a flat set of SQL queries, to demonstrate the data modelling discipline — layered architecture, reusable business logic, and automated testing — that differentiates this project from a typical BI-only portfolio piece.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Data Generation | Python (Faker, Pandas, NumPy) |
| Data Warehouse | Google BigQuery |
| Transformation | dbt Core (staging, intermediate, and mart layers) |
| Analytics / Testing | SQL (CTEs, window functions, aggregations) + 100 automated dbt tests |
| Visualization | Microsoft Power BI Desktop |

---

## Repository Structure

```
Parkallan-Analytics/
│
├── data/
│   ├── generate_parkallan_data.py
│   └── dim_date.csv                    (extended 2015–2023, see Data Model notes)
│
├── parkallan_dbt/
│   ├── dbt_project.yml
│   └── models/
│       ├── staging/                    (7 models — 1:1 cleaned/renamed raw tables)
│       │   ├── _sources.yml
│       │   ├── _staging.yml            (71 schema tests)
│       │   └── stg_*.sql
│       ├── intermediate/               (4 models — reusable business logic)
│       │   └── int_*.sql
│       └── marts/                      (9 models — BI-ready, one per business question)
│           ├── _marts.yml              (29 schema tests)
│           └── mart_*.sql
│
├── powerbi/
│   └── parkallan_dashboard.pbix
│
└── README.md
```

---

## Data Model

The project follows a star schema design with three fact tables and four dimension tables at the source layer.

### Dimension Tables

**dim_customers** stores customer demographic information including name, date of birth, income bracket, customer segment, and acquisition channel.

**dim_products** contains the Parkallan product catalogue including chequing accounts, savings accounts, GICs, TFSAs, RRSPs, credit cards, personal loans, mortgages, HELOCs, and overdraft protection.

**dim_location** covers branch and customer address locations across all Canadian provinces and territories, including region classification and neighbourhood income tier.

**dim_date** provides a full date dimension extended to cover **2015–2023** (originally 2022–2023 only — extended after dbt's automated `relationships` tests caught 9,437 accounts and 317 closures with open/close dates predating the original date range; see Testing section).

### Fact Tables

**fact_accounts** tracks every product account held by each customer, including open and close dates, current balance, credit limit, and account status.

**fact_transactions** records 500,000 individual customer transactions across channels including POS, online, ATM, mobile, and branch. Each transaction includes merchant name, category, currency, and fraud flag.

**fact_loans** captures the full loan lifecycle from application through to repayment, including approval status, credit score at application, interest rate, outstanding balance, and delinquency status.

The dataset contains 527,561+ rows across seven raw tables (`dim_date` grew from 730 to 3,287 rows after the extension above).

---

## dbt Transformation Layer

Raw BigQuery tables are transformed through three layers, each with a distinct purpose:

### 1. Staging (7 models)
1:1 cleaned and renamed versions of each raw table (`stg_customers`, `stg_date`, `stg_location`, `stg_products`, `stg_accounts`, `stg_loans`, `stg_transactions`). No business logic — just consistent naming and light type handling. Covered by **71 automated tests**: primary key uniqueness/not-null, foreign key relationship checks, and `accepted_values` checks against real distinct values pulled from the data (not guessed).

### 2. Intermediate (4 models)
Reusable business logic computed once, referenced by multiple marts, so no calculation is duplicated across the codebase:
- **`int_customer_activity`** — last transaction date and 90-day inactivity flag per customer
- **`int_customer_product_counts`** — distinct active product count per customer, single-product-holder flag
- **`int_loan_risk_flags`** — Canadian Equifax/TransUnion credit score banding, default/delinquency flags (approved loans only)
- **`int_account_balances_by_customer`** — active vs. total balance aggregated per customer

### 3. Marts (9 models)
BI-ready tables, each shaped to a specific business question's grain, replacing the original 8 SQL queries and 2 BigQuery views:

| Mart | Grain | Replaces |
|---|---|---|
| `mart_segment_profitability` | 1 row per segment | Query 01 |
| `mart_product_adoption` | 1 row per product | Query 02 (adoption) |
| `mart_product_crosssell_pairs` | 1 row per product pair | Query 02 (cross-sell matrix) |
| `mart_churn_risk` | 1 row per customer | Query 03 / `vw_churn_risk` |
| `mart_branch_performance` | 1 row per branch | Query 04 |
| `mart_monthly_transaction_trends` | 1 row per year-month | Query 05 |
| `mart_loan_default_risk` | 1 row per approved loan | Query 06 |
| `mart_acquisition_channel_value` | 1 row per channel | Query 07 |
| `mart_customer_clv` | 1 row per customer | Query 08 / `vw_customer_clv` |

Each mart is intentionally self-contained (no relationships between marts) — a deliberate design tradeoff that keeps each business question isolated and simple to reason about, at the cost of losing automatic cross-slicing that a single shared fact table would give for free. Power BI relies on each mart carrying its own copy of dimension attributes (e.g. `customer_segment`, `province`, `product_name`) it needs, rather than joining across marts.

---

## Testing

**100 automated dbt tests** run across the pipeline (71 staging, 29 marts): primary key uniqueness and not-null checks, foreign key relationship checks, and `accepted_values` checks verified against real data rather than assumed.

This wasn't just a checkbox — testing caught a real, previously undetected data issue: `dim_date` originally only covered 2022–2023, but accounts and loans in the data have open/close dates going back to 2015 (accounts predate the 2-year transaction window). The `relationships` test on `stg_accounts.open_date_id` and `.close_date_id` failed with 9,437 and 317 orphaned rows respectively — dead giveaways that would have silently broken any "accounts opened by year" analysis for anything before 2022. The date dimension was regenerated using the same holiday-calculation formula as the original (verified to reproduce the existing 2022–2023 rows exactly) and extended back to 2015-01-01.

---

## Power BI Dashboard

The dashboard connects **exclusively to the 9 dbt marts** in BigQuery via Power BI's native BigQuery connector, in Import mode — no raw tables or legacy views remain connected in the model.

**Page 1: Executive Overview** — total customers, total balance, total transactions, total transaction amount, active customer %, and churn risk count, alongside a segment balance breakdown and monthly transaction trend.

**Page 2: Branch and Geography** — interactive map of branch locations, balance and transaction volume by province, and a branch performance table, filterable by region.

**Page 3: Product and Customer Analysis** — cross-sell rate, average products per customer, segment distribution, product adoption rates, acquisition channel balance comparison, and a top-10 CLV customer table.

**Page 4: Risk and Loan Analysis** — default rate, total approved loans, default rate by province and by Canadian credit score band, and loan status breakdown.

**Page 5: Customer Intelligence** — average CLV score, CLV by segment, churn risk by segment and by acquisition channel, and a top-10 highest-CLV customer table.

---

## Key Business Insights

*(Figures below reflect the dbt-marts-based dashboard; some differ from earlier flat-SQL figures due to two deliberate definition changes made during the rebuild — see notes.)*

Chequing Account remains the anchor product at 100% adoption.

**Average products per customer is 3.05** (previously reported as 3.31). This is a deliberate correction, not a data change: the original figure counted *accounts* (`COUNT(fact_accounts)`), which double-counts a customer holding two accounts of the same product. The corrected figure counts *distinct product types* held, which is the more meaningful metric for cross-sell analysis.

The overall loan default rate is **4.70%**, across 3,784 approved loans.

Average CLV score across the customer base is **32.89** (0–100 scale, min-max normalized across balance, transaction engagement, product depth, outstanding loan value, and active-status components, weighted 40/20/20/15/5 per the original design).

**92.34%** of customers are in active relationship status, with **549 customers** flagged as churn risk (inactive 90+ days, single-product holders, or inactive relationship status).

Total transaction volume across the dataset is 500,000 transactions totaling **$343.17M**, against a total book balance of **$1.23bn** (active accounts only — see note below).

> **Note on balance figures:** current mart-based `total_balance` reflects active accounts only, whereas the original flat-SQL figure summed all accounts including closed ones. Closed-account balances are typically near-zero, so the difference is expected to be small.

---

## Setup Instructions

### Prerequisites

- Python 3.8 or higher
- Google Cloud account with BigQuery enabled
- dbt Core with the `dbt-bigquery` adapter (`pip install dbt-core dbt-bigquery`)
- Power BI Desktop (free download from Microsoft)

### Step 1: Generate the Data

```bash
pip install faker pandas numpy
python data/generate_parkallan_data.py
```

This generates seven CSV files in a `parkallan_data` directory. Use the extended `dim_date.csv` included in this repo (2015–2023) rather than regenerating it, unless you also update the generation script's date range.

### Step 2: Load to BigQuery

1. Create a Google Cloud project.
2. Create a BigQuery dataset named `parkallan_national_bank`.
3. Upload each CSV file as a new table using the BigQuery console, with auto-detect schema enabled.

### Step 3: Run the dbt Pipeline

```bash
cd parkallan_dbt
dbt deps          # if using any packages
dbt run           # builds all staging, intermediate, and mart models
dbt test          # runs all 100 schema tests
```

Requires a `profiles.yml` configured with a BigQuery service account (see `parkallan_dbt/README.md` for the standard dbt-generated setup guide).

### Step 4: Connect Power BI

1. Open Power BI Desktop.
2. Click **Get Data** → **Google BigQuery** → sign in.
3. Select the **9 mart tables only** (`mart_segment_profitability`, `mart_product_adoption`, `mart_product_crosssell_pairs`, `mart_churn_risk`, `mart_branch_performance`, `mart_monthly_transaction_trends`, `mart_loan_default_risk`, `mart_acquisition_channel_value`, `mart_customer_clv`) from `parkallan_national_bank`.
4. Click **Load**, choose **Import** mode.
5. Marts are intentionally unrelated to each other in the data model — do not let Power BI auto-create relationships between them; verify in Model view that no mart-to-mart relationship lines exist.

---

## Domain Context

This project was built with Canadian banking regulations and products in mind. Key domain considerations include PIPEDA compliance for customer data privacy, OSFI delinquency classification buckets of 30, 60, and 90 days past due, Canadian registered account types including TFSA and RRSP, Canadian credit scoring ranges from 300 to 900 via Equifax and TransUnion, and Statistics Canada provincial population distributions used to calibrate synthetic data.

---

## Author

Built as a portfolio project demonstrating end-to-end data analytics and data engineering skills — data modelling, dbt-based transformation architecture, automated testing, and BI development — targeting Business Analyst and Data Analyst roles in the Canadian financial services sector.
