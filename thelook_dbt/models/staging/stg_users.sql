WITH source AS (
    SELECT * FROM {{ source('thelook_raw', 'users') }}
)
SELECT
    CAST(id AS STRING)         AS user_id,
    first_name,
    last_name,
    email,
    LOWER(TRIM(gender))        AS gender,
    age,
    TRIM(country)              AS country,
    TRIM(city)                 AS city,
    TRIM(state)                AS state,
    traffic_source,
    created_at
FROM source
WHERE id IS NOT NULL
  AND email IS NOT NULL
  AND age BETWEEN 18 AND 100
