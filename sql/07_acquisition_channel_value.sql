
-- Parkallan National Bank — Retail Analytics
-- Query 07: Acquisition Channel Value Analysis
-- Measures the quality and value of customers
-- acquired through each channel



-- 07a: Customer Value by Acquisition Channel
-- Compares Branch, Online, Mobile App and Referral
-- channels across balance, products, and retention
-- Higher active_customer_pct = better retention
-- Higher avg_balance = higher value customers

WITH customer_products AS (
  SELECT 
    customer_id,
    COUNT(DISTINCT product_id) AS product_count
  FROM `parkallan-analytics.parkallan_national_bank.fact_accounts`
  GROUP BY customer_id
)

SELECT
  c.acquisition_channel,
  COUNT(DISTINCT a.customer_id)                                    AS total_customers,
  ROUND(SUM(a.current_balance), 2)                                 AS total_balance,
  ROUND(AVG(a.current_balance), 2)                                 AS avg_balance_per_account,
  ROUND(AVG(cp.product_count), 2)                                  AS avg_products_per_customer,
  ROUND(AVG(CASE WHEN c.is_active = TRUE THEN 1 ELSE 0 END) * 100, 2) AS active_customer_pct
FROM `parkallan-analytics.parkallan_national_bank.fact_accounts` a
LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_customers` c
  ON a.customer_id = c.customer_id
LEFT JOIN customer_products cp
  ON a.customer_id = cp.customer_id
GROUP BY c.acquisition_channel
ORDER BY total_balance DESC;