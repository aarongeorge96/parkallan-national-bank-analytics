with source as (

    select * from {{ source('parkallan_national_bank', 'dim_location') }}

),

renamed as (

    select
        location_id,
		street_address,
		city,
		province,
		postal_code,
		region,
		neighborhood_income_tier,
		is_branch

    from source

)

select * from renamed