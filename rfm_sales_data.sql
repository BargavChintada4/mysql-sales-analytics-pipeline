-- ====================================================================
-- PHASE 1: SETUP AND DATA CLEANING
-- ====================================================================

-- CREATE DATABASE sales_db;
-- USE sales_db;
SET SQL_SAFE_UPDATES = 0; -- Disable safe mode to allow updates without a key in the WHERE clause.

-- Add a new column to store the correctly formatted date.
ALTER TABLE sales ADD COLUMN Formated_Order_Date DATE;

-- Convert the integer 'Order Date' (an Excel format) into a standard SQL DATE.
UPDATE sales
SET
    Formated_Order_Date = DATE_ADD('1899-12-30',
        INTERVAL `Order Date` DAY);

-- Enforce data integrity by modifying column types to prevent NULLs and set correct precision.
ALTER TABLE sales
MODIFY COLUMN `Order ID` VARCHAR(50) NOT NULL,
MODIFY COLUMN `Customer ID` VARCHAR(50) NOT NULL,
MODIFY COLUMN `Sales` DECIMAL(10,2) NOT NULL,
MODIFY COLUMN `Profit` DECIMAL(10,2) NOT NULL;

-- ====================================================================
-- PHASE 2: EXPLORATORY DATA ANALYSIS (EDA)
-- ====================================================================

-- Check for data quality issues like missing values and duplicates.
SELECT
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN Formated_Order_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Order_Date,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Missing_Sales,
    SUM(CASE WHEN `Customer ID` IS NULL THEN 1 ELSE 0 END) AS Missing_Customer_ID
FROM sales;

-- Analyze overall business metrics.
SELECT
    MIN(Sales) AS Min_Sales,
    MAX(Sales) AS Max_Sales,
    ROUND(AVG(Sales)) AS Avg_Sales,
    ROUND(SUM(Sales)) AS Total_Sales
FROM sales;

-- Analyze sales performance by various dimensions (Region, Manager, Time).
SELECT `Region`, COUNT(*) AS Total_Orders, ROUND(SUM(Sales), 2) AS Total_Sales
FROM sales
GROUP BY `Region`
ORDER BY Total_Sales DESC;

SELECT YEAR(Formated_Order_Date) AS Year, ROUND(SUM(Sales), 2) AS Total_Sales
FROM sales
GROUP BY Year
ORDER BY Year;

-- ====================================================================
-- PHASE 3: RFM (RECENCY, FREQUENCY, MONETARY) SEGMENTATION
-- ====================================================================

-- Create a reusable VIEW to calculate RFM scores for each customer.
CREATE OR REPLACE VIEW RFM_SCORE_DATA AS
WITH CUSTOMER_AGGREGATED_DATA AS -- CTE to calculate raw Recency, Frequency, and Monetary values.
(
    SELECT
        `Customer ID`,
        `Customer Name`,
        DATEDIFF((SELECT MAX(Formated_Order_Date) FROM sales), MAX(Formated_Order_Date)) AS RECENCY_VALUE,
        COUNT(DISTINCT `Order ID`) AS FREQUENCY_VALUE,
        ROUND(SUM(Sales)) AS MONETARY_VALUE
    FROM SALES
    GROUP BY `Customer ID`, `Customer Name`
),
RFM_SCORE AS -- CTE to assign scores (1-5) to each RFM value based on quintiles.
(
    SELECT
        CAD.*,
        NTILE(5) OVER (ORDER BY RECENCY_VALUE DESC) AS R_SCORE, -- Lower recency (more recent) gets a higher score.
        NTILE(5) OVER (ORDER BY FREQUENCY_VALUE ASC) AS F_SCORE,  -- Higher frequency gets a higher score.
        NTILE(5) OVER (ORDER BY MONETARY_VALUE ASC) AS M_SCORE   -- Higher monetary value gets a higher score.
    FROM CUSTOMER_AGGREGATED_DATA AS CAD
)
-- Final SELECT to combine scores for analysis.
SELECT
    RS.*,
    (R_SCORE + F_SCORE + M_SCORE) AS TOTAL_RFM_SCORE,
    CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) AS RFM_SCORE_COMBINATION
