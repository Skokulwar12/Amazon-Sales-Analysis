Amazon SQL queries

-- Creating sellers table
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
						seller_id VARCHAR(10),	
						seller_name VARCHAR(25)
					); 


-- Creating products table
DROP TABLE IF EXISTS products;
CREATE TABLE products (
                        product_id VARCHAR(10),    
                        product_name VARCHAR(255),    
                        price FLOAT,    
                        cogs FLOAT
                        );




-- Creating customers table 
DROP TABLE IF EXISTS customers;
CREATE TABlE customers (
						customer_id VARCHAR(10),	
						customer_name VARCHAR(55),	
						state VARCHAR(55)
						);



-- Creating orders table 
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
						order_id VARCHAR(10),	
						order_date DATE	,
						customer_id	VARCHAR(10),
						state	VARCHAR(30),
						category VARCHAR(55),	
						sub_category VARCHAR(155),	
						product_id	VARCHAR(25),
						price_per_unit	FLOAT,
						quantity INT,	
						sale	FLOAT,
						seller_id 	VARCHAR(10)
					);

--Creating Returns Table
DROP TABLE IF Exists returns;
CREATE TABLE returns (
						order_id VARCHAR(10),
						return_id VARCHAR(10)
					); 

--KEY PERFORMANCE INDICATORS

--01. Total_Revenue

SELECT 
		ROUND(SUM(sale):: numeric, 2) 
		AS total_revenue
FROM orders;

--02. Average order value

SELECT 
		ROUND((SUM(sale)/ SUM(quantity)) :: numeric, 2)
		AS avg_order_value
FROM orders;

--03. Total Orders

SELECT 
		SUM(quantity) AS total_orders
FROM orders;

--04. Average Qty Per Order

SELECT 
		SUM(quantity)/ COUNT(DISTINCT(order_id))
		AS avg_qty_per_order
FROM orders;

--05. Average Price Per Unit

SELECT 
		ROUND(AVG(price_per_unit) :: numeric , 2)
		AS avg_price_per_unit
FROM orders;

-- Business Insights

--The Most Active Month-

SELECT 
		TO_CHAR(order_date, 'Month') AS "Month",
		SUM(quantity) AS total_orders
FROM orders
GROUP BY "Month"
ORDER BY total_orders DESC
LIMIT 1;

--The Most Idle Month-

SELECT 
		TO_CHAR(order_date, 'Month') AS "Month",
		SUM(quantity) AS total_orders
FROM orders
GROUP BY "Month"
ORDER BY total_orders ASC
LIMIT 1;

-- Orders By Month

SELECT 
		TO_CHAR(order_date, 'Month') AS "Month",
		SUM(quantity) AS total_orders
FROM orders
GROUP BY "Month"
ORDER BY total_orders DESC;

--Orders By State

SELECT 
		state,
		SUM(quantity) AS total_orders
		FROM orders
WHERE state IS NOT NULL
GROUP BY state
ORDER BY total_orders DESC;


--%age by category 

SELECT 
		category,
		ROUND((SUM(sale) * 100/ (SELECT SUM(sale) FROM orders)) :: numeric, 2)
		AS revenue
		FROM orders
WHERE category IS NOT NULL
GROUP BY category
ORDER BY revenue DESC;

--%age by sub_category

SELECT 
		sub_category,
		ROUND((SUM(sale) * 100/ (SELECT SUM(sale) FROM orders)) :: numeric, 2) AS revenue
		FROM orders
WHERE sub_category IS NOT NULL
GROUP BY sub_category
ORDER BY revenue DESC;

--Best selling product

SELECT 
		p.product_id, 
		p.product_name, 
		ROUND(SUM(sale) :: numeric, 2) AS revenue
FROM orders AS o
JOIN products AS p
		ON p.product_id = o.product_id
GROUP BY 
		p.product_id, 
		p.product_name
ORDER BY revenue DESC
LIMIT 5;

--Worst Selling product

SELECT 
		p.product_id, 
		p.product_name, 
		ROUND(SUM(sale) :: numeric, 2) AS revenue
FROM orders AS o
JOIN products AS p
		ON p.product_id = o.product_id
GROUP BY 
		p.product_id, 
		p.product_name
ORDER BY revenue ASC
LIMIT 5;

--Find Out the top 5 customers who made the highest profits

SELECT 
	c.customer_id, 
	c.customer_name, 
	profit.total_profit
FROM customers AS c
	JOIN
		(SELECT
		o.customer_id, 
		ROUND((SUM(sale - (p.cogs * o.quantity))):: numeric, 2) 
		AS total_profit 
FROM orders
		AS o 
JOIN products 
		AS p
ON p.product_id = o.product_id
GROUP BY o.customer_id) 
		AS profit

ON c.customer_id = profit.customer_id
ORDER BY 
		profit.total_profit DESC
LIMIT 5;

--Find out the average quantity order.

SELECT  
		category, 
		ROUND(AVG(quantity)) AS avg_qty
FROM orders
WHERE category IS NOT NULL
GROUP BY category;

--Determine the top 5 products whose revenue has decreased compared to the previous year.

WITH revenue_comparison AS (
    SELECT 
        o.product_id,
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        ROUND(SUM(o.sale)::numeric, 2) AS total_revenue
    FROM 
        orders AS o
    GROUP BY 
        o.product_id,
        EXTRACT(YEAR FROM o.order_date)
)
SELECT 
	p.product_id,
    p.product_name,
    previous_year.total_revenue AS previous_year_revenue,
    current_year.total_revenue AS current_year_revenue
    
FROM 
    revenue_comparison AS current_year
JOIN 
    revenue_comparison AS previous_year
ON 
    current_year.product_id = previous_year.product_id
    AND current_year.order_year = previous_year.order_year + 1
JOIN 
    products AS p
ON 
    p.product_id = current_year.product_id
WHERE 
    current_year.total_revenue < previous_year.total_revenue
ORDER BY 
    (previous_year.total_revenue - current_year.total_revenue) DESC
LIMIT 5;

--Identify the highest profitable sub-category. 

SELECT 
		sub_category,
		ROUND(SUM(sale) :: numeric, 2) AS total_revenue
FROM orders
WHERE sub_category IS NOT NULL
GROUP BY sub_category
ORDER BY total_revenue DESC
LIMIT 5;

--Calculate the profit margin percentage for each sale (Profit divided by Sales).

SELECT
	p.product_id,
	p.price,
	p.cogs,
	o.sale,
	ROUND((o.sale-(p.cogs * o.quantity)) * 100/ o.sale) AS profit
FROM
	products AS p
JOIN 
	orders AS o 
ON p.product_id = o.product_id
ORDER BY profit DESC;

--Calculate the percentage contribution of each sub_category.

SELECT 
	sub_category,
	ROUND(SUM(sale) :: numeric, 2) AS revenue,
	ROUND((SUM(sale) *100 / (SELECT SUM(sale) FROM orders)) :: numeric, 2)
	AS contribution
FROM 
	orders
WHERE 
	sub_category IS NOT NULL
GROUP BY
	sub_category
ORDER BY
	contribution DESC;

--Identify the top 2 categories that have received maximum returns and their return percentage.

SELECT
	o.category,
	COUNT(r.return_id) AS return_count,
	ROUND(((COUNT(r.return_id) / CAST((SELECT COUNT(return_id) FROM returns) AS FLOAT)) *100) :: numeric, 2)
	AS return_percentage
FROM
	orders AS o
JOIN
	returns AS r 
ON o.order_id = r.order_id
GROUP BY
	o.category
ORDER BY
	return_count DESC
LIMIT 2;
