with source as (

    select * from {{ source('parkallan_national_bank', 'fact_transactions') }}

),

renamed as (

    select
		transaction_id,
		account_id,
		customer_id,
		date_id,
		location_id,
		transaction_amount,
		transaction_type,
		transaction_category,
		merchant_name,
		merchant_category_code,
		channel,
		transaction_status,
		failure_reason,
		currency,
		exchange_rate,
		is_foreign,
		is_flagged

    from source

)

select * from renamed