WITH customers AS (

	SELECT
		customer_id,
		first_name,
		last_name,
		customer_segment,
		is_active

	FROM {{ ref('stg_customers') }}

),

balances AS (

	SELECT
		customer_id,
		total_active_balance

	FROM {{ ref('int_account_balances_by_customer') }}

),

products AS (

	SELECT
		customer_id,
		active_product_count

	FROM {{ ref('int_customer_product_counts') }}

),

transaction_counts AS (

	SELECT
		customer_id,
		COUNT(*) AS transaction_count

	FROM {{ ref('stg_transactions') }}
	GROUP BY customer_id

),

loan_balances AS (

	SELECT
		customer_id,
		SUM(outstanding_balance) AS total_outstanding_loan_balance

	FROM {{ ref('int_loan_risk_flags') }}
	GROUP BY customer_id

),

raw_components AS (

	SELECT
		c.customer_id,
		c.first_name,
		c.last_name,
		c.customer_segment,
		c.is_active,
		COALESCE(b.total_active_balance, 0) AS total_active_balance,
		COALESCE(p.active_product_count, 0) AS active_product_count,
		COALESCE(tc.transaction_count, 0) AS transaction_count,
		COALESCE(lb.total_outstanding_loan_balance, 0) AS total_outstanding_loan_balance

	FROM customers c
	LEFT JOIN balances b ON c.customer_id = b.customer_id
	LEFT JOIN products p ON c.customer_id = p.customer_id
	LEFT JOIN transaction_counts tc ON c.customer_id = tc.customer_id
	LEFT JOIN loan_balances lb ON c.customer_id = lb.customer_id

),

normalized AS (

	SELECT
		*,
		SAFE_DIVIDE(
			total_active_balance - MIN(total_active_balance) OVER (),
			MAX(total_active_balance) OVER () - MIN(total_active_balance) OVER ()
		) * 100 AS balance_score,
		SAFE_DIVIDE(
			transaction_count - MIN(transaction_count) OVER (),
			MAX(transaction_count) OVER () - MIN(transaction_count) OVER ()
		) * 100 AS transaction_score,
		SAFE_DIVIDE(
			active_product_count - MIN(active_product_count) OVER (),
			MAX(active_product_count) OVER () - MIN(active_product_count) OVER ()
		) * 100 AS product_score,
		SAFE_DIVIDE(
			total_outstanding_loan_balance - MIN(total_outstanding_loan_balance) OVER (),
			MAX(total_outstanding_loan_balance) OVER () - MIN(total_outstanding_loan_balance) OVER ()
		) * 100 AS loan_value_score,
		CASE WHEN is_active THEN 100 ELSE 0 END AS active_status_score

	FROM raw_components

),

final AS (

	SELECT
		customer_id,
		first_name,
		last_name,
		customer_segment,
		total_active_balance,
		transaction_count,
		active_product_count,
		total_outstanding_loan_balance,
		is_active,
		ROUND(
			(COALESCE(balance_score, 0) * 0.40)
			+ (COALESCE(transaction_score, 0) * 0.20)
			+ (COALESCE(product_score, 0) * 0.20)
			+ (COALESCE(loan_value_score, 0) * 0.15)
			+ (active_status_score * 0.05),
			2
		) AS clv_score

	FROM normalized

)

SELECT * FROM final
ORDER BY clv_score DESC
