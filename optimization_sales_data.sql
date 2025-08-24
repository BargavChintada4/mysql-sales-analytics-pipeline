USE sales_db;

-- ====================================================================
-- PART 1: CREATING STORED PROCEDURES
-- ====================================================================

-- Stored Procedure 1: Get Customer History
DELIMITER $$
CREATE PROCEDURE GetCustomerHistory(IN customerId INT)
BEGIN
    SELECT
        `Customer ID`,
        `Customer Name`,
        COUNT(*) AS Total_Items_Purchased,
        ROUND(SUM(Sales), 2) AS Total_Spent,
        ROUND(AVG(Sales), 2) AS Average_Sale_Value,
        MAX(Formated_Order_Date) AS Last_Purchase_Date
    FROM sales
    WHERE `Customer ID` = customerId
    GROUP BY `Customer ID`, `Customer Name`;
END$$
DELIMITER ;

-- HOW TO USE: CALL GetCustomerHistory(3);


-- Stored Procedure 2: Run Full RFM Segmentation Analysis
DELIMITER $$
CREATE PROCEDURE RunRFMSegmentation(IN analysisDate DATE)
BEGIN
    WITH CUSTOMER_AGGREGATED_DATA AS
    (
        SELECT
            `Customer ID`,
            `Customer Name`,
            DATEDIFF(analysisDate, MAX(Formated_Order_Date)) AS RECENCY_VALUE,
            COUNT(DISTINCT `Order ID`) AS FREQUENCY_VALUE,
            ROUND(SUM(Sales)) AS MONETARY_VALUE
        FROM SALES
        WHERE Formated_Order_Date <= analysisDate
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
        RS.*,
        CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) AS RFM_SCORE_COMBINATION,
        CASE
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('555', '554', '553') THEN 'Champion Customers'
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('552', '551', '543', '542') THEN 'Loyal Customers'
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('541', '532', '531') THEN 'Potential Loyalists'
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('535', '534', '533', '525') THEN 'Recent Customers - High Value'
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('524', '523', '515', '514', '513') THEN 'Recent Customers - Low Value'
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('512', '511', '421', '422') THEN 'Promising Customers'
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('423', '321', '322') THEN 'Need Attention'
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('311', '312', '313', '211', '212') THEN 'About to Sleep'
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('431', '432', '433', '331', '332') THEN 'At Risk'
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('221', '222', '223', '121', '122') THEN 'Lost Customers - High Value'
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('113', '112', '111') THEN 'Lost Customers - Low Value'
            WHEN CONCAT_WS('', R_SCORE, F_SCORE, M_SCORE) IN ('522', '533', '511') THEN 'Cannot Lose Them'
            ELSE 'Other'
        END AS CUSTOMER_SEGMENT
    FROM RFM_SCORE AS RS;
END$$
DELIMITER ;

-- HOW TO USE: CALL RunRFMSegmentation('2013-12-31');


-- ====================================================================
-- PART 2: PERFORMANCE OPTIMIZATION WITH INDEXING
-- ====================================================================

-- Analyze query performance BEFORE adding an index.
EXPLAIN SELECT * FROM sales WHERE `Customer ID` = 1008;

-- Add indexes to frequently queried columns to speed up data retrieval.
CREATE INDEX idx_customer_id ON sales(`Customer ID`);
CREATE INDEX idx_order_id ON sales(`Order ID`);
CREATE INDEX idx_order_date ON sales(Formated_Order_Date);

-- Analyze the SAME query's performance AFTER adding the index.
EXPLAIN SELECT * FROM sales WHERE `Customer ID` = 1008;
