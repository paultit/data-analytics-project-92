--Counting the total number of customers from the customers table 
SELECT COUNT(*) AS total_customers
FROM customers;

-- This SQL query generates a report on the top 10 performing salespeople.
-- It retrieves information about each salesperson, including their name,
-- the total number of transactions they conducted (operations), and the overall
-- revenue generated from the products they sold (income). The results are
-- sorted in descending order based on the total revenue.
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    COUNT(s.sales_person_id) AS operations,
    ROUND(SUM(s.quantity * p.price), 0) AS income
FROM
    employees e 
JOIN
    sales s ON e.employee_id = s.sales_person_id 
JOIN
    products p ON s.product_id = p.product_id 
GROUP BY
    e.first_name, e.last_name
ORDER BY
    income DESC
LIMIT 10;

-- This SQL query generates a report on salespeople whose average revenue per transaction
-- is less than the overall average revenue per transaction across all salespeople.
-- The query calculates the common average income for all sales and then compares
-- each salesperson's average income per transaction with this common average.
-- The results are sorted in ascending order based on the average income.

-- Common average income calculation
WITH common_avg_income AS (
    SELECT ROUND(AVG(sales.quantity * products.price), 0) AS com_avg_inc    
    FROM sales
    INNER JOIN products ON sales.product_id = products.product_id     
)
-- Main query to retrieve salespeople with below-average income per transaction
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    ROUND(AVG(s.quantity * p.price), 0) AS average_income
FROM
    employees e 
JOIN
    sales s ON e.employee_id = s.sales_person_id 
JOIN
    products p ON s.product_id = p.product_id
JOIN
    common_avg_income ON TRUE-- -- Temporary table included in the FROM clause
GROUP BY
    e.first_name, e.last_name, com_avg_inc
HAVING
    ROUND(AVG(s.quantity * p.price), 0) < com_avg_inc
ORDER BY
    average_income;
    
-- This SQL query generates a report on revenue by day of the week for each salesperson.
-- Each record includes the salesperson's name, the day of the week in English, and the total revenue.
-- The results are sorted by the ordinal number of the day of the week and the salesperson's name.

-- Common table expression to calculate salesperson-wise revenue per day
WITH sales_person AS (
WITH sales_person AS (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS name,
        s.sale_date AS sale_date,
        ROUND(SUM(s.quantity * p.price), 0) AS income
    FROM
        employees e 
    JOIN
        sales s ON e.employee_id = s.sales_person_id 
    JOIN
        products p ON s.product_id = p.product_id
    GROUP BY
        e.first_name, e.last_name, s.sale_date, TO_CHAR(s.sale_date, 'Day')    
)
-- Main query to retrieve revenue by day of the week for each salesperson
SELECT
    name,
    TO_CHAR(sale_date, 'Day') AS weekday,
    SUM(income) AS income
FROM
    sales_person
GROUP BY
    name, weekday, sale_date
ORDER BY
    CASE 
        WHEN EXTRACT(DOW FROM sale_date) = 1 THEN 1
        WHEN EXTRACT(DOW FROM sale_date) = 2 THEN 2
        WHEN EXTRACT(DOW FROM sale_date) = 3 THEN 3
        WHEN EXTRACT(DOW FROM sale_date) = 4 THEN 4
        WHEN EXTRACT(DOW FROM sale_date) = 5 THEN 5
        WHEN EXTRACT(DOW FROM sale_date) = 6 THEN 6
        WHEN EXTRACT(DOW FROM sale_date) = 0 THEN 7
    END,
    EXTRACT(WEEK FROM sale_date), name;    
