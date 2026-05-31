with source as (
    select * from {{ source('thelook_raw', 'distribution_centers') }}
),

cleaned as (
    select
        id          as distribution_center_id,
        name        as distribution_center_name,
        latitude,
        longitude
    from source
    where id is not null
)

select * from cleaned
