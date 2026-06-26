
-- Parkallan National Bank — Retail Analytics
-- Query 04: Branch Performance Analysis
-- Measures branch and province level performance
-- across accounts, balances, and transactions



-- 04a: Branch Performance by Account Balances
-- Total and average balance held per branch
-- Ordered by total balance descending

WITH account_count_loc AS (
  SELECT 
    location_id, 
    COUNT(account_id)            AS no_of_accounts,
    ROUND(SUM(current_balance), 2) AS total_balance, 
    ROUND(AVG(current_balance), 2) AS average_balance
  FROM `parkallan-analytics.parkallan_national_bank.fact_accounts`
  GROUP BY location_id
)

SELECT 
  l.location_id,
  l.city,
  l.province,
  l.region,
  a.no_of_accounts,
  a.total_balance,
  a.average_balance
FROM account_count_loc a
LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_location` l
  ON a.location_id = l.location_id
WHERE l.is_branch = TRUE
ORDER BY a.total_balance DESC;



-- 04b: Transaction Volume by Branch
-- Total transactions and amounts per branch
-- Ordered by total transaction amount descending

WITH transaction_count_loc AS (
  SELECT 
    location_id, 
    COUNT(transaction_id)              AS no_of_transactions,
    ROUND(SUM(transaction_amount), 2)  AS total_transaction_amount, 
    ROUND(AVG(transaction_amount), 2)  AS average_transaction_amount
  FROM `parkallan-analytics.parkallan_national_bank.fact_transactions`
  GROUP BY location_id
)

SELECT 
  l.city,
  l.province,
  l.region,
  t.no_of_transactions,
  t.total_transaction_amount,
  t.average_transaction_amount
FROM transaction_count_loc t
LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_location` l
  ON t.location_id = l.location_id
WHERE l.is_branch = TRUE
ORDER BY t.total_transaction_amount DESC;



-- 04c: Transaction Volume by Province
-- Province level rollup for Power BI map visual
-- Ordered by total transaction amount descending

WITH transaction_count_loc AS (
  SELECT 
    location_id, 
    COUNT(transaction_id)              AS no_of_transactions,
    ROUND(SUM(transaction_amount), 2)  AS total_transaction_amount, 
    ROUND(AVG(transaction_amount), 2)  AS average_transaction_amount
  FROM `parkallan-analytics.parkallan_national_bank.fact_transactions`
  GROUP BY location_id
)

SELECT 
  l.province,
  l.region,
  ROUND(SUM(t.total_transaction_amount), 2)  AS total_transaction_amount,
  ROUND(AVG(t.average_transaction_amount), 2) AS average_transaction_amount,
  SUM(t.no_of_transactions)                  AS no_of_transactions
FROM transaction_count_loc t
LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_location` l
  ON t.location_id = l.location_id
WHERE l.is_branch = TRUE
GROUP BY l.province, l.region
ORDER BY total_transaction_amount DESC;