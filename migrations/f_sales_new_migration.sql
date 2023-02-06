ALTER TABLE staging.user_order_log ADD COLUMN IF NOT EXISTS status TEXT;

CREATE TABLE IF NOT EXISTS mart.f_sales_new
(
id              Serial          PRIMARY KEY,
date_id         int4            REFERENCES mart.d_calendar(date_id),
item_id         int4            REFERENCES mart.d_item(item_id),
customer_id     int4            REFERENCES mart.d_customer(customer_id),
city_id         int4            REFERENCES mart.d_city(city_id),
quantity        int4,
payment_amount  NUMERIC(14, 2),
status TEXT
);