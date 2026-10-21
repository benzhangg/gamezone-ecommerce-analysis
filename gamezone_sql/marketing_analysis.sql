-- Marketing Channel Peformance: Main 5 KPIs

select
	marketing_channel_cleaned,
	round(sum(usd_price), 2) as revenue,
	count(distinct order_id) as orders,
	count(distinct user_id) as customers,
	round(sum(usd_price) / count(distinct order_id), 2) as aov,
	round(sum(usd_price) / count(distinct user_id), 2) as revenue_per_customer
from gamezone_analysis
group by marketing_channel_cleaned
order by revenue desc;


-- Product Mix by Marketing Channel
with product_mix as (
    select
        marketing_channel_cleaned,
        product_name_cleaned,
        round(sum(usd_price), 2) as product_revenue,
        count(distinct order_id) as product_orders
    from gamezone_analysis
    where marketing_channel_cleaned in ('direct', 'affiliate', 'email')
    group by
        marketing_channel_cleaned,
        product_name_cleaned
)

select
    marketing_channel_cleaned,
    product_name_cleaned,
    product_revenue,
    product_orders,
    round(product_revenue / product_orders, 2) as revenue_per_order,
    round(
        product_orders * 100.0 /
        sum(product_orders) over (partition by marketing_channel_cleaned),
        2
    ) as order_share,
    round(
        product_revenue * 100.0 /
        sum(product_revenue) over (partition by marketing_channel_cleaned),
        2
    ) as revenue_share
from product_mix
order by
    marketing_channel_cleaned,
    product_revenue desc;


-- Purchase Platform Performance: Main 5 KPIs
select
    purchase_platform,
    round(sum(usd_price), 2) as revenue,
    count(distinct order_id) as orders,
    count(distinct user_id) as customers,
    round(sum(usd_price) / count(distinct order_id), 2) as aov,
    round(sum(usd_price) / count(distinct user_id), 2) as revenue_per_customer
from gamezone_analysis
group by purchase_platform
order by revenue desc;


-- Product Mix by Purchase Platform
select
    purchase_platform,
    product_name_cleaned,
    round(sum(usd_price), 2) as revenue,
    count(distinct order_id) as orders,
    round(sum(usd_price) / count(distinct order_id), 2) as revenue_per_order
from gamezone_analysis
group by
    purchase_platform,
    product_name_cleaned
order by
    purchase_platform,
    revenue desc;


-- Check whether customers appear under multiple marketing channels
select 
	user_id,
	count(distinct marketing_channel_cleaned) as channel_count
from gamezone_analysis
group by user_id
having count(distinct marketing_channel_cleaned) > 1;


-- Repeat Customer Rate by Marketing Channel
with customer_summary as (
	select
		user_id,
		marketing_channel_cleaned,
		count(distinct order_id) as total_orders
	from gamezone_analysis
	group by
		user_id,
		marketing_channel_cleaned
)

select
	marketing_channel_cleaned,
	count(*) as customers,
	count(*) filter (
        where total_orders > 1
    ) as repeat_customers,
    round(
        count(*) filter (where total_orders > 1) * 100.0
        / count(*),
        2
    ) as repeat_rate
from customer_summary
group by marketing_channel_cleaned
order by repeat_rate desc;


-- Check whether customers appear under multiple purchase platforms (website and mobile)
select
    user_id,
    count(distinct purchase_platform) as platform_count
from gamezone_analysis
group by user_id
having count(distinct purchase_platform) > 1;


-- Repeat Customer Rate by Purchase Platform

with customer_summary as (
	select
		user_id,
		purchase_platform,
		count(distinct order_id) as total_orders
	from gamezone_analysis
	group by 
		user_id,
		purchase_platform
)

select
	purchase_platform,
	count(*) as customers,
	count(*) filter (
        where total_orders > 1
    ) as repeat_customers,
    round(
        count(*) filter (where total_orders > 1) * 100.0
        / count(*),
        2
    ) as repeat_rate
from customer_summary
group by purchase_platform
order by repeat_rate desc;


-- Marketing Channel x Purchase Platform Interaction

with channel_platform as (
	select
		marketing_channel_cleaned,
		purchase_platform,
		round(sum(usd_price), 2) as revenue,
		count(distinct order_id) as orders,
		count(distinct user_id) as customers
	from gamezone_analysis
	group by 
		marketing_channel_cleaned,
		purchase_platform
)
select
	marketing_channel_cleaned,
	purchase_platform,
	revenue,
	orders,
	customers,
	round(revenue / orders, 2) as aov,
	round(revenue / customers, 2) as revenue_per_customer,
	round(
        orders * 100.0 /
        sum(orders) over (partition by marketing_channel_cleaned),
        2
    ) as platform_order_share,
    round(
    	revenue * 100.0 /
        sum(revenue) over (partition by marketing_channel_cleaned),
        2
    ) as platform_revenue_share
from channel_platform
order by
	marketing_channel_cleaned,
	revenue desc;