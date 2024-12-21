WITH cohort_durations AS (
    SELECT
        DATE_TRUNC(CAST(subscription_started AS DATE), MONTH) AS cohort_month,
        DATE_DIFF(COALESCE(CAST(cancel_time AS DATE), CURRENT_DATE()), CAST(subscription_started AS DATE), MONTH) + 1 AS duration_months
    FROM
        `our-reason-346219.subscription_churn.churn`
),
max_duration AS (
    SELECT
        MAX(duration_months) AS max_months
    FROM
        cohort_durations
),
cohort_data AS (
    SELECT
        DATE_TRUNC(CAST(subscription_started AS DATE), MONTH) AS cohort_month,
        DATE_DIFF(COALESCE(CAST(cancel_time AS DATE), CURRENT_DATE()), CAST(subscription_started AS DATE), MONTH) + 1 AS duration_months
    FROM
        `our-reason-346219.subscription_churn.churn`
)

-- Construct the dynamic query
SELECT
    FORMAT_TIMESTAMP('%Y/%m', cohort_month) AS subscription_started,
    COUNTIF(duration_months >= 1) AS month_1,
    COUNTIF(duration_months >= 2) AS month_2,
    COUNTIF(duration_months >= 3) AS month_3,
    COUNTIF(duration_months >= 4) AS month_4,
    COUNTIF(duration_months >= 5) AS month_5,
    COUNTIF(duration_months >= 6) AS month_6,
    COUNTIF(duration_months >= 7) AS month_7,
    COUNTIF(duration_months >= 8) AS month_8,
    COUNTIF(duration_months >= 9) AS month_9,
    COUNTIF(duration_months >= 10) AS month_10,
    COUNTIF(duration_months >= 11) AS month_11,
    COUNTIF(duration_months >= 12) AS month_12
FROM
    cohort_data
GROUP BY
    cohort_month
ORDER BY
    cohort_month