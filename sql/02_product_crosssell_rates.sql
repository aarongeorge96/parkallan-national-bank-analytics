
-- Parkallan National Bank — Retail Analytics
-- Query 02: Product Cross-sell Analysis




-- 02a: Product Adoption Rates
-- % of customers holding each product

WITH customer_count AS (
  SELECT COUNT(DISTINCT customer_id) AS total_customers
  FROM `parkallan-analytics.parkallan_national_bank.dim_customers`
)

SELECT 
  p.product_name,
  COUNT(DISTINCT a.customer_id) AS number_of_customers,
  ROUND(COUNT(DISTINCT a.customer_id) / (SELECT total_customers FROM customer_count) * 100, 2) AS adoption_percentage
FROM `parkallan-analytics.parkallan_national_bank.fact_accounts` a
LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_products` p
  ON a.product_id = p.product_id
GROUP BY p.product_name
ORDER BY adoption_percentage DESC;



-- 02b: Average Products Per Customer
-- Key cross-sell depth metric

SELECT ROUND(AVG(product_count), 2) AS avg_products_per_customer
FROM (
  SELECT customer_id, COUNT(DISTINCT product_id) AS product_count
  FROM `parkallan-analytics.parkallan_national_bank.fact_accounts`
  GROUP BY customer_id
);



-- 02c: Product Pair Cross-sell Matrix
-- Most common product combinations held by customers
-- Ranked by co-occurrence frequency

WITH product_pairs AS (
  SELECT 
    a1.product_id AS primary_product_id,
    a2.product_id AS secondary_product_id,
    COUNT(DISTINCT a1.customer_id) AS customers_with_both
  FROM `parkallan-analytics.parkallan_national_bank.fact_accounts` a1
  JOIN `parkallan-analytics.parkallan_national_bank.fact_accounts` a2
    ON a1.customer_id = a2.customer_id
    AND a1.product_id < a2.product_id
  GROUP BY a1.product_id, a2.product_id
)

SELECT 
  p1.product_name AS primary_product,
  p2.product_name AS secondary_product,
  customers_with_both,
  DENSE_RANK() OVER (ORDER BY customers_with_both DESC) AS cross_sell_rank
FROM product_pairs pp
LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_products` p1
  ON pp.primary_product_id = p1.product_id
LEFT JOIN `parkallan-analytics.parkallan_national_bank.dim_products` p2
  ON pp.secondary_product_id = p2.product_id
ORDER BY customers_with_both DESC;