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