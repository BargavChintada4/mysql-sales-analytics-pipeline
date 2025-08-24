End-to-End Sales Analysis & Customer Segmentation in MySQL
Project Overview
This project demonstrates a complete data analysis workflow using MySQL, transforming raw, messy sales data into actionable business insights. The primary goal is to conduct in-depth exploratory data analysis (EDA) and develop a robust customer segmentation model using the RFM (Recency, Frequency, Monetary) framework.

The project goes beyond simple querying to include crucial real-world steps such as data cleaning, automation through stored procedures, and performance optimization with indexing, showcasing a production-ready approach to data analysis.

Key Features & Analysis Performed
Data Cleaning & Transformation:

Handled and corrected complex data type issues, specifically converting non-standard integer dates (from an Excel format) into a standard SQL DATE format.

Enforced data integrity by modifying column types to appropriate formats (e.g., VARCHAR, DECIMAL).

In-Depth Exploratory Data Analysis (EDA):

Analyzed overall business performance, including total sales, unique customers, and sales distribution.

Identified top/bottom-performing products, regions, and managers.

Tracked sales performance over time with yearly and monthly trend analysis.

Investigated customer behavior, including purchase history and product return rates.

Advanced RFM Customer Segmentation:

Architected a sophisticated RFM model using advanced SQL features like Common Table Expressions (CTEs) and Window Functions (NTILE).

Iteratively developed and compared three distinct segmentation models to find the most effective way to group customers into actionable segments like "Champion Customers," "Loyal Customers," and "At Risk."

Automation & Performance Optimization:

Automated the analysis pipeline by creating Stored Procedures for repeatable tasks, such as retrieving a specific customer's history or running the entire RFM analysis for a given date.

Dramatically improved query performance by implementing strategic indexing on frequently queried columns (Customer ID, Order ID, Formated_Order_Date).

Used the EXPLAIN command to analyze and verify the efficiency gains from indexing.

Technical Skills Demonstrated
Database Management: Schema creation, data type management, bulk data importation.

Data Cleaning: Handling non-standard formats, data type conversion, ensuring data integrity.

Advanced SQL Querying: CTEs, Window Functions, Joins, Aggregations, Subqueries.

Data Modeling: Developing and iterating on a logical RFM segmentation framework.

Automation: Writing and implementing Stored Procedures for repeatable analysis.

Performance Tuning: Query analysis with EXPLAIN, creating and verifying database indexes.

Project Workflow
Setup & Ingestion:

A new database (sales_db) and a sales table were created.

The raw sales.csv dataset was imported into the table using MySQL Workbench's import wizard.

Cleaning & Preparation:

The Formated_Order_Date column was created and populated by converting the integer Order Date values.

Data types for key columns were modified to enforce constraints (NOT NULL, correct precision).

Analysis & Modeling:

A comprehensive suite of EDA queries was run to explore the data from multiple perspectives.

Three distinct RFM segmentation models were developed and stored as VIEWs for easy access and comparison.

Automation & Optimization:

The most critical analyses were encapsulated into Stored Procedures for easy execution.

Indexes were added to key columns, and their impact on query performance was measured and confirmed.

How to Use This Project
Setup Database: Create a new database in MySQL named sales_db.

Create Table: Run the CREATE TABLE script to create the sales table structure.

Import Data: Use the MySQL Workbench "Table Data Import Wizard" to import the sales.csv file into the newly created sales table.

Run Main Script: Execute the main SQL analysis script. This will:

Clean the data and create the Formated_Order_Date column.

Create the RFM analysis VIEWs.

Create the Stored Procedures.

Add the performance-enhancing indexes.

Execute Analysis:

Get a customer's history: CALL GetCustomerHistory(3);

Run a full segmentation: CALL RunRFMSegmentation('2013-12-31');
