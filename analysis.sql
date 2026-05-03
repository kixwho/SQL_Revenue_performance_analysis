-- Revenue Performance Analysis (Olist E-commerce Dataset)
-- Focus: growth trends, anomaly investigation, product and geographic revenue drivers
-- Author: Kiki Wu
-- Notes: All revenue calculated using payment_value unless otherwise specified

--1. How much revenue is generated on a yearly basis?

SELECT
	EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
	SUM(p.payment_value) AS revenue
FROM orders o
JOIN payments p ON o.order_id=p.order_id
GROUP BY year;

--2. Calculate YoY revenue growth to identify overall business trend

WITH yearly_revenue AS (
	SELECT
		EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
		SUM(p.payment_value) AS Revenue
	FROM orders o
	JOIN payments p ON o.order_id=p.order_id
	GROUP BY year
),
year_comp AS (
	SELECT *, LAG(revenue, 1) OVER (ORDER BY year) AS previous_year_rev
	FROM yearly_revenue
)
SELECT
	year,
	revenue,
	ROUND((revenue - previous_year_rev) / previous_year_rev *100, 2) AS pct_yearly_revenue_growth
FROM year_comp
WHERE previous_year_rev IS NOT NULL;

--3. Investigate 2016–2017 revenue jump using monthly comparison (normalize partial year)

WITH monthly_comp AS (
	SELECT
		EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
	
		SUM(CASE
		WHEN EXTRACT(YEAR FROM o.order_purchase_timestamp)=2016
		THEN p.payment_value ELSE 0 END) AS rev_2016,
	
		SUM(CASE
		WHEN EXTRACT(YEAR FROM o.order_purchase_timestamp)=2017
		THEN p.payment_value ELSE 0 END) AS rev_2017
	FROM orders o
	JOIN payments p ON o.order_id=p.order_id
	GROUP BY month
)
SELECT *, ROUND((rev_2017 - rev_2016)/NULLIF(rev_2016,0),2) AS YoY_change
FROM monthly_comp
WHERE month BETWEEN 9 AND 12;

--4. Top 5 product categories by revenue

WITH revenue_by_product AS (
	SELECT
		p.product_category_name AS product_category,
		SUM(o.price) AS revenue
	FROM order_items o
	JOIN products p ON o.product_id=p.product_id
	GROUP BY p.product_category_name
)
SELECT
	product_category,
	revenue,
	ROUND(revenue / SUM(revenue) OVER () *100, 2) AS pct_revenue_share
FROM revenue_by_product
ORDER BY revenue DESC
LIMIT 5;

--5. Top 5 revenue generating cities

WITH revenue_by_city AS (
	SELECT
		c.customer_city,
		COUNT(o.order_id) AS order_count,
		SUM(p.payment_value) AS revenue
	FROM orders o
	JOIN payments p ON o.order_id=p.order_id
	JOIN customers c ON c.customer_id=o.customer_id
	GROUP BY c.customer_city
)
SELECT
	customer_city,
	ROUND(revenue, 0) AS revenue,
	ROUND(revenue/SUM(revenue) OVER () *100, 2) AS city_pct,
	RANK() OVER (ORDER BY order_count DESC) AS order_ct_rank,
	RANK() OVER (ORDER BY revenue DESC) AS rev_rank
FROM revenue_by_city
ORDER BY revenue DESC
LIMIT 5;