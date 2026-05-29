WITH source AS (
    SELECT * FROM {{ source('thelook_raw', 'orders') }}
)
SELECT
    CAST(order_id AS STRING)   AS order_id,
    CAST(user_id  AS STRING)   AS user_id,
    LOWER(TRIM(status))        AS status,
    num_of_item,
    created_at,
    shipped_at,
    delivered_at,
    returned_at
FROM source
WHERE order_id IS NOT NULL
