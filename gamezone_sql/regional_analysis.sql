-- Regional Performance: Main 5 KPIs

select
    analysis_region,
    round(sum(usd_price), 2) as revenue,
    count(distinct order_id) as orders,
    count(distinct user_id) as customers,
    round(sum(usd_price) / count(distinct order_id), 2) as aov,
    round(sum(usd_price) / count(distinct user_id), 2) as revenue_per_customer
from gamezone_analysis
group by analysis_region
order by revenue desc;


-- Product Mix by Region
with product_mix as (
    select
        analysis_region,
        product_name_cleaned,
        round(sum(usd_price), 2) as product_revenue,
        count(distinct order_id) as product_orders
    from gamezone_analysis
    where analysis_region <> 'Unknown'
    group by
        analysis_region,
        product_name_cleaned
)

select
    analysis_region,
    product_name_cleaned,
    product_revenue,
    product_orders,
    round(product_revenue / product_orders, 2) as revenue_per_order,
    round(
        product_orders * 100.0 /
        sum(product_orders) over (partition by analysis_region),
        2
    ) as order_share,
    round(
        product_revenue * 100.0 /
        sum(product_revenue) over (partition by analysis_region),
        2
    ) as revenue_share
from product_mix
order by
    analysis_region,
    product_revenue desc;


-- Product Revenue Share Across Regions
WITH product_region_revenue AS (
    SELECT
        analysis_region,
        product_name_cleaned,
        SUM(usd_price) AS regional_product_revenue
    FROM gamezone_analysis
    WHERE analysis_region <> 'Unknown'
    GROUP BY
        analysis_region,
        product_name_cleaned
)

SELECT
    analysis_region,
    product_name_cleaned,
    ROUND(regional_product_revenue, 2) AS regional_product_revenue,
    ROUND(
        100.0 * regional_product_revenue
        / SUM(regional_product_revenue) OVER (
            PARTITION BY product_name_cleaned
        ),
        2
    ) AS share_of_product_revenue
FROM product_region_revenue
ORDER BY
    product_name_cleaned,
    share_of_product_revenue DESC;