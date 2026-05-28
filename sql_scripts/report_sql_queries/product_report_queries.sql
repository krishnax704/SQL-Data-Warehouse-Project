/*
=========================================================================
Product Report
=========================================================================
Purpose:
	- This report consolidates key product metrics and behaviours.

Highlights:
	1. Gathers essential fields such as product name, category, subcategory and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level- metrics:
	   - total orders
	   - total sales
	   - total quantity sold
	   - total customers (unique)
	   - lifespan (in months)
	4. Calculates valuable KPIs:
	   - recency (months since last sale)
	   - average order reveneu (AOR)
	   - average monthly revenue
=========================================================================
*/

create view gold.report_product as
with base_query as (
select
	c.customer_number,
    s.order_number,
	p.product_key,
	p.product_number,
	p.product_name,
	p.category,
	p.subcategory,
	s.quantity,
	p.cost,
	s.sales_amount,
	s.order_date
from gold.dim_products p
left join gold.fact_sales s
on p.product_key = s.product_key
join gold.dim_customers c
on c.customer_key = s.customer_key
where order_date is not null)
, product_aggregation as (
/* ----------------------------------------------------
1) Product Aggregations: Summarizes Key metrics at the product level
-------------------------------------------------------*/
select 
	product_key,
    product_number,
	product_name,
	category,
	subcategory,
	cost,
	count(order_number) as total_orders,
	sum(quantity) as quantity_sold,
	count(distinct customer_number) as total_customers,
	max(order_date) as last_sale_date,
	DATEDIFF(month, min(order_date), max(order_date)) as lifespan,
	sum(sales_amount) as total_sales,
	(sales_amount/quantity) as avg_selling_price
from base_query
group by
	product_number,
	product_name,
	category,
	subcategory,
	cost,
	(sales_amount/quantity),
	product_key)
select 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,

-- Calculation of recency (Months Since Last Sale)
	DATEDIFF(month, last_sale_date, getdate()) as recency_in_months,

-- Calculation of product segment as High Performer, Mid Range, Low Performer
	case when total_sales > 50000 then 'High Performer'
		 when total_sales < 50000 then 'Mid-Range'
		 else 'Low Performer'
	end as product_segment,
	lifespan,
	total_orders,
	total_sales,
	quantity_sold,
	total_customers,
	avg_selling_price,

-- Calculation of Average Order Revenue
	case 
		when total_orders = 0 then 0
	else 
		total_sales/total_orders
	end as avg_order_revenue,

-- Calculation of Average Monthly Revenue
	case
		when lifespan = 0 then 0 
		else total_sales/lifespan
	end as avg_monthly_revenue
from product_aggregation

	
