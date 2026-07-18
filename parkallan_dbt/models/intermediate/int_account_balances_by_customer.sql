WITH customers AS (

	SELECT customer_id FROM {{ ref('stg_customers') }}

),

accounts AS (

	SELECT
		customer_id,
		account_status,
		current_balance

	FROM {{ ref('stg_accounts') }}

),

customer_balances AS (

	SELECT
		customer_id,
		SUM(current_balance) AS total_balance_all_accounts,
		SUM(CASE WHEN account_status = 'Active' THEN current_balance ELSE 0 END) AS total_active_balance,
		COUNT(*) AS total_account_count,
		COUNT(CASE WHEN account_status = 'Active' THEN 1 END) AS active_account_count

	FROM accounts
	GROUP BY customer_id

),

final AS (

	SELECT
		c.customer_id,
		COALESCE(cb.total_balance_all_accounts, 0) AS total_balance_all_accounts,
		COALESCE(cb.total_active_balance, 0) AS total_active_balance,
		COALESCE(cb.total_account_count, 0) AS total_account_count,
		COALESCE(cb.active_account_count, 0) AS active_account_count

	FROM customers c
	LEFT JOIN customer_balances cb
		ON c.customer_id = cb.customer_id

)

SELECT * FROM final