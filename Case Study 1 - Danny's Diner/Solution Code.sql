/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


-- Question 1
SELECT sales.customer_id, SUM(menu.price) AS total_sales
FROM sales
	join menu
	on sales.product_id = menu.product_id
GROUP BY sales.customer_id;


-- Question 2
SELECT customer_id, COUNT (DISTINCT order_date) as days_visited
FROM sales
GROUP BY customer_id


-- Question 3
WITH ordered_sales AS (
  SELECT
    sales.customer_id, menu.product_name, sales.order_date,
    RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS order_rank
  FROM sales
	JOIN menu
    ON sales.product_id = menu.product_id
)
SELECT
  customer_id,
  product_name
FROM ordered_sales
WHERE order_rank = 1;


-- Question 4
SELECT
  TOP (1) menu.product_name,
  COUNT(sales.product_id) AS total_purchases
FROM sales
JOIN menu
  ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY total_purchases DESC


-- Question 5
WITH ordered_sales AS (
  SELECT
    sales.customer_id, menu.product_name, count(sales.product_id) as quantity,
    RANK() OVER (PARTITION BY sales.customer_id ORDER BY count(sales.product_id) desc) AS order_rank
   -- menu.product_name
  FROM sales
	LEFT JOIN menu
    ON sales.product_id = menu.product_id
GROUP BY sales.customer_id, menu.product_name
)
SELECT
  customer_id,
  product_name,
  quantity
FROM ordered_sales
WHERE order_rank = 1;


-- Question 6
WITH member_sales AS (
  SELECT
    sales.customer_id, menu.product_name, sales.order_date,
    RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS order_rank
  FROM sales
	JOIN menu
    	ON sales.product_id = menu.product_id
	JOIN members
	ON sales.customer_id = members.customer_id
	WHERE sales.order_date >=members.join_date
)
SELECT customer_id, product_name, order_date
FROM member_sales
WHERE order_rank = 1;


-- Question 7
WITH member_sales AS (
  SELECT
    sales.customer_id, menu.product_name, sales.order_date,
    RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date desc) AS order_rank
  FROM sales
	JOIN menu
    	ON sales.product_id = menu.product_id
	JOIN members
	ON sales.customer_id = members.customer_id
	WHERE sales.order_date <members.join_date
)
SELECT customer_id, product_name, order_date
FROM member_sales
WHERE order_rank = 1;


-- Question 8
SELECT sales.customer_id, COUNT(DISTINCT sales.product_id) AS unique_menu_items, SUM(menu.price) AS total_spend
FROM sales
	JOIN menu
	ON sales.product_id = menu.product_id
	JOIN members
	ON sales.customer_id = members.customer_id
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id;


-- Question 9 
SELECT sales.customer_id, 
SUM (CASE WHEN
	menu.product_name = 'sushi' THEN 20 * menu.price
	ELSE 10 * menu.price
END) AS points
FROM sales
	join menu
	on sales.product_id = menu.product_id
GROUP BY sales.customer_id;


-- Question 10
SELECT sales.customer_id, 
SUM (CASE 
	WHEN menu.product_name = 'sushi' THEN 20 * menu.price
	WHEN sales.order_date between members.join_date and dateadd(day, 6, join_date) THEN 20 * menu.price
	ELSE 10 * menu.price
END) AS points
FROM sales
	join menu
	on sales.product_id = menu.product_id
	join members
	ON sales.customer_id = members.customer_id
WHERE sales.order_date between '2021-01-01' and '2021-01-31'
GROUP BY sales.customer_id;
