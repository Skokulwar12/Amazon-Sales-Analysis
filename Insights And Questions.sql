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









