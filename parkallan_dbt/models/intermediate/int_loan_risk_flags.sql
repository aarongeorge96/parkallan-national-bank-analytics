WITH approved_loans AS (

	SELECT
		loan_id,
		customer_id,
		product_id,
		location_id,
		credit_score_at_application,
		loan_status,
		outstanding_balance,
		days_past_due,
		interest_rate

	FROM {{ ref('stg_loans') }}
	WHERE approval_status = 'Approved'

),

final AS (

	SELECT
		loan_id,
		customer_id,
		product_id,
		location_id,
		credit_score_at_application,
		loan_status,
		outstanding_balance,
		days_past_due,
		interest_rate,
		CASE
			WHEN credit_score_at_application < 580 THEN 'Poor'
			WHEN credit_score_at_application < 670 THEN 'Fair'
			WHEN credit_score_at_application < 740 THEN 'Good'
			WHEN credit_score_at_application < 800 THEN 'Very Good'
			ELSE 'Excellent'
		END AS credit_score_band,
		CASE WHEN loan_status = 'Defaulted' THEN true ELSE false END AS is_defaulted,
		CASE WHEN loan_status = 'Delinquent' THEN true ELSE false END AS is_delinquent,
		CASE WHEN loan_status IN ('Defaulted', 'Delinquent') THEN true ELSE false END AS is_at_risk

	FROM approved_loans

)

SELECT * FROM final
