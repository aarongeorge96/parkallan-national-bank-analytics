with source as (

    select * from {{ source('parkallan_national_bank', 'dim_customers') }}

),

renamed as (

    select
        customer_id,
        first_name,
        last_name,
        dob as date_of_birth,
        gender,
        sin,
        phone,
        email,
        occupation,
        income_bracket,
        customer_segment,
        acquisition_channel,
        location_id,
        created_at,
        is_active

    from source

)

select * from renamed