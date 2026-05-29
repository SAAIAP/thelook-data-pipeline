SELECT
    product_id   AS product_key,
    product_id,
    name,
    category,
    brand,
    department,
    cost,
    retail_price,
    margin_pct,
    CASE
        WHEN retail_price < 20   THEN 'Budget'
        WHEN retail_price < 100  THEN 'Mid-range'
        WHEN retail_price < 300  THEN 'Premium'
        ELSE 'Luxury'
    END          AS price_tier
FROM {{ ref('stg_products') }}
