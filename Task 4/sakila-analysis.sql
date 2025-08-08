-- Helper view: enrich payments with rental, inventory, film, category

CREATE OR REPLACE VIEW v_sales AS
SELECT
  p.payment_id,
  p.payment_date,
  p.amount,
  p.customer_id,
  r.rental_id,
  i.inventory_id,
  i.store_id,
  p.staff_id,
  f.film_id,
  f.title          AS film_title,
  c.category_id,
  c.name           AS category_name
FROM payment AS p
JOIN rental      AS r  ON p.rental_id = r.rental_id
JOIN inventory   AS i  ON r.inventory_id = i.inventory_id
JOIN film        AS f  ON i.film_id = f.film_id
LEFT JOIN film_category AS fc ON f.film_id = fc.film_id
LEFT JOIN category      AS c  ON fc.category_id = c.category_id;

-- Optional helper: monthly key as first of month (DATE type)
CREATE OR REPLACE VIEW v_sales_monthly AS
SELECT
  DATE_FORMAT(payment_date, '%Y-%m-01') AS month_start,
  store_id,
  staff_id,
  customer_id,
  film_id,
  film_title,
  category_id,
  category_name,
  amount
FROM v_sales;

-- Core analysis queries

-- 1. Total revenue
SELECT SUM(amount) AS total_revenue
FROM payment;

-- 2. Revenue by store
SELECT s.store_id, ROUND(SUM(p.amount), 2) AS revenue
FROM payment p
JOIN rental r   ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s     ON i.store_id = s.store_id
GROUP BY s.store_id
ORDER BY revenue DESC;

-- 3. Revenue by category (Top 10)
SELECT category_name, ROUND(SUM(amount), 2) AS revenue
FROM v_sales
GROUP BY category_name
ORDER BY revenue DESC
LIMIT 10;

-- 4. Top 10 customers by lifetime spend
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       ROUND(SUM(p.amount), 2) AS total_spend,
       COUNT(*) AS payments
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spend DESC
LIMIT 10;

-- 5. Average revenue per user (ARPU)
SELECT ROUND(SUM(amount) / COUNT(DISTINCT customer_id), 2) AS arpu
FROM payment;

-- 6. Monthly revenue trend with MoM delta and percent change
WITH monthly AS (
  SELECT DATE_FORMAT(payment_date, '%Y-%m-01') AS month_start,
         ROUND(SUM(amount), 2) AS revenue
  FROM payment
  GROUP BY month_start
)
SELECT month_start,
       revenue,
       revenue - LAG(revenue) OVER(ORDER BY month_start) AS mom_change,
       ROUND(100 * (revenue - LAG(revenue) OVER(ORDER BY month_start))
                 / NULLIF(LAG(revenue) OVER(ORDER BY month_start), 0), 2) AS mom_change_pct
FROM monthly
ORDER BY month_start;

-- 7. Top 15 films by revenue
SELECT film_title, ROUND(SUM(amount), 2) AS revenue, COUNT(*) AS payments
FROM v_sales
GROUP BY film_title
ORDER BY revenue DESC
LIMIT 15;

-- 8. Rentals count by category and store
SELECT store_id, category_name, COUNT(*) AS rentals
FROM v_sales
GROUP BY store_i d, category_name
ORDER BY rentals DESC;

-- 9. Staff performance (revenue and transactions)
SELECT st.staff_id,
       CONCAT(st.first_name, ' ', st.last_name) AS staff_name,
       ROUND(SUM(p.amount), 2) AS revenue,
       COUNT(*) AS payments
FROM payment p
JOIN staff st ON p.staff_id = st.staff_id
GROUP BY st.staff_id, staff_name
ORDER BY revenue DESC;

-- 10. Inventory currently in stock per store
SELECT i.store_id, SUM(inventory_in_stock(i.inventory_id)) AS items_in_stock
FROM inventory i
GROUP BY i.store_id
ORDER BY i.store_id;

-- 11. Overdue rentals (returned late)
SELECT COUNT(*) AS returned_late
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f      ON i.film_id = f.film_id
WHERE r.return_date IS NOT NULL
  AND DATEDIFF(r.return_date, r.rental_date) > f.rental_duration;

-- 12. Overdue and not yet returned
SELECT COUNT(*) AS currently_overdue
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f      ON i.film_id = f.film_id
WHERE r.return_date IS NULL
  AND DATEDIFF(NOW(), r.rental_date) > f.rental_duration;

-- 13. Customers whose total spend is above overall average spend (subquery)
WITH customer_totals AS (
  SELECT customer_id, SUM(amount) AS total_spend
  FROM payment
  GROUP BY customer_id
)
SELECT ct.customer_id, ROUND(ct.total_spend, 2) AS total_spend
FROM customer_totals ct
WHERE ct.total_spend > (SELECT AVG(total_spend) FROM customer_totals)
ORDER BY total_spend DESC
LIMIT 20;

-- 14. Monthly revenue by store and category (pivot-friendly)
SELECT DATE_FORMAT(payment_date, '%Y-%m-01') AS month_start,
       store_id,
       category_name,
       ROUND(SUM(amount), 2) AS revenue
FROM v_sales
GROUP BY month_start, store_id, category_name
ORDER BY month_start, revenue DESC;

-- 15. New vs repeat vs loyal customers by rental count
WITH activity AS (
  SELECT customer_id, COUNT(*) AS rentals
  FROM rental
  GROUP BY customer_id
)
SELECT CASE
         WHEN rentals = 1 THEN 'new'
         WHEN rentals BETWEEN 2 AND 5 THEN 'repeat'
         ELSE 'loyal'
       END AS segment,
       COUNT(*) AS customers
FROM activity
GROUP BY segment
ORDER BY customers DESC;

-- 16. First rental date per customer (window function example)
SELECT customer_id,
       MIN(rental_date) AS first_rental,
       COUNT(*) AS total_rentals
FROM rental
GROUP BY customer_id
ORDER BY first_rental;

-- 17. Top cities by revenue
SELECT ci.city, cy.country, ROUND(SUM(p.amount), 2) AS revenue
FROM payment p
JOIN rental r   ON p.rental_id = r.rental_id
JOIN customer c ON p.customer_id = c.customer_id
JOIN address a  ON c.address_id = a.address_id
JOIN city ci    ON a.city_id = ci.city_id
JOIN country cy ON ci.country_id = cy.country_id
GROUP BY ci.city, cy.country
ORDER BY revenue DESC
LIMIT 20;

-- 18. Category share of revenue within each store (window function)
SELECT store_id,
       category_name,
       ROUND(SUM(amount), 2) AS revenue,
       ROUND(100 * SUM(amount) / SUM(SUM(amount)) OVER (PARTITION BY store_id), 2) AS pct_of_store
FROM v_sales
GROUP BY store_id, category_name
ORDER BY store_id, revenue DESC;

-- End of analysis