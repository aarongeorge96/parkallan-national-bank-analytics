
-- 01a: Total and Average Balance by Customer Segment
-- Identifies which segments hold the most value

SELECT 
  c.customer_segment AS customer_segment,
  COUNT(c.customer_id) AS number_of_customers,
  ROUND(SUM(a.current_balance), 2) AS total_balance,
  ROUND(AVG(a.current_balance), 2) AS avg_balance_per_account
FROM `parkallan-analytics.parkallan_national_bank.fact_accounts` a
LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_customers` c
  ON a.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY total_balance DESC;