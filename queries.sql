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
    
-- This query categorizes customers into different age groups and counts the number of customers in each group.
SELECT
    age_category, -- Display the age category in the result
    COUNT(*) AS count  -- Count the number of customers in each age category
FROM (
    SELECT
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            ELSE '40+'
        END AS age_category
    FROM
        customers
) AS age_groups
GROUP BY
    age_category -- Group the results by age category
ORDER BY
    CASE
        WHEN age_category = '16-25' THEN 1
        WHEN age_category = '26-40' THEN 2
        ELSE 3
    END; -- Order the results based on the age categories
    
    -- This SQL query calculates the total number of unique customers and the income they generated,
-- grouped by the date in the specified format (YYYY-MM). The results are sorted by date in ascending order.
select 
	to_char(sales.sale_date, 'YYYY-MM') as date,
	COUNT(distinct sales.sales_id) as total_customers,	
	ROUND(SUM(sales.quantity * products.price),0) as income
	from sales join products on
	sales.product_id = products.product_id 
	group by date
	order by date;
    
-- This SQL query retrieves information about customers who made purchases with products having a price of 0.
-- The data includes the customer's full name, sale date, and the full name of the employee who made the sale.
-- The results are filtered using the condition "products.price = 0," and the earliest sale date for each customer is considered.
-- The outcome is sorted by customer_id.
select 
	concat(customers.first_name, ' ', customers.last_name) as customer,
	MIN(sales.sale_date) AS sale_date,
	concat(employees.first_name, ' ', employees.last_name) as seller
	from sales 
	join customers on sales.customer_id = customers.customer_id 
	join products on sales.product_id = products.product_id 
	join employees on sales.sales_person_id = employee_id 
	group by customers.customer_id, employees.employee_id
	order by customers.customer_id;    
