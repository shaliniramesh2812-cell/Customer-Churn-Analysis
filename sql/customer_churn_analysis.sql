
-- =====================================================
-- PROJECT: CUSTOMER CHURN ANALYSIS
-- DOMAIN: TELECOMMUNICATIONS
-- TOOL: GOOGLE BIGQUERY (SQL)
-- DATASET: IBM TELCO CUSTOMER CHURN
-- =====================================================

-- PROJECT OBJECTIVE:
-- Analyze customer churn patterns to identify
-- factors associated with customer attrition.
-- Explore customer contracts, tenure, monthly charges,
-- internet services, and payment methods.

-- TABLE:
-- customer-churn-sql.churn_analysis.telco_customers

-- =====================================================
-- SECTION 1: DATA OVERVIEW
-- =====================================================

-- 1.1 View the first 10 customer records

SELECT *
FROM `customer-churn-sql.churn_analysis.telco_customers`
LIMIT 10;


-- 1.2 Count total customers

SELECT
    COUNT(*) AS total_customers
FROM `customer-churn-sql.churn_analysis.telco_customers`;


-- 1.3 Check for duplicate customer IDs

SELECT
    customerID,
    COUNT(*) AS record_count
FROM `customer-churn-sql.churn_analysis.telco_customers`
GROUP BY customerID
HAVING COUNT(*) > 1;



-- =====================================================
-- SECTION 2: OVERALL CUSTOMER CHURN ANALYSIS
-- =====================================================

-- 2.1 Calculate total, churned, and retained customers
--     and the overall churn rate

SELECT
    COUNT(*) AS total_customers,
    COUNTIF(Churn = TRUE) AS churned_customers,
    COUNTIF(Churn = FALSE) AS retained_customers,
    ROUND(
        SAFE_DIVIDE(
            COUNTIF(Churn = TRUE),
            COUNT(*)
        ) * 100, 2
    ) AS churn_rate_percentage
FROM `customer-churn-sql.churn_analysis.telco_customers`;


-- 2.2 Calculate churn percentage by contract type

SELECT
    Contract,
    COUNT(*) AS total_customers,
    COUNTIF(Churn = TRUE) AS churned_customers,
    ROUND(
        SAFE_DIVIDE(COUNTIF(Churn = TRUE), COUNT(*)) * 100,
        2
    ) AS churn_rate
FROM `customer-churn-sql.churn_analysis.telco_customers`
GROUP BY Contract
ORDER BY churn_rate DESC;



-- =====================================================
-- SECTION 3: CUSTOMER BEHAVIOUR ANALYSIS
-- =====================================================

-- 3.1 Average monthly charges by churn status

SELECT
    Churn,
    COUNT(*) AS total_customers,
    ROUND(AVG(MonthlyCharges), 2) AS average_monthly_charge
FROM `customer-churn-sql.churn_analysis.telco_customers`
GROUP BY Churn;


-- 3.2 Average tenure by churn status

SELECT
    Churn,
    COUNT(*) AS total_customers,
    ROUND(AVG(tenure), 2) AS average_tenure_months
FROM `customer-churn-sql.churn_analysis.telco_customers`
GROUP BY Churn;


-- 3.3 Churn analysis by payment method

SELECT
    PaymentMethod,
    COUNT(*) AS total_customers,
    COUNTIF(Churn = TRUE) AS churned_customers,
    ROUND(
        SAFE_DIVIDE(COUNTIF(Churn = TRUE), COUNT(*)) * 100,
        2
    ) AS churn_rate
FROM `customer-churn-sql.churn_analysis.telco_customers`
GROUP BY PaymentMethod
ORDER BY churn_rate DESC;


-- 3.4 Churn analysis by internet service

SELECT
    InternetService,
    COUNT(*) AS total_customers,
    COUNTIF(Churn = TRUE) AS churned_customers,
    ROUND(
        SAFE_DIVIDE(COUNTIF(Churn = TRUE), COUNT(*)) * 100,
        2
    ) AS churn_rate
FROM `customer-churn-sql.churn_analysis.telco_customers`
GROUP BY InternetService
ORDER BY churn_rate DESC;


-- 3.5 Churn analysis by senior citizen status

SELECT
    SeniorCitizen,
    COUNT(*) AS total_customers,
    COUNTIF(Churn = TRUE) AS churned_customers,
    ROUND(
        SAFE_DIVIDE(COUNTIF(Churn = TRUE), COUNT(*)) * 100,
        2
    ) AS churn_rate
FROM `customer-churn-sql.churn_analysis.telco_customers`
GROUP BY SeniorCitizen
ORDER BY churn_rate DESC;


