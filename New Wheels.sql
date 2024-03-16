
-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
      
SELECT
	state,
    COUNT(DISTINCT customer_id) AS number_of_customers
FROM customer_t
GROUP BY state
ORDER BY number_of_customers DESC;
    
  -- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

WITH customer_rating AS

(
SELECT
	quarter_number,
	CASE
		WHEN customer_feedback = 'Very Bad'  THEN 1
		WHEN customer_feedback = 'Bad'       THEN 2
		WHEN customer_feedback = 'Okay'      THEN 3
		WHEN customer_feedback = 'Good'      THEN 4
		WHEN customer_feedback = 'Very Good' THEN 5
		ELSE 0
	END AS ratings
FROM order_t
)

SELECT
	CONCAT('Q', quarter_number) AS quarter,
    ROUND(AVG(ratings),2) AS avg_customer_rating
FROM customer_rating
GROUP BY quarter
ORDER BY avg_customer_rating DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

 
 WITH quarter_feedback AS
 (
	SELECT
		CONCAT('Q', quarter_number) AS quarter,
		customer_feedback,
		COUNT(DISTINCT order_id) AS number_of_order
	FROM order_t
	GROUP BY quarter, customer_feedback
)
SELECT
	quarter,
    customer_feedback,
    number_of_order,
    SUM(number_of_order) OVER (PARTITION BY quarter) AS total_qtr_order,
    ROUND((number_of_order) / SUM(number_of_order) OVER (PARTITION BY quarter) * 100 ,2) AS percent_feedback
FROM quarter_feedback
ORDER BY quarter, percent_feedback DESC; 


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.


SELECT
	p.vehicle_maker,
    COUNT(DISTINCT o.customer_id) AS no_of_customers
FROM product_t AS p
INNER JOIN order_t AS o USING(product_id)
GROUP BY p.vehicle_maker
ORDER BY no_of_customers DESC
LIMIT 5;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?


WITH maker_per_state AS
 (
SELECT
	c.state,
	p.vehicle_maker,
		COUNT(DISTINCT o.customer_id) AS no_of_customers
FROM product_t AS p
INNER JOIN order_t AS o USING(product_id)
INNER JOIN customer_t AS c USING(customer_id)
GROUP BY  c.state, p.vehicle_maker
)
SELECT
	vehicle_maker,
    state,
    no_of_customers,
    d_rank
FROM (
	SELECT
		vehicle_maker,
		state,
		no_of_customers,
		DENSE_RANK() OVER (PARTITION BY state ORDER BY no_of_customers DESC) AS d_rank
FROM
	maker_per_state
) AS ranked_data
WHERE d_rank = 1
ORDER BY no_of_customers DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------


-- [Q6] What is the trend of number of orders by quarters?

SELECT
	CONCAT ('Q',quarter_number) AS quarter,
    COUNT(DISTINCT Order_id) AS num_of_orders
FROM order_t
GROUP BY quarter
ORDER BY num_of_orders DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

WITH revenue_quarter AS
(
SELECT 
	CONCAT('Q',quarter_number) AS quarter,
    ROUND(SUM(vehicle_price * quantity - discount/100 * vehicle_price),2) AS revenue
FROM order_t
GROUP BY quarter
ORDER BY revenue DESC
)

SELECT
	quarter,
    revenue,
    COALESCE(LAG(revenue) OVER (ORDER BY quarter ASC), 0) AS prior_revenue,
    CASE
		WHEN LAG(revenue) OVER (ORDER BY quarter ASC) <> 0 THEN 
        ROUND(((revenue - LAG(revenue) OVER (ORDER BY quarter ASC)) / LAG(revenue) OVER (ORDER BY quarter ASC)),2) * 100
        ELSE 0
        END AS qoq_percentage_change
FROM revenue_quarter;
	
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?


SELECT
 CONCAT('Q', quarter_number) AS quarter,
 COUNT(DISTINCT order_id) AS order_count,
 ROUND(SUM(vehicle_price * quantity - discount/100 * vehicle_price),2) AS revenue
FROM order_t
GROUP BY quarter
ORDER BY quarter;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

SELECT
	credit_card_type,
    ROUND(AVG(discount),2) AS avg_discount
FROM customer_t AS c
INNER JOIN order_t AS o USING(customer_id)
GROUP BY credit_card_type
ORDER BY avg_discount DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?

SELECT
	CONCAT('Q', quarter_number) AS quarter,
    ROUND(AVG(DATEDIFF(ship_date, order_date)),2) AS avg_shipping_time
FROM order_t
GROUP BY quarter
ORDER BY quarter;    

Select *
FROM order_t

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------

-- Total rev
SELECT 
ROUND(SUM((quantity*Vehicle_price) - ((discount/100) * Vehicle_price)),2) AS revenue
FROM Order_t

-- Total Orders
SELECT
	COUNT(DISTINCT order_ID)
FROM Order_t    

-- Total Customers
SELECT
	COUNT(DISTINCT Customer_id)
FROM customer_t

-- Avg rating
WITH customer_rating AS

(
SELECT
	quarter_number,
	CASE
		WHEN customer_feedback = 'Very Bad' THEN 1
		WHEN customer_feedback = 'Bad' THEN 2
		WHEN customer_feedback = 'Okay' THEN 3
		WHEN customer_feedback = 'Good' THEN 4
		WHEN customer_feedback = 'Very Good' THEN 5
		ELSE 0
	END AS ratings
FROM order_t
)

SELECT
	ROUND(AVG(ratings),2) AS avg_customer_rating
FROM customer_rating;

-- Last Qtr Revenue

SELECT 
ROUND(SUM((quantity*Vehicle_price) - ((discount/100) * Vehicle_price)),2) AS revenue
FROM Order_t
Where quarter_number = 4;

-- Last Qtr Orders
SELECT
	COUNT(order_ID)
FROM Order_t
Where quarter_number = 4;

-- AVG days to Ship

SELECT
	ROUND(AVG(DATEDIFF(ship_date, order_date)),2) AS avg_shipping_time
FROM order_t;

-- % Good feedback

WITH customer_rating AS 
(
    SELECT
        CASE
            WHEN customer_feedback = 'Good' THEN 1
            ELSE 0
        END AS is_good_feedback
    FROM order_t
)

SELECT
    ROUND((SUM(is_good_feedback) / COUNT(*)) * 100, 2) AS percentage_good_feedback
FROM customer_rating;



