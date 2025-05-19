-- Estimate Customer Lifetime Value (CLV) based on transaction volume and account tenure
-- Formula: (total_transactions / tenure_in_months) * 12 * avg_profit_per_transaction

SELECT 
    u.id AS customer_id,
    u.name,
    
    -- Calculate the number of months since the user joined
    TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE()) AS tenure_months,

    -- Count of all successful transactions made by the customer
    COUNT(s.id) AS total_transactions,

    -- Estimated CLV calculation:
    -- Normalize transaction rate per month, multiply by 12 (annualized),
    -- then by average profit per transaction (0.1% of average transaction value)
    ROUND(
        (COUNT(s.id) / 
        GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE()), 1)) * 
        12 * 
        (0.001 * COALESCE(SUM(s.confirmed_amount), 0) / GREATEST(COUNT(s.id), 1)),
        2
    ) AS estimated_clv

FROM 
    users_customuser u

-- Join with savings transactions where confirmed_amount > 0
LEFT JOIN 
    savings_savingsaccount s 
    ON u.id = s.owner_id AND s.confirmed_amount > 0

GROUP BY 
    u.id, u.name, u.date_joined

-- Exclude users with zero-month tenure to avoid division by zero
HAVING 
    TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE()) > 0

ORDER BY 
    estimated_clv DESC;