FROM RFM_SCORE AS RS;

-- Create a VIEW to apply the first segmentation logic model.
-- This model uses a detailed CASE statement to assign human-readable labels to customers.
CREATE OR REPLACE VIEW RFM_ANALYSIS AS
SELECT
    rfm_score_data.*,
    CASE
        WHEN R_SCORE = 5 AND F_SCORE = 5 AND M_SCORE = 5 THEN 'Champion Customers'
        WHEN R_SCORE >= 4 AND F_SCORE >= 4 AND M_SCORE >= 4 THEN 'Loyal Customers'
        WHEN R_SCORE >= 3 AND F_SCORE >= 4 AND M_SCORE >= 3 THEN 'Potential Loyalists'
        WHEN R_SCORE >= 4 AND F_SCORE <= 2 AND M_SCORE <= 2 THEN 'Recent Customers'
        WHEN R_SCORE <= 2 AND F_SCORE <= 2 AND M_SCORE <= 2 THEN 'At Risk'
        WHEN R_SCORE = 1 AND F_SCORE = 1 AND M_SCORE = 1 THEN 'Lost Customers'
        ELSE 'Other'
    END AS CUSTOMER_SEGMENT
FROM rfm_score_data;

-- Analyze the distribution of customers across the defined segments.
SELECT
	CUSTOMER_SEGMENT,
    COUNT(*) AS NUMBER_OF_CUSTOMERS,
    ROUND(AVG(MONETARY_VALUE),0) AS AVERAGE_MONETARY_VALUE
FROM RFM_ANALYSIS
GROUP BY CUSTOMER_SEGMENT;

-- Create a second VIEW for an alternative segmentation model.
-- This model uses specific RFM code combinations for different labeling logic.
CREATE OR REPLACE VIEW RFM_ANALYSIS2 AS
WITH CUSTOMER_AGGREGATED_DATA AS
(
    SELECT
        `Customer ID`,
        `Customer Name`,
        DATEDIFF((SELECT MAX(Formated_Order_Date) FROM sales), MAX(Formated_Order_Date)) AS RECENCY_VALUE,
        COUNT(DISTINCT `Order ID`) AS FREQUENCY_VALUE,
        ROUND(SUM(Sales)) AS MONETARY_VALUE
    FROM SALES
    GROUP BY `Customer ID`, `Customer Name`
),
RFM_SCORE AS
(
    SELECT
        CAD.*,
        NTILE(5) OVER (ORDER BY RECENCY_VALUE DESC) AS R_SCORE,
        NTILE(5) OVER (ORDER BY FREQUENCY_VALUE ASC) AS F_SCORE,
        NTILE(5) OVER (ORDER BY MONETARY_VALUE ASC) AS M_SCORE
    FROM CUSTOMER_AGGREGATED_DATA AS CAD
)
SELECT
    RS.* ,
    CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) AS RFM_SCORE_COMBINATION,
    CASE
        WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('555', '554', '553', '552', '551') THEN 'Champion Customers'
        WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('543', '542', '541', '532', '531') THEN 'Loyal Customers'
        WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('221', '222', '223', '121', '122') THEN 'At Risk'
        WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('113', '112', '111') THEN 'Lost Customers'
        ELSE 'Other'
    END AS CUSTOMER_SEGMENT2
FROM RFM_SCORE AS RS;

-- Analyze the results of the second segmentation model.
SELECT
	CUSTOMER_SEGMENT2,
    COUNT(*) AS NUMBER_OF_CUSTOMERS,
    ROUND(AVG(MONETARY_VALUE),0) AS AVERAGE_MONETARY_VALUE
FROM RFM_ANALYSIS2
GROUP BY CUSTOMER_SEGMENT2;
