/*
 * Creates a view/saved query of orders_cleaned so orders_cleaned is not directly modified
 */
create or replace view gamezone_analysis as
select
    orders_cleaned.*,
    coalesce(region_cleaned.region_cleaned, 'Unknown') as analysis_region
from
    orders_cleaned
left join region_cleaned
    on orders_cleaned.country_code = region_cleaned.country_code;


/*
 * Count of unique orders
 */
select
    count(distinct order_id) as unique_orders
from
    gamezone_analysis;

/*
 * Count of unique customers
 */
select
	count(distinct user_id) as unique_customers
from
	gamezone_analysis;

/*
 * Total revenue
 */
select 
	round(sum(usd_price), 2) as total_revenue
from
	gamezone_analysis;

/*
 * The amount of revenue generated from duplicate orders only
 */

with duplicate_orders as (
    select
        order_id,
        usd_price,
        row_number() over (
            partition by order_id
            order by order_id
        ) as row_num
    from
        gamezone_analysis
)

select
    sum(usd_price) as duplicate_revenue
from
    duplicate_orders
where
    row_num > 1;


/*
 * Average Order Value (AOV)
 */
select
    sum(usd_price) / count(distinct order_id) as avg_order_value
from
    gamezone_analysis;


/*
 * Revenue Per Customer
 */
select
    round(sum(usd_price) / count(distinct user_id), 2) as revenue_per_customer
from
    gamezone_analysis;


/*
 * Monthly unique orders
 */
select
    purchase_month_year,
    count(distinct order_id) as unique_orders
from
    gamezone_analysis
where
    purchase_month_year <> '1900-01-01'
group by purchase_month_year
order by purchase_month_year;


/*
 * Monthly unique customers
 */
select
    purchase_month_year,
    count(distinct user_id) as unique_customers
from
    gamezone_analysis
where
    purchase_month_year <> '1900-01-01'
group by purchase_month_year
order by purchase_month_year;


-- Monthly Revenue
select
    purchase_month_year,
    round(sum(usd_price), 2) as monthly_revenue
from
    gamezone_analysis
where
    purchase_month_year <> '1900-01-01'
group by
    purchase_month_year
order by
    purchase_month_year;

/*
 * Monthly AOV
 */
select
    purchase_month_year,
    round(sum(usd_price) / count(distinct order_id), 2) as monthly_avg_order_value
from
    gamezone_analysis
where
    purchase_month_year <> '1900-01-01'
group by purchase_month_year
order by purchase_month_year;


/*
 * Monthly Revenue Per Customer
 */
select
    purchase_month_year,
    round(sum(usd_price) / count(distinct user_id), 2) as monthly_revenue_per_customer
from
    gamezone_analysis
where
    purchase_month_year <> '1900-01-01'
group by purchase_month_year
order by purchase_month_year;


/*
 * Combined Monthly Summary
 */
select
    purchase_month_year,
    round(sum(usd_price), 2) as monthly_revenue,
    count(distinct order_id) as unique_orders,
    count(distinct user_id) as unique_customers,
    round(
        sum(usd_price) / count(distinct order_id),
        2
    ) as monthly_avg_order_value,
    round(
        sum(usd_price) / count(distinct user_id),
        2
    ) as monthly_revenue_per_customer
from
    gamezone_analysis
where
    purchase_month_year <> '1900-01-01'
group by
    purchase_month_year
order by
    purchase_month_year;


-- Month over Month KPI Summary

with monthly_summary as (
    select
        purchase_month_year,
        round(sum(usd_price), 2) as monthly_revenue,
        count(distinct order_id) as unique_orders,
        count(distinct user_id) as unique_customers,
        round(
            sum(usd_price) / count(distinct order_id),
            2
        ) as monthly_aov,
        round(
            sum(usd_price) / count(distinct user_id),
            2
        ) as monthly_revenue_per_customer
    from
        gamezone_analysis
    where
        purchase_month_year <> '1900-01-01'
    group by
        purchase_month_year
),

monthly_growth as (
    select
        purchase_month_year,
        monthly_revenue,
        unique_orders,
        unique_customers,
        monthly_aov,
        monthly_revenue_per_customer,

        lag(monthly_revenue) over (
            order by purchase_month_year
        ) as previous_revenue,

        lag(unique_orders) over (
            order by purchase_month_year
        ) as previous_orders,

        lag(unique_customers) over (
            order by purchase_month_year
        ) as previous_customers,

        lag(monthly_aov) over (
            order by purchase_month_year
        ) as previous_aov,

        lag(monthly_revenue_per_customer) over (
            order by purchase_month_year
        ) as previous_revenue_per_customer

    from
        monthly_summary
)

select
    purchase_month_year,

    round(
        (monthly_revenue - previous_revenue)
        / previous_revenue * 100,
        2
    ) as mom_revenue_growth,

    round(
        (unique_orders - previous_orders) * 100.0
        / previous_orders,
        2
    ) as mom_order_growth,

    round(
        (unique_customers - previous_customers) * 100.0
        / previous_customers,
        2
    ) as mom_customer_growth,

    round(
        (monthly_aov - previous_aov)
        / previous_aov * 100,
        2
    ) as mom_aov_growth,

    round(
        (monthly_revenue_per_customer - previous_revenue_per_customer)
        / previous_revenue_per_customer * 100,
        2
    ) as mom_revenue_per_customer_growth

from
    monthly_growth
order by
    purchase_month_year;




