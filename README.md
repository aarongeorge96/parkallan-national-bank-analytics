# Parkallan National Bank: Retail Analytics Platform

A full-stack retail banking analytics project simulating the data infrastructure and analytical capabilities of a Canadian retail bank. Built to demonstrate end-to-end data skills across data modelling, SQL analytics, cloud data warehousing, and business intelligence.

---

## Project Overview

This project simulates the analytics environment of a Canadian retail bank called Parkallan National Bank. It covers the full data pipeline from raw data generation to executive dashboards, answering real business questions that analysts at institutions like TD, RBC, and Scotiabank work on daily.

The project was built entirely from scratch including the data model design, synthetic data generation, cloud warehouse setup, SQL analytics layer, and Power BI dashboard.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Data Generation | Python (Faker, Pandas, NumPy) |
| Data Warehouse | Google BigQuery |
| Analytics | SQL (CTEs, Window Functions, Aggregations) |
| Visualization | Microsoft Power BI Desktop |

---

## Repository Structure

```
Parkallan-Analytics/
│
├── data/
│   └── generate_parkallan_data.py
│
├── sql/
│   ├── 01_customer_segment_profitability.sql
│   ├── 02_product_crosssell_analysis.sql
│   ├── 03_churn_risk_analysis.sql
│   ├── 04_branch_performance.sql
│   ├── 05_monthly_transaction_trends.sql
│   ├── 06_loan_default_analysis.sql
│   ├── 07_acquisition_channel_value.sql
│   └── 08_customer_lifetime_value.sql
│
├── powerbi/
│   └── parkallan_dashboard.pbix
│
└── README.md
```

---

## Data Model

The project follows a star schema design with three fact tables and four dimension tables.

### Dimension Tables

**dim_customers** stores customer demographic information including name, date of birth, income bracket, customer segment, and acquisition channel.

**dim_products** contains the Parkallan product catalogue including chequing accounts, savings accounts, GICs, TFSAs, RRSPs, credit cards, personal loans, mortgages, HELOCs, and overdraft protection.

**dim_location** covers branch and customer address locations across all Canadian provinces and territories, including region classification and neighbourhood income tier.

**dim_date** provides a full date dimension for 2022 and 2023 including day, month, quarter, fiscal quarter, weekend flags, and Canadian statutory holidays.

### Fact Tables

**fact_accounts** tracks every product account held by each customer, including open and close dates, current balance, credit limit, and account status.

**fact_transactions** records 500,000 individual customer transactions across channels including POS, online, ATM, mobile, and branch. Each transaction includes merchant name, category, currency, and fraud flag.

**fact_loans** captures the full loan lifecycle from application through to repayment, including approval status, credit score at application, interest rate, outstanding balance, and delinquency status.

---

## Data Generation

Synthetic data was generated using Python to simulate realistic Canadian retail banking patterns. Key design decisions include:

- Customer demographics calibrated against Statistics Canada provincial population distributions
- Real Canadian cities, provinces, and postal codes across all 13 provinces and territories
- Real Canadian merchants including Tim Hortons, Sobeys, Canadian Tire, Petro-Canada, and Air Canada
- Canadian banking products including TFSA and RRSP which are unique to Canada
- Credit scores following a normal distribution centred around 680, consistent with Canadian Equifax and TransUnion scoring ranges of 300 to 900
- Transaction categories aligned with Canadian household spending patterns
- Loan interest rates consistent with Canadian market rates for the 2022 to 2023 period

The dataset contains 527,561 rows across seven tables.

---

## SQL Analytics

Eight analytical queries were written to answer key business questions. All queries are stored in the sql directory and were executed in Google BigQuery.

### Query 01: Customer Segment Profitability

Calculates total balance, average balance, and customer count by segment (Mass Market, Emerging Affluent, High Net Worth, Private Banking). Identifies which segments drive the most value for the bank.

### Query 02: Product Cross-sell Analysis

Three part analysis covering product adoption rates, average products per customer, and a product pair cross-sell matrix. Uses a self join on fact_accounts to identify the most common product combinations held by customers.

### Query 03: Churn Risk Analysis

Flags customers as churn risk based on three conditions: no transaction activity in the last 90 days of the dataset, single product holders, and inactive account status. Uses two chained CTEs and joins across four tables.

### Query 04: Branch Performance

Two part analysis covering account balances per branch and transaction volumes per branch, with a province level rollup for geographic reporting. Filters to branch locations only using the is_branch flag in dim_location.

### Query 05: Monthly Transaction Trends

Calculates monthly transaction volumes and amounts for 2022 and 2023, with month over month growth percentage calculated using the LAG window function. Joins fact_transactions to dim_date for clean date dimension filtering.

### Query 06: Loan Default Analysis

