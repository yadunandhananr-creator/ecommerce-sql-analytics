
CREATE DATABASE ecommerce_project;

USE ecommerce_project;

SELECT DATABASE();

USE ecommerce_project;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    seller_id INT,
    FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_type VARCHAR(30),
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

SHOW TABLES;

DESCRIBE customers;
DESCRIBE sellers;
DESCRIBE products;
DESCRIBE orders;
DESCRIBE order_items;
DESCRIBE payments;

USE ecommerce_project;

INSERT INTO customers VALUES
(1,'Arun','Kochi','2025-01-10'),
(2,'Meera','Thrissur','2025-02-15'),
(3,'Rahul','Kochi','2025-03-20'),
(4,'Anjali','Calicut','2025-06-10'),
(5,'Nikhil','Thrissur','2026-01-05');

INSERT INTO sellers VALUES
(1,'Tech World','Kochi'),
(2,'Fashion Hub','Thrissur'),
(3,'Home Store','Calicut');

INSERT INTO products VALUES
(1,'Laptop','Electronics',60000,1),
(2,'Phone','Electronics',25000,1),
(3,'Headphones','Electronics',2000,1),
(4,'T-Shirt','Clothing',800,2),
(5,'Jeans','Clothing',1800,2),
(6,'Chair','Furniture',3500,3);

INSERT INTO orders VALUES
(101,1,'2025-01-15','delivered'),
(102,2,'2025-02-20','delivered'),
(103,1,'2025-03-10','delivered'),
(104,3,'2025-04-05','shipped'),
(105,4,'2025-06-15','delivered'),
(106,5,'2026-01-10','pending'),
(107,2,'2026-02-12','delivered'),
(108,3,'2026-03-01','delivered');

INSERT INTO order_items VALUES
(1,101,1,1,60000),
(2,101,3,2,2000),
(3,102,4,3,800),
(4,103,2,1,25000),
(5,104,6,2,3500),
(6,105,5,1,1800),
(7,106,1,1,60000),
(8,107,3,1,2000),
(9,108,2,2,25000),
(10,108,4,2,800);


INSERT INTO payments VALUES
(1,101,'UPI',64000,'2025-01-15'),
(2,102,'Card',2400,'2025-02-20'),
(3,103,'UPI',25000,'2025-03-10'),
(4,104,'Card',7000,'2025-04-05'),
(5,105,'Cash',1800,'2025-06-15'),
(6,106,'UPI',60000,'2026-01-10'),
(7,107,'Card',2000,'2026-02-12'),
(8,108,'UPI',51600,'2026-03-01');


SELECT * FROM customers;
SELECT * FROM sellers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;

USE ecommerce_project;

#beginer questions
-- 1. List customers from Kochi
SELECT *
FROM customers
WHERE city = 'Kochi';

-- 2. Orders placed in the last 30 days
SELECT *
FROM orders
WHERE order_date BETWEEN
      DATE_SUB(CURDATE(), INTERVAL 30 DAY)
      AND CURDATE();

-- 3. Ten most expensive products
SELECT *
FROM products
ORDER BY price DESC
LIMIT 10;

-- 4. All delivered orders
SELECT *
FROM orders
WHERE status = 'delivered';

-- 5. Customers who signed up in 2025
SELECT *
FROM customers
WHERE signup_date >= '2025-01-01'
  AND signup_date < '2026-01-01';
  
#intermediate questions

USE ecommerce_project;

-- 6. Total revenue from recorded payments
SELECT SUM(amount) AS total_revenue
FROM payments;

-- 7. Product category with the most units sold
SELECT p.category, SUM(oi.quantity) AS units_sold
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY units_sold DESC;

-- 8. Top 5 customers by total amount spent
SELECT c.customer_id, c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

-- 9. Sellers generating more than 10000 in sales
SELECT s.seller_id, s.seller_name,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM sellers s
JOIN products p ON s.seller_id = p.seller_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
GROUP BY s.seller_id, s.seller_name
HAVING SUM(oi.quantity * oi.unit_price) > 10000;

-- 10. Average order value by customer city
SELECT c.city,
       AVG(t.order_total) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN (
    SELECT order_id,
           SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
) t ON o.order_id = t.order_id
GROUP BY c.city;

-- 11. Number of payments and average payment by type
SELECT payment_type,
       COUNT(*) AS payment_count,
       AVG(amount) AS avg_payment
FROM payments
GROUP BY payment_type;

#advanced questions

#12.Rank products by revenue within each category

WITH product_sales AS (
    SELECT p.product_id, p.product_name, p.category,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT product_name, category, revenue,
       DENSE_RANK() OVER (
           PARTITION BY category
           ORDER BY revenue DESC
       ) AS product_rank
FROM product_sales;

#13.Find customers spending more than the average customer

WITH customer_spend AS (
    SELECT c.customer_id, c.customer_name,
           SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT *
FROM customer_spend
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM customer_spend
);

#14.Calculate monthly sales using a CTE

WITH monthly_sales AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT *
FROM monthly_sales
ORDER BY sales_month;

#15.Find repeat customers with more than 20 orders

SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) > 20;

#16.Create the monthly sales summary view

CREATE VIEW monthly_sales_summary AS
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');


SELECT * FROM monthly_sales_summary;

#17.Create a stored procedure for customer order history

DELIMITER //

CREATE PROCEDURE get_customer_history(IN p_customer_id INT)
BEGIN
    SELECT c.customer_id, c.customer_name,
           o.order_id, o.order_date, o.status,
           p.product_name, oi.quantity, oi.unit_price
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN products p ON oi.product_id = p.product_id
    WHERE c.customer_id = p_customer_id
    ORDER BY o.order_date DESC;
END //

DELIMITER ;


CALL get_customer_history(1);

#18.Find the best-selling product in each category

WITH product_units AS (
    SELECT p.product_name, p.category,
           SUM(oi.quantity) AS units_sold
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY category
               ORDER BY units_sold DESC
           ) AS rnk
    FROM product_units
)
SELECT *
FROM ranked
WHERE rnk = 1;

#19.Find customers who have never placed an order

SELECT c.*
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

#20.Calculate revenue by payment type

SELECT payment_type,
       SUM(amount) AS total_payment,
       COUNT(*) AS payment_count
FROM payments
GROUP BY payment_type
ORDER BY total_payment DESC;

SELECT * FROM monthly_sales_summary;

CALL get_customer_history(1);




















