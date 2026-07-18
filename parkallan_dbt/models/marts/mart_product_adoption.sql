WITH total_customers AS (

	SELECT COUNT(*) AS total_customer_count
	FROM {{ ref('stg_customers') }}

),

active_holders AS (

	SELECT
		a.product_id,
		COUNT(DISTINCT a.customer_id) AS holder_count

	FROM {{ ref('stg_accounts') }} a
	WHERE a.account_status = 'Active'
	GROUP BY a.product_id

),

final AS (

	SELECT
		p.product_id,
		p.product_name,
		p.product_category,
		COALESCE(h.holder_count, 0) AS holder_count,
		ROUND(SAFE_DIVIDE(COALESCE(h.holder_count, 0), tc.total_customer_count) * 100, 2) AS adoption_rate_pct

	FROM {{ ref('stg_products') }} p
	LEFT JOIN active_holders h
		ON p.product_id = h.product_id
	CROSS JOIN total_customers tc

)

SELECT * FROM final
