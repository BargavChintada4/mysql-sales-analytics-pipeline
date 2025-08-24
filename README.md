# End-to-End Sales Analysis & Customer Segmentation in MySQL

### Project Overview

This project demonstrates a complete, production-ready data analysis workflow using MySQL. It begins with raw, messy sales data and ends with an automated, performance-optimized pipeline that delivers actionable business insights. The core of the project involves in-depth Exploratory Data Analysis (EDA) and the development of a sophisticated RFM (Recency, Frequency, Monetary) customer segmentation model.

The implementation focuses on a realistic, end-to-end process:
1.  **Data Cleaning & Preparation**: Transforming raw data into a usable format.
2.  **Exploratory Data Analysis**: Uncovering trends and patterns within the data.
3.  **Advanced Segmentation**: Building and iterating on an RFM model to classify customers.
4.  **Automation & Optimization**: Encapsulating logic in Stored Procedures and improving query performance with strategic indexing.

---

### Key Features & Methodology

1.  **Dataset**: The project uses a real-world sales dataset (`sales.csv`) containing transactional data.

2.  **Data Cleaning and Transformation**:
    * A new `Formated_Order_Date` column was engineered by converting an integer-based Excel date format into a standard SQL `DATE` type using `DATE_ADD()`.
    * Data integrity was enforced by modifying key columns (`Order ID`, `Customer ID`, `Sales`) to appropriate data types and adding `NOT NULL` constraints.

3.  **Exploratory Data Analysis (EDA)**:
    * A comprehensive EDA was performed to understand the business from multiple angles, including:
        * Overall sales performance (total revenue, average sale, etc.).
        * Top and bottom customers by total spending.
        * Best and least-selling products.
        * Sales distribution by region and performance by manager.
        * Yearly and monthly sales trends.

4.  **RFM Customer Segmentation**:
    * A sophisticated RFM model was architected using advanced SQL features like **Common Table Expressions (CTEs)** and **Window Functions (`NTILE`)**.
    * The model calculates Recency, Frequency, and Monetary values for each customer and assigns them a score from 1-5 for each metric.
    * **Three distinct segmentation models** were iteratively developed using `CASE` statements to map RFM scores to actionable segments like `Champion Customers`, `Loyal Customers`, and `At Risk`.

5.  **Automation & Optimization**:
    * **Stored Procedures** were created to automate the analysis, allowing for repeatable execution of complex queries (e.g., getting a customer's history or running the full RFM analysis) with a single `CALL` statement.
    * **Strategic Indexing** was applied to frequently queried columns (`Customer ID`, `Order ID`, `Formated_Order_Date`). The `EXPLAIN` command was used to verify a significant reduction in rows scanned, proving a dramatic improvement in query performance.

---

### How to Run

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url>
    cd <your-repo-name>
    ```
2.  **Setup the Database:**
    * In MySQL Workbench, create a new database: `CREATE DATABASE sales_db;`
    * Create the `sales` table using the provided `CREATE TABLE` script.
    * Use the **Table Data Import Wizard** in MySQL Workbench to import `sales.csv` into the `sales` table.
3.  **Run the Main SQL Script:**
    * Execute the main analysis script (`analysis_and_automation.sql`). This will perform all data cleaning, create the RFM views, build the stored procedures, and add the indexes.
4.  **Execute Automated Analysis:**
    * To get a specific customer's history: `CALL GetCustomerHistory(3);`
    * To run the full RFM segmentation as of a specific date: `CALL RunRFMSegmentation('2013-12-31');`

---

### Key Outcomes

The project successfully transforms a raw dataset into a powerful, automated analysis tool. The key outcomes are:
* A **clean, reliable database** ready for analysis.
* **Actionable business insights** derived from a comprehensive EDA.
* A reusable and **iteratively developed RFM model** that provides a deep understanding of the customer base.
* An **efficient and scalable analysis pipeline** through the use of stored procedures and performance-tuned queries.