Three part risk analysis covering default rate by province, default rate by Canadian credit score band (Poor, Fair, Good, Very Good, Excellent), and a comparison of average credit scores between defaulted and current loans. Uses conditional COUNT aggregations and OSFI standard delinquency classifications.

### Query 07: Acquisition Channel Value

Compares the four acquisition channels (Branch, Online, Mobile App, Referral) across total customers, total balance, average balance, average products per customer, and active customer retention rate.

### Query 08: Customer Lifetime Value

Calculates a composite CLV score per customer using a weighted formula across five components: total account balance (40%), transaction engagement (20%), product depth (20%), outstanding loan value (15%), and active status bonus (5%). Uses three chained CTEs joining across all three fact tables.

---

## BigQuery Views

Two views were created in BigQuery to pre-compute complex analytical scores for use in Power BI.

**vw_customer_clv** pre-computes the Customer Lifetime Value score for all 5,000 customers using the Query 08 formula. This avoids running a three CTE, four table join query on every dashboard refresh.

**vw_churn_risk** pre-computes the churn risk flag and reason for all at-risk customers using the Query 03 logic. This encapsulates the business logic in a single reusable view accessible to any downstream tool.

---

## Power BI Dashboard

The dashboard contains five pages connected directly to Google BigQuery via the native BigQuery connector in Power BI Desktop.

**Page 1: Executive Overview** displays six KPI cards covering total customers, total balance, total transactions, total transaction amount, active customer rate, and churn risk count. Supported by a customer segment bar chart and monthly transaction trend line chart.

**Page 2: Branch and Geography** features an interactive map of Canada with transaction volume bubbles by province, a total balance bar chart by province, and a top branch performance table. A region slicer allows filtering by Western Canada, Central Canada, Atlantic Canada, Prairie, and Northern regions.

**Page 3: Product and Customer Analysis** covers cross-sell rate, average products per customer, customer segment distribution, product adoption rates, acquisition channel balance comparison, and a top 10 CLV customer table sourced from vw_customer_clv.

**Page 4: Risk and Loan Analysis** displays overall default rate, total approved loans, default rate by province, default rate by Canadian credit score band, loan status breakdown, and loan performance by status.

**Page 5: Customer Intelligence** presents average CLV score, CLV by customer segment, churn risk by segment, churn risk by acquisition channel, and a top 10 highest CLV customers table sourced from vw_customer_clv.

---

## Key Business Insights

The following insights were derived from the analytics layer and are reflected in the dashboard.

Chequing Account is held by 100% of customers confirming its role as the anchor product. All secondary products sit at approximately 25% adoption, indicating a significant cross-sell opportunity across the customer base.

The average customer holds 3.31 products, which is consistent with Canadian retail banking industry benchmarks of 3 to 4 products per customer.

The overall loan default rate is 4.70%. Nunavut shows the highest provincial default rate at 6.45%, though the small loan book of 93 loans limits statistical reliability. British Columbia represents the highest risk by volume with 40 defaults across 932 approved loans.

Referral channel customers show the highest retention rate at 94.45% active, while Mobile App customers carry the highest average account balance at $82,563, suggesting this channel attracts higher value customers despite lower acquisition volume.

The top CLV customer, Richard Kidd, is classified as Emerging Affluent rather than High Net Worth, demonstrating that individual customer behaviour is a stronger predictor of value than segment label alone.

---

## Setup Instructions

### Prerequisites

- Python 3.8 or higher
- Google Cloud account with BigQuery enabled
- Power BI Desktop (free download from Microsoft)

### Step 1: Generate the Data

```bash
pip install faker pandas numpy
python data/generate_parkallan_data.py
```

This generates seven CSV files in a parkallan_data directory.

### Step 2: Load to BigQuery

1. Create a Google Cloud project
2. Create a BigQuery dataset named parkallan_national_bank
3. Upload each CSV file as a new table using the BigQuery console
4. Enable auto-detect schema during upload

### Step 3: Create BigQuery Views

Run the CREATE VIEW statements from queries 03 and 08 in the BigQuery console to create vw_churn_risk and vw_customer_clv.

### Step 4: Connect Power BI

1. Open Power BI Desktop
2. Click Get Data and select Google BigQuery
3. Sign in with your Google account
4. Select all seven tables and two views from parkallan_national_bank
5. Click Load and select Import mode

---

## Domain Context

This project was built with Canadian banking regulations and products in mind. Key domain considerations include PIPEDA compliance for customer data privacy, OSFI delinquency classification buckets of 30, 60, and 90 days past due, Canadian registered account types including TFSA and RRSP, Canadian credit scoring ranges from 300 to 900 via Equifax and TransUnion, and Statistics Canada provincial population distributions used to calibrate synthetic data.

---

## Author

Built as a portfolio project demonstrating end-to-end data analytics skills targeting Business Analyst and Data Analyst roles in the Canadian financial services sector.
