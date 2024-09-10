-- SQL RETAIL SALES ANALYSIS

--CREATE DATABASE
CREATE DATABASE sql_practice_project1;

-- CREATE TABLE
CREATE TABLE retail_sales
  (
	transactions_id	INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id	INT,
	gender VARCHAR(15),
	age	INT,
	category VARCHAR(15),
	quantity	INT,
	price_per_unit FLOAT,	
	cogs FLOAT,
	total_sale FLOAT
  );

-- SAMPLE DATA SELECTION
SELECT * FROM retail_sales
LIMIT 10;

SELECT COUNT(*) FROM retail_sales;


-- DATA CLEANING

--TO CHECK NULL VALUES COLUMN WISE
SELECT * FROM retail_sales
WHERE sale_time is NULL;

SELECT * FROM retail_sales
WHERE transactions_id IS NULL
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL
OR age IS NULL
OR category IS NULL
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL;

DELETE FROM retail_sales
WHERE transactions_id IS NULL
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL
OR age IS NULL
OR category IS NULL
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL;

-- DATA EXPLORATION

-- How many sales we have?
SELECT COUNT(*) AS total_sales FROM retail_sales;

-- How many unique customers we have?
SELECT COUNT(DISTINCT customer_id) as unique_customers FROM retail_sales;

-- How many categories we have?
--count distinct categories
SELECT COUNT(DISTINCT category) as categories FROM retail_sales;

-- displays the categories
SELECT DISTINCT category FROM retail_sales;


-- DATA ANALYSIS

-- [Beginner Level]
-- Q1: Write a SQL query to retrieve all columns for sales made on '2022-11-05'
SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q2: Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT *
FROM retail_sales
WHERE 
    category = 'Clothing' 
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4;

-- Q3: How many sales we have?
SELECT COUNT(*) AS total_sales 
FROM retail_sales;

-- Q4: How many unique customers we have?
SELECT COUNT(DISTINCT customer_id) AS unique_customers 
FROM retail_sales;

-- Q5: Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * 
FROM retail_sales
WHERE total_sale > 1000;


-- [Intermediate Level]
-- Q6: Write a SQL query to calculate the total_sales for each category.
SELECT category, SUM(total_sale) AS total_sales, COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;

-- Q7: Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT ROUND(AVG(age)) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q8: Write a SQL query to find the total revenue generated by each gender.
SELECT 
    gender, 
    SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY gender;

-- Q9: Write a SQL query to find the average price_per_unit for each category.
SELECT 
    category, 
    ROUND(AVG(price_per_unit)::numeric, 2) AS avg_price_per_unit
FROM retail_sales
WHERE price_per_unit IS NOT NULL
GROUP BY category;

-- Q10: Write a SQL query to find transactions where cogs (Cost of Goods Sold) is greater than total_sale.
SELECT *
FROM retail_sales
WHERE cogs > total_sale;


-- [Advanced Level]
-- Q11: Write a SQL query to find the top 5 customers based on the highest total sales.
SELECT
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q12: Write a SQL query to determine the total quantity of items sold per age group (e.g., below 20, 20-40, 40-60, above 60).
SELECT 
    CASE 
        WHEN age < 20 THEN 'Below 20'
        WHEN age BETWEEN 20 AND 40 THEN '20-40'
        WHEN age BETWEEN 40 AND 60 THEN '40-60'
        ELSE 'Above 60'
    END AS age_group,
    SUM(quantity) AS total_quantity
FROM retail_sales
GROUP BY age_group;

-- Q13: Write a SQL query to find the total number of transactions made by each gender in each category.
SELECT category, gender, COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY 1, 2
ORDER BY 1;

-- Q14: Write a SQL query to find the most common age group among customers who made purchases in the 'Electronics' category.
SELECT 
    CASE 
        WHEN age < 20 THEN 'Below 20'
        WHEN age BETWEEN 20 AND 40 THEN '20-40'
        WHEN age BETWEEN 40 AND 60 THEN '40-60'
        ELSE 'Above 60'
    END AS age_group,
    COUNT(*) AS customer_count
FROM retail_sales
WHERE category = 'Electronics'
GROUP BY age_group
ORDER BY customer_count DESC
LIMIT 1;

-- Q15: Write a SQL query to calculate the average sale for each month. Find out the best-selling month in each year.
SELECT year, month, avg_sale
FROM
(
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
    FROM retail_sales
    GROUP BY 1, 2
) AS t1
WHERE rank = 1;

-- Q16: Write a SQL query to find the top 3 categories with the highest average sales per transaction.
SELECT 
    category, 
    ROUND(AVG(total_sale)::numeric, 2) AS avg_sales
FROM retail_sales
GROUP BY category
ORDER BY avg_sales DESC
LIMIT 3;

-- Q17: Write a SQL query to calculate the percentage of total sales made by male customers.
SELECT 
    ROUND(
        (SUM(CASE WHEN gender = 'Male' THEN total_sale ELSE 0 END) / NULLIF(SUM(total_sale), 0))::numeric * 100, 2
    ) AS male_sales_percentage
FROM retail_sales;


-- Q18: Write a SQL query to identify which day of the week had the highest total sales.
SELECT 
    TO_CHAR(sale_date, 'Day') AS day_of_week,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY day_of_week
ORDER BY total_sales DESC
LIMIT 1;

-- Q19: Write a SQL query to find the total cogs (Cost of Goods Sold) for each month and year.
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    SUM(cogs) AS total_cogs
FROM retail_sales
GROUP BY year, month
ORDER BY year, month;

-- Q20: Write a SQL query to create each shift and number of orders (e.g., morning < 12, afternoon between 12 & 17, evening > 17).
WITH hourly_sale AS
(
    SELECT *,
        CASE 
             WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
             WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
             ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;
