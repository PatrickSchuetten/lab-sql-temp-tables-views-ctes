USE Sakila;
-- - Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW rental_information AS
SELECT c.customer_id, first_name, last_name, email, count(r.rental_id) AS number_of_rentals FROM customer AS c
LEFT JOIN rental AS r
ON c.customer_id = r.customer_id
GROUP BY c.customer_id; 

SELECT * FROM rental_information;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 
-- to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE sakila.total_amount_paid
SELECT r.customer_id, r.first_name, r.last_name, sum(amount) AS total_paid FROM rental_information AS r
LEFT JOIN payment AS p
ON r.customer_id = p.customer_id
GROUP BY r.customer_id;

SELECT * FROM total_amount_paid;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid. 

SELECT * FROM rental_information AS r
LEFT JOIN total_amount_paid AS t
ON r.customer_id = t.customer_id;

WITH customer_summary_report AS (
	SELECT r.first_name, r.last_name, r.email, r.number_of_rentals, t.total_paid FROM rental_information AS r
	LEFT JOIN total_amount_paid AS t
	ON r.customer_id = t.customer_id
)
SELECT * FROM customer_summary_report;

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
WITH customer_summary_report AS (
	SELECT r.first_name, r.last_name, r.email, r.number_of_rentals, t.total_paid FROM rental_information AS r
	LEFT JOIN total_amount_paid AS t
	ON r.customer_id = t.customer_id
)
SELECT first_name, last_name, email, number_of_rentals, total_paid, round(total_paid/number_of_rentals,2) AS average_payment_per_rental FROM customer_summary_report;
