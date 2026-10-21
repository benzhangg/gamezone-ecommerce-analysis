-- Total revenue generated from each product
select
	product_name_cleaned,
	round(sum(usd_price), 2) as total_revenue,
	count(distinct order_id) as unique_orders
from 
	gamezone_analysis
group by 
	product_name_cleaned
order by
	total_revenue desc;


-- Revenue per order for each product and product revenue % over total revenue
select
	product_name_cleaned,
	round(sum(usd_price), 2) as total_revenue,
	count(distinct order_id) as unique_orders,
	round(sum(usd_price) / count(distinct order_id), 2) as revenue_per_order,
	round(sum(usd_price) / sum(sum(usd_price)) over () * 100, 2) as product_revenue_share
from
	gamezone_analysis
group by
	product_name_cleaned
order by
	total_revenue desc;


-- Monthly Product Performance

select
	purchase_month_year,
	product_name_cleaned,
	round(sum(usd_price), 2) as monthly_product_revenue,
	count(distinct order_id) as monthly_product_orders,
	round(sum(usd_price) / count(distinct order_id), 2) as monthly_product_revenue_per_order
from
	gamezone_analysis
where 
	purchase_month_year <> '1900-01-01'
group by
	purchase_month_year,
	product_name_cleaned
order by
	purchase_month_year,
	monthly_product_revenue desc;


-- Jan - Feb 2020 Product Revenue and Order Change
select
    product_name_cleaned,
    round(coalesce(sum(usd_price) filter (where purchase_month_year = '2020-01-01'), 0), 2) as jan_revenue,
    round(coalesce(sum(usd_price) filter (where purchase_month_year = '2020-02-01'), 0), 2) as feb_revenue,
    round(
        coalesce(sum(usd_price) filter (where purchase_month_year = '2020-02-01'), 0)
        - coalesce(sum(usd_price) filter (where purchase_month_year = '2020-01-01'), 0),
        2
    ) as revenue_change,
    count(distinct order_id) filter (where purchase_month_year = '2020-01-01') as jan_orders,
    count(distinct order_id) filter (where purchase_month_year = '2020-02-01') as feb_orders,
    count(distinct order_id) filter (where purchase_month_year = '2020-02-01')
    - count(distinct order_id) filter (where purchase_month_year = '2020-01-01') as order_change
from gamezone_analysis
where purchase_month_year in ('2020-01-01', '2020-02-01')
group by product_name_cleaned
order by revenue_change desc;
    

-- Feb - Mar 2020 Product Revenue and Order Change
select
    product_name_cleaned,
    round(coalesce(sum(usd_price) filter (where purchase_month_year = '2020-02-01'), 0), 2) as feb_revenue,
    round(coalesce(sum(usd_price) filter (where purchase_month_year = '2020-03-01'), 0), 2) as mar_revenue,
    round(
        coalesce(sum(usd_price) filter (where purchase_month_year = '2020-03-01'), 0)
        - coalesce(sum(usd_price) filter (where purchase_month_year = '2020-02-01'), 0),
        2
    ) as revenue_change,
    count(distinct order_id) filter (where purchase_month_year = '2020-02-01') as feb_orders,
    count(distinct order_id) filter (where purchase_month_year = '2020-03-01') as mar_orders,
    count(distinct order_id) filter (where purchase_month_year = '2020-03-01')
    - count(distinct order_id) filter (where purchase_month_year = '2020-02-01') as order_change
from gamezone_analysis
where purchase_month_year in ('2020-02-01', '2020-03-01')
group by product_name_cleaned
order by revenue_change desc;


-- Sep - Oct 2020 Product Revenue and Order Change
select
    product_name_cleaned,
    round(coalesce(sum(usd_price) filter (where purchase_month_year = '2020-09-01'), 0), 2) as sep_revenue,
    round(coalesce(sum(usd_price) filter (where purchase_month_year = '2020-10-01'), 0), 2) as oct_revenue,
    round(
        coalesce(sum(usd_price) filter (where purchase_month_year = '2020-10-01'), 0)
        - coalesce(sum(usd_price) filter (where purchase_month_year = '2020-09-01'), 0),
        2
    ) as revenue_change,
    count(distinct order_id) filter (where purchase_month_year = '2020-09-01') as sep_orders,
    count(distinct order_id) filter (where purchase_month_year = '2020-10-01') as oct_orders,
    count(distinct order_id) filter (where purchase_month_year = '2020-10-01')
    - count(distinct order_id) filter (where purchase_month_year = '2020-09-01') as order_change
from gamezone_analysis
where purchase_month_year in ('2020-09-01', '2020-10-01')
group by product_name_cleaned
order by revenue_change;


