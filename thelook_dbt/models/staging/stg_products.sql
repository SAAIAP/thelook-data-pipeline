WITH source AS (
    SELECT * FROM {{ source('thelook_raw', 'products') }}
)
SELECT
    CAST(id AS STRING)                                           AS product_id,
    TRIM(name)                                                   AS name,
    TRIM(category)                                               AS category,
    TRIM(brand)                                                  AS brand,
    TRIM(department)                                             AS department,
    ROUND(cost, 2)                                               AS cost,
    ROUND(retail_price, 2)                                       AS retail_price,
    ROUND(SAFE_DIVIDE(retail_price - cost, retail_price), 4)     AS margin_pct
FROM source
WHERE id IS NOT NULL
  AND retail_price > 0
  AND cost > 0
