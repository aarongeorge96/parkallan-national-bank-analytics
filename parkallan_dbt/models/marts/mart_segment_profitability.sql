WITH customers AS (

	SELECT
		customer_id,
		customer_segment

	FROM {{ ref('stg_customers') }}

),

balances AS (

	SELECT
		customer_id,
		total_active_balance

	FROM {{ ref('int_account_balances_by_customer') }}

),

joined AS (

	SELECT
		c.customer_segment,
		COALESCE(b.total_active_balance, 0) AS total_active_balance

	FROM customers c
	LEFT JOIN balances b
		ON c.customer_id = b.customer_id

)

SELECT
	customer_segment,
	COUNT(*) AS customer_count,
	SUM(total_active_balance) AS total_balance,
	AVG(total_active_balance) AS avg_balance

FROM joined
GROUP BY customer_segment