/*
 * Nov - Dec 2020 Product Revenue and Order Change
 */
select
    product_name_cleaned,
    round(coalesce(sum(usd_price) filter (where purchase_month_year = '2020-11-01'), 0), 2) as nov_revenue,
    round(coalesce(sum(usd_price) filter (where purchase_month_year = '2020-12-01'), 0), 2) as dec_revenue,
    round(
        coalesce(sum(usd_price) filter (where purchase_month_year = '2020-12-01'), 0)
        - coalesce(sum(usd_price) filter (where purchase_month_year = '2020-11-01'), 0),
        2
    ) as revenue_change,
    count(distinct order_id) filter (where purchase_month_year = '2020-11-01') as nov_orders,
    count(distinct order_id) filter (where purchase_month_year = '2020-12-01') as dec_orders,
    count(distinct order_id) filter (where purchase_month_year = '2020-12-01')
    - count(distinct order_id) filter (where purchase_month_year = '2020-11-01') as order_change
from gamezone_analysis
where purchase_month_year in ('2020-11-01', '2020-12-01')
group by product_name_cleaned
order by revenue_change desc;


/*
 * Dec 2020 - Jan 2021 Product Revenue and Order Change
 */
select
    product_name_cleaned,
    round(coalesce(sum(usd_price) filter (where purchase_month_year = '2020-12-01'), 0), 2) as dec_revenue,
    round(coalesce(sum(usd_price) filter (where purchase_month_year = '2021-01-01'), 0), 2) as jan_revenue,
    round(
        coalesce(sum(usd_price) filter (where purchase_month_year = '2021-01-01'), 0)
        - coalesce(sum(usd_price) filter (where purchase_month_year = '2020-12-01'), 0),
        2
    ) as revenue_change,
    count(distinct order_id) filter (where purchase_month_year = '2020-12-01') as dec_orders,
    count(distinct order_id) filter (where purchase_month_year = '2021-01-01') as jan_orders,
    count(distinct order_id) filter (where purchase_month_year = '2021-01-01')
    - count(distinct order_id) filter (where purchase_month_year = '2020-12-01') as order_change
from gamezone_analysis
where purchase_month_year in ('2020-12-01', '2021-01-01')
group by product_name_cleaned
order by revenue_change;


--Best Performing Product Sales in 2019 and 2020
select
    purchase_year,
    product_name_cleaned,
    round(sum(usd_price), 2) as product_revenue
from gamezone_analysis
where product_name_cleaned in (
    '27in 4K gaming monitor',
    'Nintendo Switch',
    'Sony PlayStation 5 Bundle'
)
and purchase_year in (2019, 2020)
group by
    purchase_year,
    product_name_cleaned
order by
    product_name_cleaned,
    purchase_year;


-- Worst Performing Product
select
    product_name_cleaned,
    count(distinct order_id) as total_orders,
    round(sum(usd_price), 2) as total_revenue,
    round(sum(usd_price) / count(distinct order_id), 2) as revenue_per_order
from gamezone_analysis
where product_name_cleaned = 'Razer Pro Gaming Headset'
group by product_name_cleaned;


-- Product Ranking by Sales
select
    product_name_cleaned,
    round(sum(usd_price), 2) as total_sales_revenue
from gamezone_analysis
group by product_name_cleaned
order by total_sales_revenue desc;


-- Tracks which months products had no sales
with months as (
    select distinct purchase_month_year
    from gamezone_analysis
    where purchase_month_year between '2019-01-01' and '2021-02-01'
),
products as (
    select distinct product_name_cleaned
    from gamezone_analysis
),
product_month_sales as (
    select
        product_name_cleaned,
        purchase_month_year,
        count(distinct order_id) as orders
    from gamezone_analysis
    where purchase_month_year between '2019-01-01' and '2021-02-01'
    group by
        product_name_cleaned,
        purchase_month_year
)
select
    p.product_name_cleaned,
    m.purchase_month_year
from products p
cross join months m
left join product_month_sales s
    on p.product_name_cleaned = s.product_name_cleaned
    and m.purchase_month_year = s.purchase_month_year
where coalesce(s.orders, 0) = 0
order by
    p.product_name_cleaned,
    m.purchase_month_year;


-- Orders, Revenue, and Revenue Per Order For Each Product
select
    product_name_cleaned,
    count(distinct order_id) as total_orders,
    round(sum(usd_price), 2) as total_revenue,
    round(
        sum(usd_price) / count(distinct order_id),
        2
    ) as revenue_per_order
from gamezone_analysis
group by product_name_cleaned
order by total_revenue desc;


	

	
	
	