-- 3.6 Churn analysis by paperless billing

SELECT
    PaperlessBilling,
    COUNT(*) AS total_customers,
    COUNTIF(Churn = TRUE) AS churned_customers,
    ROUND(
        SAFE_DIVIDE(COUNTIF(Churn = TRUE), COUNT(*)) * 100,
        2
    ) AS churn_rate
FROM `customer-churn-sql.churn_analysis.telco_customers`
GROUP BY PaperlessBilling
ORDER BY churn_rate DESC;




-- =====================================================
-- SECTION 4: ADVANCED CUSTOMER SEGMENTATION
-- =====================================================

-- 4.1 Classify customers based on tenure

SELECT
    customerID,
    tenure,
    CASE
        WHEN tenure <= 12 THEN 'New Customer'
        WHEN tenure <= 48 THEN 'Medium-Term Customer'
        ELSE 'Long-Term Customer'
    END AS customer_category,
    Churn
FROM `customer-churn-sql.churn_analysis.telco_customers`
LIMIT 20;


-- 4.2 Calculate churn rate by customer category

SELECT
    CASE
        WHEN tenure <= 12 THEN 'New Customer'
        WHEN tenure <= 48 THEN 'Medium-Term Customer'
        ELSE 'Long-Term Customer'
    END AS customer_category,
    COUNT(*) AS total_customers,
    COUNTIF(Churn = TRUE) AS churned_customers,
    ROUND(
        SAFE_DIVIDE(COUNTIF(Churn = TRUE), COUNT(*)) * 100,
        2
    ) AS churn_rate
FROM `customer-churn-sql.churn_analysis.telco_customers`
GROUP BY customer_category
ORDER BY churn_rate DESC;


-- 4.3 Identify high-risk customer segments

SELECT
    Contract,
    InternetService,
    PaymentMethod,
    COUNT(*) AS total_customers,
    COUNTIF(Churn = TRUE) AS churned_customers,
    ROUND(
        SAFE_DIVIDE(COUNTIF(Churn = TRUE), COUNT(*)) * 100,
        2
    ) AS churn_rate
FROM `customer-churn-sql.churn_analysis.telco_customers`
GROUP BY Contract, InternetService, PaymentMethod
HAVING COUNT(*) >= 50
ORDER BY churn_rate DESC;



-- =====================================================
-- SECTION 5: SUBQUERY ANALYSIS
-- =====================================================

-- 5.1 Identify customers whose monthly charges
--     are above the overall average

SELECT
    customerID,
    Contract,
    MonthlyCharges,
    Churn
FROM `customer-churn-sql.churn_analysis.telco_customers`
WHERE MonthlyCharges > (
    SELECT AVG(MonthlyCharges)
    FROM `customer-churn-sql.churn_analysis.telco_customers`
)
ORDER BY MonthlyCharges DESC
LIMIT 20;


-- 5.2 Identify customers whose monthly charges
--     are above their own contract's average

SELECT
    customerID,
    Contract,
    MonthlyCharges,
    Churn
FROM `customer-churn-sql.churn_analysis.telco_customers` AS t
WHERE MonthlyCharges > (
    SELECT AVG(MonthlyCharges)
    FROM `customer-churn-sql.churn_analysis.telco_customers` AS s
    WHERE s.Contract = t.Contract
)
ORDER BY Contract, MonthlyCharges DESC
LIMIT 20;


-- 5.3 Identify the top 10 highest-paying
--     customers who have churned

SELECT
    customerID,
    Contract,
    tenure,
    MonthlyCharges,
    Churn
FROM `customer-churn-sql.churn_analysis.telco_customers`
WHERE Churn = TRUE
ORDER BY MonthlyCharges DESC
LIMIT 10;



-- =====================================================
-- SECTION 6: CTEs AND WINDOW FUNCTIONS
-- =====================================================

-- 6.1 Use a CTE to classify customers by tenure

WITH customer_data AS (
    SELECT
        customerID,
        tenure,
        Churn,
        CASE
            WHEN tenure <= 12 THEN 'New Customer'
            WHEN tenure <= 48 THEN 'Medium-Term Customer'
            ELSE 'Long-Term Customer'
        END AS customer_category
    FROM `customer-churn-sql.churn_analysis.telco_customers`
)

SELECT
    customer_category,
    COUNT(*) AS total_customers,
    COUNTIF(Churn = TRUE) AS churned_customers,
    ROUND(
        SAFE_DIVIDE(COUNTIF(Churn = TRUE), COUNT(*)) * 100,
        2
    ) AS churn_rate
FROM customer_data
GROUP BY customer_category
ORDER BY churn_rate DESC;


