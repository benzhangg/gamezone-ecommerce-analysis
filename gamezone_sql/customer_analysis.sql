-- Total orders and total revenue for each customer
select
	user_id,
	count(distinct order_id) as total_orders,
	round(sum(usd_price), 2) as total_revenue
from gamezone_analysis
group by user_id
order by total_revenue desc;


--Count of one time and repeat customers and revenue based on customer type
with customer_summary as (
	select
		user_id,
		count(distinct order_id) as total_orders,
		round(sum(usd_price), 2) as total_revenue
	from gamezone_analysis
	group by user_id
)

select
	case
		when total_orders = 1 then 'One time'
		else 'Repeat'
	end as customer_type,
	count(*) as customers,
	sum(total_orders) as orders,
	round(sum(total_revenue), 2) as revenue,
	round(avg(total_revenue), 2) as avg_revenue_per_customer,
	round(sum(total_revenue) / sum(total_orders), 2) as revenue_per_order
from customer_summary
group by customer_type;


--Top 10% Customers vs Bottom 90% Customers Based on Spending
with customer_summary as (
	select
		user_id,
		round(sum(usd_price), 2) as total_revenue
	from gamezone_analysis
	group by user_id
),

ranked_customers as (
	select
		user_id,
		total_revenue,
		ntile(10) over (order by total_revenue desc nulls last) as revenue_group
	from customer_summary
)

select
	case
		when revenue_group = 1 then 'Top 10%'
		else 'Other 90%'
	end as customer_spending_percentile,
	count(*) as customers,
	round(sum(total_revenue), 2) as revenue,
	round(sum(total_revenue) / (select sum(usd_price) from gamezone_analysis) * 100, 2) as revenue_share
from ranked_customers
group by customer_spending_percentile
order by customer_spending_percentile desc;
	

-- Assign customers to acquisition cohorts
with customer_cohorts as (
	select
    	user_id,
    	min(purchase_month_year) as cohort_month
	from gamezone_analysis
	where purchase_month_year <> '1900-01-01'
  		and purchase_month_year is not null
	group by user_id
),


-- All the months that each customer made purchases in
customer_activity as (
    select distinct
        user_id,
        purchase_month_year
    from gamezone_analysis
    where purchase_month_year <> '1900-01-01'
      and purchase_month_year is not null
)

--Retention Rate based on returning customers / total customers for each cohort month
select
	cohort_month,
	count(*) as total_customers,
	count(a.user_id) as returning_customers,
	round(count(a.user_id) * 100.0 / count(*), 2) as retention_rate
from customer_cohorts c
left join customer_activity a
	on c.user_id = a.user_id
	and a.purchase_month_year = (c.cohort_month + interval '1 month')::date
where c.cohort_month < '2021-01-01'
group by c.cohort_month
order by c.cohort_month;


-- 3-Month Customer Retention
with customer_cohorts as (
    select
        user_id,
        min(purchase_month_year) as cohort_month
    from gamezone_analysis
    where purchase_month_year <> '1900-01-01'
        and purchase_month_year is not null
    group by user_id
),

customer_activity as (
    select distinct
        user_id,
        purchase_month_year
    from gamezone_analysis
    where purchase_month_year <> '1900-01-01'
        and purchase_month_year is not null
)

select
    c.cohort_month,
    count(distinct c.user_id) as total_customers,
    count(distinct a.user_id) as returning_customers,
    round(
        count(distinct a.user_id) * 100.0 /
        count(distinct c.user_id),
        2
    ) as retention_rate
from customer_cohorts c
left join customer_activity a
    on c.user_id = a.user_id
    and a.purchase_month_year between
        (c.cohort_month + interval '1 month')::date
        and (c.cohort_month + interval '3 months')::date
where c.cohort_month < '2020-11-01'
group by c.cohort_month
order by c.cohort_month;
	

