USE sakila;

-- Creating a Customer Summary Report

-- summarizes key information about customers in the Sakila database, including their rental history and payment details. 

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
SELECT * FROM sakila.rental; -- rental_id, customer_id, 
SELECT * FROM sakila.customer; -- customer_id, first_name, last_name, email

DROP VIEW IF EXISTS rental_info;
CREATE VIEW rental_info AS
SELECT 
	c.customer_id,
	CONCAT(c.first_name, ' ', c.last_name) as name,
    c.email,
	COUNT(*) AS rental_count
FROM sakila.customer as c
JOIN sakila.rental as r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
ORDER BY rental_count DESC;

SELECT * FROM rental_info;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
SELECT * FROM sakila.payment; -- payment_id, customer_id, rental_id, amount

CREATE TEMPORARY TABLE temp_total_paid AS
SELECT 
	ri.customer_id,
    ri.name,
    SUM(p.amount) AS total_paid
FROM sakila.rental_info AS ri
JOIN sakila.payment AS p ON ri.customer_id = p.customer_id
GROUP BY ri.customer_id; 

SELECT * FROM temp_total_paid;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH cte_customer_summary_report AS (
	SELECT 
		ri.customer_id,
		ri.name,
        ri.email,
        ri.rental_count,
		SUM(p.amount) AS total_paid
		FROM sakila.rental_info AS ri
		JOIN sakila.payment AS p ON ri.customer_id = p.customer_id
		GROUP BY ri.customer_id
)
SELECT
	cte.customer_id,
    cte.name,
    cte.email,
    cte.rental_count,
    cte.total_paid
FROM cte_customer_summary_report AS cte;


-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental
-- this last column is a derived column from total_paid and rental_count.

WITH cte_customer_summary_report AS (
	SELECT 
		ri.customer_id,
		ri.name,
        ri.email,
        ri.rental_count,
		SUM(p.amount) AS total_paid
		FROM sakila.rental_info AS ri
		JOIN sakila.payment AS p ON ri.customer_id = p.customer_id
		GROUP BY ri.customer_id
)
SELECT
	cte.customer_id,
    cte.name,
    cte.email,
    cte.rental_count,
    cte.total_paid,
    ROUND(cte.total_paid/cte.rental_count,2) AS average_payment_per_rental 
FROM cte_customer_summary_report AS cte;


