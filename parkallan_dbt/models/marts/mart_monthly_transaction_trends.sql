WITH transactions_with_date AS (

	SELECT
		t.transaction_id,
		t.transaction_amount,
		d.year,
		d.month,
		d.month_name

	FROM {{ ref('stg_transactions') }} t
	INNER JOIN {{ ref('stg_date') }} d
		ON t.date_id = d.date_id

),

monthly AS (

	SELECT
		year,
		month,
		month_name,
		COUNT(*) AS transaction_count,
		SUM(transaction_amount) AS total_transaction_amount

	FROM transactions_with_date
	GROUP BY year, month, month_name

),

with_growth AS (

	SELECT
		year,
		month,
		month_name,
		transaction_count,
		total_transaction_amount,
		LAG(total_transaction_amount) OVER (ORDER BY year, month) AS prev_month_amount,
		ROUND(
			SAFE_DIVIDE(
				total_transaction_amount - LAG(total_transaction_amount) OVER (ORDER BY year, month),
				LAG(total_transaction_amount) OVER (ORDER BY year, month)
			) * 100,
			2
		) AS mom_growth_pct

	FROM monthly

)

SELECT * FROM with_growth
ORDER BY year, month
