WITH customers AS (

	SELECT
		customer_id,
		customer_segment,
		acquisition_channel,
		is_active AS is_active_relationship

	FROM {{ ref('stg_customers') }}

),

activity AS (

	SELECT
		customer_id,
		last_transaction_date,
		days_since_last_transaction,
		is_inactive_90d

	FROM {{ ref('int_customer_activity') }}

),

products AS (

	SELECT
		customer_id,
		active_product_count,
		is_single_product_holder

	FROM {{ ref('int_customer_product_counts') }}

),

final AS (

	SELECT
		c.customer_id,
		c.customer_segment,
		c.acquisition_channel,
		c.is_active_relationship,
		a.last_transaction_date,
		a.days_since_last_transaction,
		a.is_inactive_90d,
		p.active_product_count,
		p.is_single_product_holder,
		CASE
			WHEN a.is_inactive_90d
				OR p.is_single_product_holder
				OR NOT c.is_active_relationship
			THEN true
			ELSE false
		END AS is_churn_risk,
		CASE
			WHEN a.is_inactive_90d AND p.is_single_product_holder AND NOT c.is_active_relationship
				THEN 'No activity 90d + single product + inactive status'
			WHEN a.is_inactive_90d AND p.is_single_product_holder
				THEN 'No activity 90d + single product'
			WHEN a.is_inactive_90d AND NOT c.is_active_relationship
				THEN 'No activity 90d + inactive status'
			WHEN p.is_single_product_holder AND NOT c.is_active_relationship
				THEN 'Single product + inactive status'
			WHEN a.is_inactive_90d
				THEN 'No activity in last 90 days'
			WHEN p.is_single_product_holder
				THEN 'Single product holder'
			WHEN NOT c.is_active_relationship
				THEN 'Inactive account status'
			ELSE 'Not at risk'
		END AS churn_risk_reason

	FROM customers c
	LEFT JOIN activity a
		ON c.customer_id = a.customer_id
	LEFT JOIN products p
		ON c.customer_id = p.customer_id

)

SELECT * FROM final
