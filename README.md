# DataAnalytics-Assessment

### ✅ Question 1: High-Value Customers with Multiple Products

**Objective:**  
Identify customers who have both a **funded savings plan** and a **funded investment plan**, and sort them by total deposits.

**Approach:**
- Joined `users_customuser`, `savings_savingsaccount`, and `plans_plan` using `owner_id`.
- Filtered for successful savings transactions using `transaction_status = 'success'`.
- Identified funded investment plans using `plan_type_id = 2` and `status_id = 1`.
- Counted distinct savings and investment plans per user.
- Summed `confirmed_amount` (from savings) and `amount` (from plans), and divided by 100 to convert from Kobo to Naira.
- Used `HAVING` to ensure each user had at least one of both product types.
- Sorted final result by total deposits in descending order.


### ✅ Question 2: Transaction Frequency Analysis

**Objective:**  
Categorize customers based on the **average number of transactions per month** into:  
- **High Frequency** (≥10/month)  
- **Medium Frequency** (3–9/month)  
- **Low Frequency** (≤2/month)

**Approach:**
- Counted total transactions for each user from `savings_savingsaccount`.
- Calculated tenure in months using `TIMESTAMPDIFF(MONTH, MIN(transaction_date), MAX(transaction_date))`.
- Computed average transactions per month.
- Used `CASE` logic to categorize each user.
- Grouped by frequency category to count users and compute overall averages.


### ✅ Question 3: Account Inactivity Alert

**Objective:**  
Find active savings or investment accounts that have had **no inflow transactions in the last 365 days**.

**Approach:**
- Extracted latest `transaction_date` for each savings account.
- Considered active plans using flags `is_regular_savings = 1` or `is_a_fund = 1`.
- Used `DATEDIFF(CURRENT_DATE, last_transaction_date)` to compute inactivity period.
- Filtered accounts with inactivity over 365 days.
- Returned plan/account info including inactivity days.


### ✅ Question 4: Customer Lifetime Value (CLV) Estimation

**Objective:**  
Estimate CLV using a simplified model:  
\[
\text{CLV} = \left(\frac{\text{total\_transactions}}{\text{tenure\_months}} \right) \times 12 \times \text{avg\_profit\_per\_transaction}
\]

**Approach:**
- Calculated `tenure_months` using `TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE)`.
- Counted all savings transactions with `confirmed_amount > 0`.
- Computed average profit per transaction as 0.1% of average transaction value.
- Applied CLV formula and used `ROUND` to format the result to 2 decimal places.
- Filtered out users with 0-month tenure to avoid division by zero.
- Ordered results by estimated CLV in descending order.

---

## ⚠️ Challenges

1. **Incorrect Status Matching in Savings Transactions:**
   - Initial assumption was that `transaction_status = 'funded'`.
   - Resolved by checking distinct values in the table and discovering `'success'` was the correct value.

2. **plan_type_id and status_id Values:**
   - At first, filters used `'investment'` and `'funded'` as string values.
   - Realized that both columns store **integers**, not descriptive strings.
   - Used `SELECT DISTINCT` to identify the correct numeric values for filtering.

3. **NULL Results and Misleading Joins:**
   - Early results returned only NULLs due to mismatches in JOIN logic and filters.
   - Solved by validating intermediate outputs and ensuring joins aligned with existing records and valid filter conditions.

4. **Kobo to Naira Conversion:**
   - All monetary values were in Kobo.
   - Added `/ 100` to convert to Naira and used `ROUND(..., 2)` to cleanly format final monetary results.
