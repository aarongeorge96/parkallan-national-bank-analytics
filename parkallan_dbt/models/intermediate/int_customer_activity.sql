WITH customers AS (

	SELECT customer_id FROM {{ ref('stg_customers') }}

),

transactions_with_date AS (

	SELECT
		t.customer_id,
		d.full_date AS transaction_date

	FROM {{ ref('stg_transactions') }} t
	INNER JOIN {{ ref('stg_date') }} d
		ON t.date_id = d.date_id

),

max_dataset_date AS (

	-- reference point is the latest transaction date IN THE DATA, not CURRENT_DATE(),
	-- since this dataset only covers up to 2023-12-31
	SELECT MAX(transaction_date) AS max_date
	FROM transactions_with_date

),

customer_last_transaction AS (

	SELECT
		customer_id,
		MAX(transaction_date) AS last_transaction_date

	FROM transactions_with_date
	GROUP BY customer_id

),

final AS (

	SELECT
		c.customer_id,
		clt.last_transaction_date,
		m.max_date AS dataset_max_date,
		DATE_DIFF(m.max_date, clt.last_transaction_date, day) AS days_since_last_transaction,
		CASE
			WHEN clt.last_transaction_date IS NULL THEN true
			WHEN DATE_DIFF(m.max_date, clt.last_transaction_date, day) > 90 THEN true
			ELSE false
		END AS is_inactive_90d

	FROM customers c
	LEFT JOIN customer_last_transaction clt
		ON c.customer_id = clt.customer_id
	CROSS JOIN max_dataset_date m

)

SELECT * FROM final