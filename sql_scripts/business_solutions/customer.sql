select * from gold.report_customer

/* Customer Report — Business Questions
Customer Segmentation */

--Which customer segment contributes the highest revenue?
select 
	customer_segment,
	sum(total_sales) as total_sales
from gold.report_customer
group by customer_segment
order by total_sales desc

--What is the distribution of customers across VIP, Regular, and New segments?
select
	customer_segment,
	count(customer_name) as total_customers
from gold.report_customer
group by customer_segment

--Which age group generates the most sales?
select 
	age_group,
	sum(total_sales) as total_sales
from gold.report_customer
group by age_group
order by total_sales desc

--Which customer segment has the highest average order value?
select 
	customer_segment,
	avg_order_value,
	rank() over(order by avg_order_value desc) as rank
from gold.report_customer


--Which age group purchases most frequently?
select
	age_group,
	sum(total_orders) as total_orders,
	sum(total_sales) as total_sales
from gold.report_customer
group by age_group
order by total_orders desc;

/* Customer Purchase Behavior */
-- 1) Who are the top 10 customers by total sales?
select top 10
	customer_number,
	customer_name,
	total_sales as total_sales
from gold.report_customer
order by total_sales desc;

-- 2) Which customers place the highest number of orders?
select top 10
	customer_name,
	total_orders
from gold.report_customer
order by total_orders desc

-- 3) Which customers purchase the highest quantity of products?
select top 10
	customer_name,
	total_quantity
from gold.report_customer
order by total_quantity desc

-- 4) What is the average monthly spending per customer segment?
select 
	customer_segment,
	avg(avg_order_value) as avg_order_value
from gold.report_customer
group by customer_segment
order by avg_order_value desc

-- 5) Which customers buy the widest variety of products?
select top 10
	customer_name,
	customer_segment,
	total_products,
	total_sales
from gold.report_customer
order by total_products desc

/* Customer Retention & Loyalty */
-- 1) Which customers are most loyal based on lifespan?
select top 10
	customer_name,
	lifespan,
	total_orders,
	total_quantity,
	total_sales
from gold.report_customer
order by lifespan desc,
		 total_sales desc

-- 2) Which customers are inactive based on recency?
select 
	customer_number,
	customer_name,
	recency
from gold.report_customer
order by recency desc;

-- 3) Which customer segment has the highest retention rate?
select
	customer_segment,
	count(customer_name) as customer_name ,
	avg(recency) as avg_recency,
	avg(lifespan) as avg_lifespan
from gold.report_customer
group by customer_segment
order by avg_recency;

-- 4) Which customers are at risk of churn?
select
	customer_name,
	customer_segment,
	recency,
	total_sales
from gold.report_customer
order by recency desc

-- 5) How does customer lifespan impact total sales?
select
	customer_name,
	lifespan,
	total_sales,
	total_orders
from gold.report_customer
order by lifespan desc;

/* Revenue & Profitability */
-- 1) Which customers generate the highest lifetime value?
select top 10
	customer_key,
	customer_name,
	total_sales
from gold.report_customer
order by total_sales desc;

-- 2) What is the average revenue generated per customer?
select
	customer_key,
	customer_name,
	avg_monthly_spend
from gold.report_customer
order by avg_monthly_spend desc;

-- 3) Which segment contributes the most to overall revenue?
select
	customer_segment,
	sum(total_sales) as total_sales
from gold.report_customer
group by customer_segment
order by total_sales desc;

-- 4) Is there a relationship between order frequency and customer spending?
select
	customer_name,
	customer_segment,
	lifespan,
	recency,
	total_sales,
	total_orders
from gold.report_customer
order by 
	total_orders desc,
	total_sales desc;

-- 5) Which customers should be targeted for upselling or retention campaigns?
-- Upselling
select
	customer_name,
	customer_segment,
	recency,
	lifespan,
	total_orders,
	total_quantity,
	total_sales
from gold.report_customer
where customer_segment = 'VIP'
order by total_sales desc;

-- Retention
select
	customer_name,
	customer_segment,
	total_orders,
	total_quantity,
	lifespan,
	total_sales
from gold.report_customer
where 
	recency > 150 and
	lifespan > 12 and
	total_orders > 1
order by 
	recency desc,
	lifespan desc
