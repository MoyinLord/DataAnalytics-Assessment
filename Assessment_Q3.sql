-- Identify plans (savings or investment) with no inflow transactions in the last 365 days.
-- This query uses UNION to combine savings and investment inactivity results.

-- Step 1: Inactive savings plans
SELECT 
    s.id AS plan_id,                                 
    s.owner_id,                                     
    'Savings' AS type,                               
    MAX(s.transaction_date) AS last_transaction_date, 
    DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) AS inactivity_days 
FROM 
    savings_savingsaccount s
WHERE 
    s.confirmed_amount > 0                                              
    AND s.transaction_date < DATE_SUB(CURRENT_DATE, INTERVAL 365 DAY)   
GROUP BY 
    s.id, s.owner_id

UNION ALL

-- Step 2: Inactive investment plans
SELECT 
    p.id AS plan_id,                                      
    p.owner_id,                                           
    'Investment' AS type,                                 
    MAX(p.last_charge_date) AS last_transaction_date,    
    DATEDIFF(CURRENT_DATE, MAX(p.last_charge_date)) AS inactivity_days 
FROM 
    plans_plan p
WHERE 
    p.amount > 0                                          
    AND p.is_a_fund = 1                                    
    AND p.last_charge_date < DATE_SUB(CURRENT_DATE, INTERVAL 365 DAY) 
GROUP BY 
    p.id, p.owner_id

-- Sort the entire result by inactivity duration (most inactive first)
ORDER BY 
    inactivity_days DESC;
