with source as (

    select * from {{ source('parkallan_national_bank', 'fact_loans') }}

),

renamed as (

    select
		loan_id,
		customer_id,
		product_id,
		location_id,
		application_date_id,
		approval_date_id,
		loan_amount_requested,
		loan_amount_approved,
		approval_status,
		rejection_reason,
		interest_rate,
		interest_rate_type,
		loan_term_months,
		monthly_payment,
		outstanding_balance,
		total_paid,
		is_secured,
		collateral_type,
		collateral_value,
		credit_score_at_application,
		loan_status,
		missed_payments_count,
		days_past_due

    from source

)

select * from renamed