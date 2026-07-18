WITH customers AS (

	SELECT customer_id FROM {{ ref('stg_customers') }}

),

accounts AS (

	SELECT
		customer_id,
		product_id,
		account_status

	FROM {{ ref('stg_accounts') }}

),

customer_products AS (

	SELECT
		customer_id,
		COUNT(DISTINCT product_id) AS total_product_count,
		COUNT(DISTINCT CASE WHEN account_status = 'Active' THEN product_id END) AS active_product_count

	FROM accounts
	GROUP BY customer_id

),

final AS (

	SELECT
		c.customer_id,
		COALESCE(cp.total_product_count, 0) AS total_product_count,
		COALESCE(cp.active_product_count, 0) AS active_product_count,
		CASE
			WHEN COALESCE(cp.active_product_count, 0) <= 1 THEN true
			ELSE false
		END AS is_single_product_holder

	FROM customers c
	LEFT JOIN customer_products cp
		ON c.customer_id = cp.customer_id

)

SELECT * FROM final