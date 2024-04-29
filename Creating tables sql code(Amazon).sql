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


