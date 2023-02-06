CREATE TABLE IF NOT EXISTS mart.f_customer_retention(
	new_customers_count 			int8,
	returning_customers_count 		int8,
	refunded_customer_count 		int8,
	period_name 					TEXT,
	period_id 						int4,
	item_id 						int4,
	new_customers_revenue 			NUMERIC(14, 2),
	returning_customers_revenue 	NUMERIC(14, 2),
	customers_refunded 				int8
);

WITH by_weeks AS (
	SELECT customer_id, item_id, status, payment_amount, week_of_year,
		ROW_NUMBER() OVER(PARTITION BY week_of_year) row_num
	FROM mart.f_sales_new fsn
		LEFT JOIN mart.d_calendar dc ON fsn.date_id = dc.date_id
), counter AS (
	SELECT count(customer_id) AS count_c, customer_id, item_id, week_of_year
	FROM by_weeks
	GROUP BY customer_id, item_id, week_of_year
), revenue AS (
	SELECT customer_id, item_id, SUM(payment_amount) AS payment_amount, week_of_year,
		ROW_NUMBER() OVER(PARTITION BY customer_id) AS by_customers
	FROM mart.f_sales_new fsn
		LEFT JOIN mart.d_calendar dc ON fsn.date_id = dc.date_id
	GROUP BY customer_id, item_id, week_of_year
)
INSERT INTO mart.f_customer_retention(new_customers_count, returning_customers_count, refunded_customer_count, period_name,
    period_id, item_id, new_customers_revenue, returning_customers_revenue, customers_refunded)
SELECT
	SUM(CASE WHEN c.count_c = 1 THEN 1 END) AS new_customers_count,
	SUM(CASE WHEN c.count_c > 1 THEN 1 END) AS returning_customers_count,
	COUNT(DISTINCT(CASE WHEN status = 'refunded' THEN bw.customer_id END)) AS refunded_customer_count,
	CASE WHEN 1=1 THEN 'weekly'	END	AS period_name,
	c.week_of_year, c.item_id,
	SUM(CASE WHEN c.count_c = 1 THEN bw.payment_amount END) AS new_customers_revenue,
	SUM(CASE WHEN c.count_c > 1 THEN bw.payment_amount END) AS returning_customers_revenue,
	COUNT(CASE WHEN status = 'refunded' THEN bw.customer_id END) AS customers_refunded
FROM counter c
	JOIN by_weeks bw ON bw.customer_id = c.customer_id
GROUP BY c.item_id, c.week_of_year;