-- 6.2 Rank customer categories by churn rate

WITH customer_data AS (
    SELECT
        tenure,
        Churn,
        CASE
            WHEN tenure <= 12 THEN 'New Customer'
            WHEN tenure <= 48 THEN 'Medium-Term Customer'
            ELSE 'Long-Term Customer'
        END AS customer_category
    FROM `customer-churn-sql.churn_analysis.telco_customers`
),

churn_summary AS (
    SELECT
        customer_category,
        ROUND(
            SAFE_DIVIDE(COUNTIF(Churn = TRUE), COUNT(*)) * 100,
            2
        ) AS churn_rate
    FROM customer_data
    GROUP BY customer_category
)

SELECT
    customer_category,
    churn_rate,
    RANK() OVER (ORDER BY churn_rate DESC) AS churn_rank
FROM churn_summary;


-- 6.3 Assign row numbers based on customer tenure

SELECT
    customerID,
    tenure,
    Churn,
    ROW_NUMBER() OVER (
        ORDER BY tenure DESC
    ) AS customer_number
FROM `customer-churn-sql.churn_analysis.telco_customers`
LIMIT 20;


-- 6.4 Compare RANK, DENSE_RANK and ROW_NUMBER

SELECT
    customerID,
    tenure,
    RANK() OVER (ORDER BY tenure DESC) AS rank_number,
    DENSE_RANK() OVER (ORDER BY tenure DESC) AS dense_rank_number,
    ROW_NUMBER() OVER (ORDER BY tenure DESC) AS row_number
FROM `customer-churn-sql.churn_analysis.telco_customers`
LIMIT 20;


-- 6.5 Rank customers separately within each contract type

SELECT
    customerID,
    Contract,
    tenure,
    Churn,
    ROW_NUMBER() OVER (
        PARTITION BY Contract
        ORDER BY tenure DESC
    ) AS customer_rank
FROM `customer-churn-sql.churn_analysis.telco_customers`
ORDER BY Contract, customer_rank
LIMIT 30;


-- 6.6 Calculate average monthly charges within each contract

SELECT
    customerID,
    Contract,
    MonthlyCharges,
    ROUND(
        AVG(MonthlyCharges) OVER (
            PARTITION BY Contract
        ), 2
    ) AS avg_charge_by_contract
FROM `customer-churn-sql.churn_analysis.telco_customers`
ORDER BY Contract
LIMIT 20;


-- 6.7 Compare customer tenure with the previous customer

SELECT
    customerID,
    tenure,
    LAG(tenure) OVER (
        ORDER BY tenure DESC
    ) AS previous_customer_tenure
FROM `customer-churn-sql.churn_analysis.telco_customers`
LIMIT 20;


-- 6.8 Compare customer tenure with the next customer

SELECT
    customerID,
    tenure,
    LEAD(tenure) OVER (
        ORDER BY tenure DESC
    ) AS next_customer_tenure
FROM `customer-churn-sql.churn_analysis.telco_customers`
LIMIT 20;



-- =====================================================
-- SECTION 7: TABLE JOINS
-- =====================================================

-- 7.1 INNER JOIN
-- Return only records with matching customer IDs

SELECT
    t.customerID,
    t.Contract,
    t.MonthlyCharges,
    s.tenure,
    s.Churn
FROM `customer-churn-sql.churn_analysis.telco_customers` AS t
INNER JOIN `customer-churn-sql.churn_analysis.customer_summary` AS s
ON t.customerID = s.customerID
LIMIT 20;


-- 7.2 LEFT JOIN
-- Keep all records from the main customer table

SELECT
    t.customerID,
    t.Contract,
    s.tenure,
    s.Churn
FROM `customer-churn-sql.churn_analysis.telco_customers` AS t
LEFT JOIN `customer-churn-sql.churn_analysis.customer_summary` AS s
ON t.customerID = s.customerID
LIMIT 20;


-- 7.3 RIGHT JOIN
-- Keep all records from the customer summary table

SELECT
    t.customerID,
    t.Contract,
    s.tenure,
    s.Churn
FROM `customer-churn-sql.churn_analysis.telco_customers` AS t
RIGHT JOIN `customer-churn-sql.churn_analysis.customer_summary` AS s
ON t.customerID = s.customerID
LIMIT 20;


-- 7.4 FULL OUTER JOIN
-- Keep all records from both tables

SELECT
    t.customerID,
    t.Contract,
    s.tenure,
    s.Churn
FROM `customer-churn-sql.churn_analysis.telco_customers` AS t
FULL OUTER JOIN `customer-churn-sql.churn_analysis.customer_summary` AS s
ON t.customerID = s.customerID
LIMIT 20;
