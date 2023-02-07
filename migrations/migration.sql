ALTER TABLE staging.user_order_log ADD COLUMN IF NOT EXISTS status TEXT;

ALTER TABLE mart.f_sales ADD COLUMN IF NOT EXISTS status TEXT;

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

ALTER TABLE mart.f_customer_retention
ADD CONSTRAINT uniq_pare_period_id_item_id UNIQUE (period_id, item_id);