-- 6-Month Customer Retention
with customer_cohorts as (
    select
        user_id,
        min(purchase_month_year) as cohort_month
    from gamezone_analysis
    where purchase_month_year <> '1900-01-01'
        and purchase_month_year is not null
    group by user_id
),

customer_activity as (
    select distinct
        user_id,
        purchase_month_year
    from gamezone_analysis
    where purchase_month_year <> '1900-01-01'
        and purchase_month_year is not null
)

select
    c.cohort_month,
    count(distinct c.user_id) as total_customers,
    count(distinct a.user_id) as returning_customers,
    round(
        count(distinct a.user_id) * 100.0 /
        count(distinct c.user_id),
        2
    ) as retention_rate
from customer_cohorts c
left join customer_activity a
    on c.user_id = a.user_id
    and a.purchase_month_year between
        (c.cohort_month + interval '1 month')::date
        and (c.cohort_month + interval '6 months')::date
where c.cohort_month < '2020-08-01'
group by c.cohort_month
order by c.cohort_month;


-- 12-Month Customer Retention
with customer_cohorts as (
    select
        user_id,
        min(purchase_month_year) as cohort_month
    from gamezone_analysis
    where purchase_month_year <> '1900-01-01'
        and purchase_month_year is not null
    group by user_id
),

customer_activity as (
    select distinct
        user_id,
        purchase_month_year
    from gamezone_analysis
    where purchase_month_year <> '1900-01-01'
        and purchase_month_year is not null
)

select
    c.cohort_month,
    count(distinct c.user_id) as total_customers,
    count(distinct a.user_id) as returning_customers,
    round(
        count(distinct a.user_id) * 100.0 /
        count(distinct c.user_id),
        2
    ) as retention_rate
from customer_cohorts c
left join customer_activity a
    on c.user_id = a.user_id
    and a.purchase_month_year between
        (c.cohort_month + interval '1 month')::date
        and (c.cohort_month + interval '12 months')::date
where c.cohort_month < '2020-02-01'
group by c.cohort_month
order by c.cohort_month;



-- Customer Type of Top 10% Customers

WITH customer_summary AS (
    SELECT
        user_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(usd_price) AS total_revenue
    FROM gamezone_analysis
    GROUP BY user_id
),

ranked_customers AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank,
        COUNT(*) OVER () AS total_customers
    FROM customer_summary
),

top_10_percent AS (
    SELECT
        *,
        CASE
            WHEN total_orders = 1 THEN 'One-Time'
            ELSE 'Repeat'
        END AS customer_type
    FROM ranked_customers
    WHERE revenue_rank <= CEIL(total_customers * 0.10)
)

SELECT
    customer_type,
    COUNT(*) AS customers,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percent_of_top_10
FROM top_10_percent
GROUP BY customer_type
ORDER BY customers DESC;



-- AOV for Repeat and One Time Customers

WITH customer_summary AS (
    SELECT
        user_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM gamezone_analysis
    GROUP BY user_id
),

customer_type AS (
    SELECT
        user_id,
        CASE
            WHEN total_orders = 1 THEN 'One-Time'
            ELSE 'Repeat'
        END AS customer_type
    FROM customer_summary
),

monthly_aov AS (
    SELECT
        g.purchase_month_year,
        c.customer_type,
        COUNT(DISTINCT g.order_id) AS orders,
        ROUND(
            SUM(g.usd_price) / COUNT(DISTINCT g.order_id),
            2
        ) AS aov
    FROM gamezone_analysis g
    JOIN customer_type c
        ON g.user_id = c.user_id
    WHERE g.purchase_month_year IS NOT NULL
      AND g.purchase_month_year <> '1900-01-01'
    GROUP BY
        g.purchase_month_year,
        c.customer_type
),

