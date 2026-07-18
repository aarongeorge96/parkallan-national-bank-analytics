with source as (

    select * from {{ source('parkallan_national_bank', 'dim_products') }}

),

renamed as (

    select
		product_id,
		product_name,
		product_category,
		product_type,
		is_credit,
		interest_rate_type,
		typical_term_months,
		risk_tier,
		min_income_required,
		is_registered,
		is_active_product,
		monthly_fee

    from source

)

select * from renamed