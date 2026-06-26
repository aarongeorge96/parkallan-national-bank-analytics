
-- Parkallan National Bank — Retail Analytics
-- Query 06: Loan Default Analysis
-- Identifies default risk across provinces,
-- credit score bands, and loan status comparison



-- 06a: Loan Default Rate by Province
-- Rolls up branch-level loan data to province level
-- Higher default rate = higher regional credit risk

WITH loan_stats AS (
  SELECT 
    location_id,
    COUNT(loan_id)                                          AS total_loans,
    COUNT(CASE WHEN loan_status = 'Defaulted' THEN 1 END)  AS defaulted_loans
  FROM `parkallan-analytics.parkallan_national_bank.fact_loans`
  GROUP BY location_id
)

SELECT 
  lo.province,
  lo.region,
  SUM(ls.total_loans)                                          AS total_loans,
  SUM(ls.defaulted_loans)                                      AS defaulted_loans,
  ROUND(SUM(ls.defaulted_loans) / SUM(ls.total_loans) * 100, 2) AS default_rate_pct
FROM loan_stats ls
LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_location` lo
  ON ls.location_id = lo.location_id
GROUP BY lo.province, lo.region
ORDER BY default_rate_pct DESC;



-- 06b: Loan Default Rate by Credit Score Band
-- Canadian credit score bands (Equifax/TransUnion)
-- Shows which borrower profiles carry most risk

SELECT 
  CASE 
    WHEN credit_score_at_application BETWEEN 300 AND 579 THEN 'Poor (300-579)'
    WHEN credit_score_at_application BETWEEN 580 AND 669 THEN 'Fair (580-669)'
    WHEN credit_score_at_application BETWEEN 670 AND 739 THEN 'Good (670-739)'
    WHEN credit_score_at_application BETWEEN 740 AND 799 THEN 'Very Good (740-799)'
    WHEN credit_score_at_application >= 800              THEN 'Excellent (800+)'
  END                                                           AS credit_score_band,
  ROUND(AVG(credit_score_at_application), 2)                    AS avg_credit_score,
  COUNT(loan_id)                                                AS total_loans,
  COUNT(CASE WHEN loan_status = 'Defaulted' THEN 1 END)         AS defaulted_loans,
  ROUND(
    COUNT(CASE WHEN loan_status = 'Defaulted' THEN 1 END) 
    / COUNT(loan_id) * 100
  , 2)                                                          AS default_rate_pct
FROM `parkallan-analytics.parkallan_national_bank.fact_loans`
GROUP BY credit_score_band
ORDER BY avg_credit_score ASC;



-- 06c: Average Credit Score — Defaulted vs Current
-- Compares credit profiles of defaulted borrowers
-- against currently performing loans
-- Excludes rejected and pending applications

SELECT 
  loan_status,
  COUNT(loan_id)                             AS total_loans,
  ROUND(AVG(credit_score_at_application), 2) AS avg_credit_score,
  ROUND(AVG(outstanding_balance), 2)         AS avg_outstanding_balance,
  ROUND(AVG(interest_rate), 2)               AS avg_interest_rate
FROM `parkallan-analytics.parkallan_national_bank.fact_loans`
WHERE loan_amount_approved IS NOT NULL
  AND loan_status IN ('Current', 'Defaulted')
GROUP BY loan_status
ORDER BY loan_status;