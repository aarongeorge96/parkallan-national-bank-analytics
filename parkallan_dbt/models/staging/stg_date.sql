with source as (

    select * from {{ source('parkallan_national_bank', 'dim_date') }}

),

renamed as (

    select
        date_id,
        full_date,
        day,
        month,
        month_name,
        quarter,
        year,
        day_of_week,
        is_weekend,
        is_canadian_holiday,
        fiscal_quarter

    from source

)

select * from renamed