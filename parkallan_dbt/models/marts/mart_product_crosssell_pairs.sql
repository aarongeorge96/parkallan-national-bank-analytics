WITH active_customer_products AS (

	SELECT DISTINCT
		customer_id,
		product_id

	FROM {{ ref('stg_accounts') }}
	WHERE account_status = 'Active'

),

pairs AS (

	SELECT
		a.customer_id,
		a.product_id AS product_id_1,
		b.product_id AS product_id_2

	FROM active_customer_products a
	INNER JOIN active_customer_products b
		ON a.customer_id = b.customer_id
		AND a.product_id < b.product_id  -- avoids self-pairs and duplicate mirrored pairs

),

pair_counts AS (

	SELECT
		product_id_1,
		product_id_2,
		COUNT(DISTINCT customer_id) AS customer_count

	FROM pairs
	GROUP BY product_id_1, product_id_2

),

final AS (

	SELECT
		pc.product_id_1,
		p1.product_name AS product_1_name,
		pc.product_id_2,
		p2.product_name AS product_2_name,
		pc.customer_count

	FROM pair_counts pc
	INNER JOIN {{ ref('stg_products') }} p1
		ON pc.product_id_1 = p1.product_id
	INNER JOIN {{ ref('stg_products') }} p2
		ON pc.product_id_2 = p2.product_id

)

SELECT * FROM final
ORDER BY customer_count DESC
