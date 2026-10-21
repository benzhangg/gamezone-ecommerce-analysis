-- Refund Rate by Product

select
	product_name_cleaned,
	count(distinct order_id) as total_orders,
	count(distinct order_id) filter (
        where refund_ts is not null
    ) as refunded_orders,
    round(
        count(distinct order_id) filter (where refund_ts is not null) * 100.0
        / count(distinct order_id),
        2
    ) as refund_rate
from gamezone_analysis
group by product_name_cleaned
order by refund_rate desc;


-- Refund Rate by Purchase Platform
select
    purchase_platform,
    count(distinct order_id) as total_orders,
    count(distinct order_id) filter (
        where refund_ts is not null
    ) as refunded_orders,
    round(
        count(distinct order_id) filter (where refund_ts is not null) * 100.0
        / count(distinct order_id),
        2
    ) as refund_rate
from gamezone_analysis
group by purchase_platform
order by refund_rate desc;


-- Refund Rate by Product and Purchase Platform
select
    product_name_cleaned,
    purchase_platform,
    count(distinct order_id) as total_orders,
    count(distinct order_id) filter (
        where refund_ts is not null
    ) as refunded_orders,
    round(
        count(distinct order_id) filter (where refund_ts is not null) * 100.0
        / count(distinct order_id),
        2
    ) as refund_rate
from gamezone_analysis
group by
    product_name_cleaned,
    purchase_platform
order by
    product_name_cleaned,
    refund_rate desc;


-- Refund Rate by Product and Year
select
    purchase_year::text as purchase_year,
    product_name_cleaned,
    count(distinct order_id) as total_orders,
    count(distinct order_id) filter (
        where refund_ts is not null
    ) as refunded_orders,
    round(
        count(distinct order_id) filter (where refund_ts is not null) * 100.0
        / count(distinct order_id),
        2
    ) as refund_rate
from gamezone_analysis
where purchase_year in (2019, 2020, 2021)
group by
    purchase_year,
    product_name_cleaned
order by
    product_name_cleaned,
    purchase_year;