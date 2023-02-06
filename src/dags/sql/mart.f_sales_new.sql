INSERT INTO mart.f_sales_new (date_id, item_id, customer_id, city_id, quantity, payment_amount, status)
WITH revenue AS (
	SELECT
		CASE
			WHEN status = 'shipped' THEN payment_amount
			WHEN status = 'refunded' THEN -payment_amount
		END AS payment_amount, uniq_id
	FROM staging.user_order_log uol
)
SELECT dc.date_id, uol.item_id, uol.customer_id, city_id, quantity, rev.payment_amount, status
FROM staging.user_order_log uol
	INNER JOIN revenue rev ON uol.uniq_id = rev.uniq_id
	LEFT JOIN mart.d_calendar AS dc ON uol.date_time::Date = dc.date_actual
WHERE uol.date_time::Date = '{{ds}}';;