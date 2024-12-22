WITH cohort_data AS (
    SELECT
        DATE_TRUNC(CAST(subscription_started AS DATE), MONTH) AS cohort_month,
        DATE_DIFF(
            LEAST(
                COALESCE(CAST(cancel_time AS DATE), CURRENT_DATE()),
                DATE_ADD(CAST(subscription_started AS DATE), INTERVAL subscription_duration MONTH)
            ),
            CAST(subscription_started AS DATE),
            MONTH
        ) + 1 AS duration_months
    FROM (
        SELECT
            subscription_started,
            cancel_time,
            subscription_plan_type,
            CASE
                WHEN subscription_plan_type = 'monthly' THEN 1
                WHEN subscription_plan_type = 'quarterly' THEN 3
                WHEN subscription_plan_type = 'semi_annual' THEN 6
                WHEN subscription_plan_type = 'annual' THEN 12
                WHEN subscription_plan_type IN ('single_course', 'lifetime') THEN 24
                WHEN subscription_plan_type = 'attachment_bootcamp' THEN 1
            END AS subscription_duration
        FROM
            `our-reason-346219.subscription_churn.churn`
    )
),
cohort_months AS (
    SELECT
        cohort_month,
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
)

-- Construct the final query
SELECT
    FORMAT_TIMESTAMP('%Y/%m', cohort_month) AS subscription_started,
    month_1,
    month_2,
    month_3,
    month_4,
    month_5,
    month_6,
    month_7,
    month_8,
    month_9,
    month_10,
    month_11,
    month_12
FROM
    cohort_months
ORDER BY
    cohort_month