monthly_compare AS (
    SELECT
        purchase_month_year,
        MAX(CASE WHEN customer_type = 'One-Time' THEN aov END) AS one_time_aov,
        MAX(CASE WHEN customer_type = 'Repeat' THEN aov END) AS repeat_aov,
        MAX(CASE WHEN customer_type = 'One-Time' THEN orders END) AS one_time_orders,
        MAX(CASE WHEN customer_type = 'Repeat' THEN orders END) AS repeat_orders
    FROM monthly_aov
    GROUP BY purchase_month_year
)

SELECT
    *,
    ROUND(repeat_aov - one_time_aov, 2) AS aov_gap
FROM monthly_compare
ORDER BY purchase_month_year;


-- Yearly performance: One-Time vs Repeat Customers
WITH customer_summary AS (
    SELECT
        user_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM gamezone_analysis
    GROUP BY user_id
),

customer_type AS (
    SELECT
        user_id,
        CASE
            WHEN total_orders = 1 THEN 'One-Time'
            ELSE 'Repeat'
        END AS customer_type
    FROM customer_summary
),

yearly_summary AS (
    SELECT
        EXTRACT(YEAR FROM g.purchase_month_year)::INT AS year,
        c.customer_type,

        COUNT(DISTINCT g.user_id) AS customers,
        COUNT(DISTINCT g.order_id) AS orders,
        ROUND(SUM(g.usd_price), 2) AS revenue,

        ROUND(
            SUM(g.usd_price) / COUNT(DISTINCT g.order_id),
            2
        ) AS aov

    FROM gamezone_analysis g

    JOIN customer_type c
        ON g.user_id = c.user_id

    WHERE g.purchase_month_year IS NOT NULL
      AND EXTRACT(YEAR FROM g.purchase_month_year) IN (2019, 2020)

    GROUP BY
        year,
        c.customer_type
),

with_growth AS (
    SELECT
        *,
        
        ROUND(
            100.0 * (
                revenue
                / LAG(revenue) OVER (
                    PARTITION BY customer_type
                    ORDER BY year
                ) - 1
            ),
            2
        ) AS revenue_growth_pct,

        ROUND(
            100.0 * (
                orders::NUMERIC
                / LAG(orders) OVER (
                    PARTITION BY customer_type
                    ORDER BY year
                ) - 1
            ),
            2
        ) AS order_growth_pct,

        ROUND(
            100.0 * (
                aov
                / LAG(aov) OVER (
                    PARTITION BY customer_type
                    ORDER BY year
                ) - 1
            ),
            2
        ) AS aov_growth_pct

    FROM yearly_summary
)

SELECT *
FROM with_growth
ORDER BY customer_type, year;


--Product Mix by Customer Type
WITH customer_summary AS (
    SELECT
        user_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM gamezone_analysis
    GROUP BY user_id
),

customer_orders AS (
    SELECT
        g.user_id,
        g.order_id,
        g.product_name_cleaned,
        g.usd_price,
        CASE
            WHEN c.total_orders = 1 THEN 'One-Time'
            ELSE 'Repeat'
        END AS customer_type
    FROM gamezone_analysis g
    JOIN customer_summary c
        ON g.user_id = c.user_id
),

product_mix AS (
    SELECT
        customer_type,
        product_name_cleaned,
        COUNT(DISTINCT (user_id, order_id)) AS product_orders,
        ROUND(SUM(usd_price), 2) AS product_revenue
    FROM customer_orders
    GROUP BY
        customer_type,
        product_name_cleaned
)

SELECT
    customer_type,
    product_name_cleaned,
    product_orders,

    ROUND(
        product_orders * 100.0
        / SUM(product_orders) OVER (
            PARTITION BY customer_type
        ),
        2
    ) AS order_share,

    product_revenue,

    ROUND(
        product_revenue / product_orders,
        2
    ) AS revenue_per_order,

    ROUND(
        product_revenue * 100.0
        / SUM(product_revenue) OVER (
            PARTITION BY customer_type
        ),
        2
    ) AS revenue_share

FROM product_mix
ORDER BY
    customer_type,
    order_share DESC;
