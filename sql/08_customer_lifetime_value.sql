
-- Parkallan National Bank — Retail Analytics
-- Query 08: Customer Lifetime Value (CLV)
-- Calculates a composite CLV score per customer
-- combining balance, transactions, products,
-- loans and active status



-- 08a: Customer Lifetime Value Score
-- CLV Formula Weights:
--   40% — Total account balance
--   20% — Transaction engagement (count x $10)
--   20% — Product depth (count x $5,000)
--   15% — Outstanding loan value
--    5% — Active status bonus ($50,000)
-- Higher score = more valuable customer

WITH account_metrics AS (
  SELECT 
    customer_id,
    COUNT(DISTINCT product_id)       AS product_count,
    ROUND(SUM(current_balance), 2)   AS total_balance
  FROM `parkallan-analytics.parkallan_national_bank.fact_accounts`
  GROUP BY customer_id
),

transaction_metrics AS (
  SELECT 
    customer_id,
    COUNT(DISTINCT transaction_id) AS transaction_count
  FROM `parkallan-analytics.parkallan_national_bank.fact_transactions`
  GROUP BY customer_id
),

loan_metrics AS (
  SELECT 
    customer_id,
    ROUND(SUM(outstanding_balance), 2) AS loan_value
  FROM `parkallan-analytics.parkallan_national_bank.fact_loans`
  WHERE loan_amount_approved IS NOT NULL
  GROUP BY customer_id
)

SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  c.customer_segment,
  c.acquisition_channel,
  c.is_active,
  acm.product_count,
  acm.total_balance,
  tm.transaction_count,
  COALESCE(lm.loan_value, 0)          AS loan_value,
  ROUND(
    (acm.total_balance * 0.40) +
    (tm.transaction_count * 10 * 0.20) +
    (acm.product_count * 5000 * 0.20) +
    (COALESCE(lm.loan_value, 0) * 0.15) +
    (CASE WHEN c.is_active = TRUE THEN 50000 ELSE 0 END * 0.05)
  , 2)                                AS clv_score
FROM account_metrics acm
LEFT JOIN transaction_metrics tm
  ON acm.customer_id = tm.customer_id
LEFT JOIN loan_metrics lm
  ON acm.customer_id = lm.customer_id
LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_customers` c
  ON acm.customer_id = c.customer_id
ORDER BY clv_score DESC;