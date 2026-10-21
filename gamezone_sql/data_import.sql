CREATE TABLE region_cleaned (
    country_code TEXT,
    region TEXT,
    region_cleaned TEXT
);

CREATE TABLE orders_cleaned (
    user_id TEXT,
    order_id TEXT,
    purchase_ts TEXT,
    purchase_ts_cleaned DATE,
    ship_ts DATE,
    purchase_year INTEGER,
    purchase_month INTEGER,
    purchase_month_year DATE,
    time_to_ship INTEGER,
    valid_ship_date BOOLEAN,
    refund_ts DATE,
    product_name TEXT,
    product_name_cleaned TEXT,
    product_id TEXT,
    usd_price NUMERIC(10,2),
    purchase_platform TEXT,
    marketing_channel TEXT,
    marketing_channel_cleaned TEXT,
    account_creation_method TEXT,
    account_creation_method_cleaned TEXT,
    region_cleaned TEXT,
    country_code TEXT
);

SELECT COUNT(*) AS total_rows
FROM orders_cleaned;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT user_id) AS unique_customers
FROM orders_cleaned;

SELECT *
FROM orders_cleaned
LIMIT 10;

ALTER TABLE region_cleaned
DROP COLUMN column4,
DROP COLUMN column5;

SELECT *
FROM region_cleaned
LIMIT 10;

ALTER TABLE orders
DROP COLUMN "Column13",
DROP COLUMN "Column14";

DELETE FROM region
WHERE "COUNTRY_CODE" IS NULL
  AND "REGION" IS NULL;

SELECT "COUNTRY_CODE", COUNT(*)
FROM region
GROUP BY "COUNTRY_CODE"
HAVING COUNT(*) > 1;