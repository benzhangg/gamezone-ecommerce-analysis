/*
 * Count total rows, unique orders, and unique customers
 */
select
    count(*) as total_rows,
    count(distinct order_id) as unique_orders,
    count(distinct user_id) as unique_customers
from
    orders_cleaned;


/*
 * Checks the first purchase and last purchase date
 */
select
    min(purchase_ts_cleaned) as first_purchase,
    max(purchase_ts_cleaned) as last_purchase
from
    orders_cleaned;


/*
 * Checks total revenue
 */
select
    round(sum(usd_price), 2) as total_revenue
from
    orders_cleaned;


/*
 * # of duplicated orders
 */
SELECT
    order_id,
    count(order_id) AS user_count
FROM
    orders_cleaned
GROUP BY
    order_id
HAVING
    count(order_id) > 1;


/*
 * Checks the number of valid and invalid ship dates
 */
select
    valid_ship_date,
    count(valid_ship_date) as row_count
from
    orders_cleaned
group by
    valid_ship_date;


/*
 * Checks the row where valid_ship_date is null
 */
SELECT *
FROM orders_cleaned
WHERE valid_ship_date IS NULL;


/*
 * Checks that invalid shipping dates don't have a time_to_ship value
 */
select
    count(*) as invalid_rows_with_shipping_time
from
    orders_cleaned
where
    valid_ship_date = false
    and time_to_ship is not null;


/*
 * Joins the orders and region tables based on country code
 */
select
    orders_cleaned.country_code,
    region_cleaned.region_cleaned
from
    orders_cleaned
left join region_cleaned
    on orders_cleaned.country_code = region_cleaned.country_code;


/*
 * Checks which country codes are not mapped
 */
select
    distinct orders_cleaned.country_code
from
    orders_cleaned
left join region_cleaned
    on orders_cleaned.country_code = region_cleaned.country_code
where
    region_cleaned.country_code is null;


/*
 * Checks the # of rows that each country code is not mapped to
 */
select
    orders_cleaned.country_code,
    count(*) as row_count
from
    orders_cleaned
left join region_cleaned
    on orders_cleaned.country_code = region_cleaned.country_code
where
    region_cleaned.country_code is null
group by
    orders_cleaned.country_code;


/*
 * Checks that unmapped regions are categorized as Unknown
 */
select
    orders_cleaned.country_code,
    coalesce(region_cleaned.region_cleaned, 'Unknown') as region_cleaned,
    count(*) as row_count
from
    orders_cleaned
left join region_cleaned
    on orders_cleaned.country_code = region_cleaned.country_code
where
    orders_cleaned.country_code in ('EU', 'AP')
    or orders_cleaned.country_code is null
group by
    orders_cleaned.country_code,
    coalesce(region_cleaned.region_cleaned, 'Unknown');


/*
 * Checks items with no price
 */
select
    count(*) as missing_prices
from
    orders_cleaned
where
    usd_price is null;


/*
 * Checks $0 transactions
 */
select
    count(*) as zero_dollar_transactions
from
    orders_cleaned
where
    usd_price = 0;


/*
 * Checks missing purchase dates
 */
select
    count(*) as missing_purchase_dates
from
    orders_cleaned
where
    purchase_ts_cleaned is null;


/*
 * Checks rows where the product name was cleaned
 */
select
    count(*) as cleaned_product_names
from
    orders_cleaned
where
    product_name is distinct from product_name_cleaned;


/*
 * Checks unknown marketing channels
 */
select
    count(*) as unknown_marketing_channels
from
    orders_cleaned
where
    marketing_channel_cleaned = 'unknown';


/*
 * Checks unknown account creation methods
 */
select
    count(*) as unknown_account_creation_methods
from
    orders_cleaned
where
    account_creation_method_cleaned = 'unknown';