-- Identify high-value customers who have:
-- - At least one funded savings plan (is_regular_savings = 1)
-- - At least one funded investment plan (is_a_fund = 1)
-- - A positive total confirmed deposit amount
-- The result is ordered by total deposits in descending order

WITH savings_plans AS (
    -- Get count of funded regular savings plans per customer
    SELECT 
        s.owner_id,
        COUNT(DISTINCT p.id) AS savings_count
    FROM 
        savings_savingsaccount s
    JOIN plans_plan p 
        ON s.plan_id = p.id
        AND p.is_regular_savings = 1
    WHERE 
        s.confirmed_amount > 0
    GROUP BY 
        s.owner_id
),

investment_plans AS (
    -- Get count of funded investment plans per customer
    SELECT 
        s.owner_id,
        COUNT(DISTINCT p.id) AS investment_count
    FROM 
        savings_savingsaccount s
    JOIN plans_plan p 
        ON s.plan_id = p.id
        AND p.is_a_fund = 1
    WHERE 
        s.confirmed_amount > 0
    GROUP BY 
        s.owner_id
),

total_deposits AS (
    -- Calculate total deposit amount per customer (converted from Kobo to Naira)
    SELECT 
        s.owner_id,
        SUM(s.confirmed_amount) / 100 AS total_deposits
    FROM 
        savings_savingsaccount s
    WHERE 
        s.confirmed_amount > 0
    GROUP BY 
        s.owner_id
)

-- Final result: customers with both savings and investment plans and their total deposits
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    sp.savings_count,
    ip.investment_count,
    td.total_deposits
FROM 
    users_customuser u
JOIN savings_plans sp 
    ON u.id = sp.owner_id
JOIN investment_plans ip 
    ON u.id = ip.owner_id
JOIN total_deposits td 
    ON u.id = td.owner_id
ORDER BY 
    td.total_deposits DESC;