WITH customers AS (

	SELECT
		customer_id,
		acquisition_channel,
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

joined AS (

	SELECT
		c.customer_id,
		c.acquisition_channel,
		c.is_active,
		COALESCE(b.total_active_balance, 0) AS total_active_balance,
		COALESCE(p.active_product_count, 0) AS active_product_count

	FROM customers c
	LEFT JOIN balances b
		ON c.customer_id = b.customer_id
	LEFT JOIN products p
		ON c.customer_id = p.customer_id

),

final AS (

	SELECT
		acquisition_channel,
		COUNT(*) AS total_customers,
		SUM(total_active_balance) AS total_balance,
		AVG(total_active_balance) AS avg_balance,
		AVG(active_product_count) AS avg_products_per_customer,
		ROUND(SAFE_DIVIDE(COUNTIF(is_active), COUNT(*)) * 100, 2) AS active_retention_rate_pct

	FROM joined
	GROUP BY acquisition_channel

)

SELECT * FROM final
