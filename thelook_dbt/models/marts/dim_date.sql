SELECT
    CAST(FORMAT_DATE('%Y%m%d', d) AS INT64)                          AS date_key,
    d                                                                  AS full_date,
    EXTRACT(YEAR    FROM d)                                            AS year,
    EXTRACT(QUARTER FROM d)                                            AS quarter,
    EXTRACT(MONTH   FROM d)                                            AS month,
    FORMAT_DATE('%B', d)                                               AS month_name,
    FORMAT_DATE('%b', d)                                               AS month_short,
    EXTRACT(WEEK    FROM d)                                            AS week,
    EXTRACT(DAY     FROM d)                                            AS day_of_month,
    FORMAT_DATE('%A', d)                                               AS day_name,
    CASE WHEN EXTRACT(DAYOFWEEK FROM d) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend
FROM UNNEST(
    GENERATE_DATE_ARRAY('2019-01-01', '2026-12-31', INTERVAL 1 DAY)
) AS d
