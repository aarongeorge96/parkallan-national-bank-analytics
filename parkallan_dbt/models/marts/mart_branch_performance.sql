WITH branches AS (

	SELECT
		location_id,
		city,
		province,
		region

	FROM {{ ref('stg_location') }}
	WHERE is_branch = true

),

branch_balances AS (

	SELECT
		location_id,
		SUM(CASE WHEN account_status = 'Active' THEN current_balance ELSE 0 END) AS total_active_balance,
		COUNT(DISTINCT customer_id) AS customer_count

	FROM {{ ref('stg_accounts') }}
	GROUP BY location_id

),

branch_transactions AS (

	SELECT
		location_id,
		COUNT(*) AS transaction_count,
		SUM(transaction_amount) AS total_transaction_amount

	FROM {{ ref('stg_transactions') }}
	GROUP BY location_id

),

final AS (

	SELECT
		b.location_id,
		b.city,
		b.province,
		b.region,
		COALESCE(bb.total_active_balance, 0) AS total_active_balance,
		COALESCE(bb.customer_count, 0) AS customer_count,
		COALESCE(bt.transaction_count, 0) AS transaction_count,
		COALESCE(bt.total_transaction_amount, 0) AS total_transaction_amount

	FROM branches b
	LEFT JOIN branch_balances bb
		ON b.location_id = bb.location_id
	LEFT JOIN branch_transactions bt
		ON b.location_id = bt.location_id

)

SELECT * FROM final
