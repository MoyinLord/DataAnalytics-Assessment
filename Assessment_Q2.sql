-- Step 1: Calculate the number of transactions each customer made per month
WITH monthly_transactions AS (
    SELECT 
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m-01') AS month_start, -- get the first day of each month
        COUNT(*) AS transactions
    FROM savings_savingsaccount
    GROUP BY owner_id, DATE_FORMAT(transaction_date, '%Y-%m-01')
),

-- Step 2: Compute the average transactions per month per customer
customer_avg AS (
    SELECT 
        owner_id,
        AVG(transactions) AS avg_transactions_per_month
    FROM monthly_transactions
    GROUP BY owner_id
)

-- Step 3: Classify customers based on average transaction frequency and compute aggregates
SELECT 
    CASE 
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM customer_avg
GROUP BY frequency_category
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;
