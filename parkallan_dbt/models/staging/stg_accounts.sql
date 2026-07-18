with source as (

    select * from {{ source('parkallan_national_bank', 'fact_accounts') }}

),

renamed as (

    select
		account_id,
		customer_id,
		product_id,
		location_id,
		open_date_id,
		close_date_id,
		account_status,
		current_balance,
		credit_limit,
		original_amount,
		relationship_manager_id,
		overdraft_limit,
		last_activity_date

    from source

)

select * from renamed