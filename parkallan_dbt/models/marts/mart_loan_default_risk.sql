WITH loans AS (

	SELECT
		loan_id,
		customer_id,
		location_id,
		credit_score_at_application,
		credit_score_band,
		loan_status,
		outstanding_balance,
		interest_rate,
		is_defaulted,
		is_delinquent,
		is_at_risk

	FROM {{ ref('int_loan_risk_flags') }}

),

locations AS (

	SELECT
		location_id,
		province,
		region

	FROM {{ ref('stg_location') }}

),

final AS (

	SELECT
		l.loan_id,
		l.customer_id,
		loc.province,
		loc.region,
		l.credit_score_at_application,
		l.credit_score_band,
		l.loan_status,
		l.outstanding_balance,
		l.interest_rate,
		l.is_defaulted,
		l.is_delinquent,
		l.is_at_risk

	FROM loans l
	LEFT JOIN locations loc
		ON l.location_id = loc.location_id

)

SELECT * FROM final
