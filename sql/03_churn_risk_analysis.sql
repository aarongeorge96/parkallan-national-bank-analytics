
-- Parkallan National Bank — Retail Analytics
-- Query 03: Customer Churn Risk Analysis
-- Identifies customers at risk of leaving the bank
-- based on transaction inactivity, product count,
-- and account status



-- 03a: Churn Risk Customer List
-- Flags customers meeting any churn risk condition:
--   1. No transaction in last 90 days of dataset
--   2. Single product holder
--   3. Inactive account status

WITH customer_product_count AS (
  SELECT 
    customer_id, 
    COUNT(DISTINCT product_id) AS product_count
  FROM `parkallan-analytics.parkallan_national_bank.fact_accounts`
  GROUP BY customer_id
),

customer_last_transaction AS (
  SELECT 
    customer_id, 
    MAX(date_id) AS last_transaction_date_id
  FROM `parkallan-analytics.parkallan_national_bank.fact_transactions`
  GROUP BY customer_id
)

SELECT 
  c.customer_id,
  c.first_name,
  c.last_name,
  c.customer_segment,
  cpc.product_count,
  clt.last_transaction_date_id,
  MIN(a.last_activity_date) AS last_activity_date,
  CASE 
    WHEN clt.last_transaction_date_id < 20231002 THEN 'No Recent Activity'
    WHEN cpc.product_count = 1                   THEN 'Single Product'
    WHEN c.is_active = FALSE                      THEN 'Inactive Customer'
  END AS churn_risk_reason
FROM `parkallan-analytics.parkallan_national_bank.fact_accounts` a
LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_customers` c
  ON a.customer_id = c.customer_id
LEFT JOIN customer_product_count cpc
  ON a.customer_id = cpc.customer_id
LEFT JOIN customer_last_transaction clt
  ON a.customer_id = clt.customer_id
WHERE clt.last_transaction_date_id < 20231002
  OR cpc.product_count = 1
  OR c.is_active = FALSE
GROUP BY 
  c.customer_id,
  c.first_name,
  c.last_name,
  c.customer_segment,
  c.is_active,
  cpc.product_count,
  clt.last_transaction_date_id
ORDER BY last_activity_date ASC;