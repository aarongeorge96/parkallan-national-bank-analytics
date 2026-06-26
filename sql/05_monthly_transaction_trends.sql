
-- Parkallan National Bank — Retail Analytics
-- Query 05: Monthly Transaction Trends
-- Tracks monthly transaction volumes and amounts
-- with Month-over-Month (MoM) growth analysis
-- across 2022-2023



-- 05a: Monthly Transaction Volume and MoM Growth
-- Uses LAG window function to calculate MoM growth %
-- Negative % = decline from previous month
-- Positive % = growth from previous month
-- NULL in row 1 = no previous month to compare

WITH monthly_transactions AS (
  SELECT 
    d.year,
    d.month,
    d.month_name,
    COUNT(t.transaction_id)           AS no_of_transactions,
    ROUND(SUM(t.transaction_amount), 2) AS total_transaction_amount
  FROM `parkallan-analytics.parkallan_national_bank.fact_transactions` t
  LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_date` d
    ON t.date_id = d.date_id
  WHERE d.year IN (2022, 2023)
  GROUP BY d.year, d.month, d.month_name
)

SELECT 
  year,
  month,
  month_name,
  no_of_transactions,
  total_transaction_amount,
  ROUND(
    (total_transaction_amount - LAG(total_transaction_amount) OVER (ORDER BY year, month))
    / LAG(total_transaction_amount) OVER (ORDER BY year, month) * 100
  , 2) AS mom_growth_pct
FROM monthly_transactions
ORDER BY year, month;