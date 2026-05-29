WITH source AS (
    SELECT * FROM {{ source('thelook_raw', 'order_items') }}
)
SELECT
    CAST(id         AS STRING) AS order_item_id,
    CAST(order_id   AS STRING) AS order_id,
    CAST(product_id AS STRING) AS product_id,
    CAST(user_id    AS STRING) AS user_id,
    LOWER(TRIM(status))        AS status,
    ROUND(sale_price, 2)       AS sale_price,
    created_at,
    shipped_at,
    delivered_at,
    returned_at
FROM source
WHERE id IS NOT NULL
  AND sale_price >= 0
