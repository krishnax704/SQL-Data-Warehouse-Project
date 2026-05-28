/* Product Report — Business Questions */
-- Product Sales Performance
-- 1) Which products generate the highest total revenue?
select top 10
	product_key,
	product_name,
	category,
	subcategory,
	total_sales
from gold.report_product
order by total_sales desc;

-- 2) Which products sell the highest quantity?
select top 10
	product_key,
	product_name,
	category,
	subcategory,
	quantity_sold
from gold.report_product
order by quantity_sold desc;

-- 3) Which products receive the highest number of orders?
select top 10
	product_key,
	product_name,
	category,
	subcategory,
	total_orders,
	quantity_sold
from gold.report_product
order by total_orders desc;

-- 4) Which products have the highest average order revenue?
select top 10
	product_key,
	product_name,
	category,
	subcategory,
	avg_order_revenue
from gold.report_product
order by avg_order_revenue desc;

-- 5) Which products generate the highest monthly revenue?
select top 10
	product_key,
	product_name,
	category,
	subcategory,
	avg_monthly_revenue
from gold.report_product
order by avg_monthly_revenue desc;

-- Product Category Analysis
-- 1) Which product category contributes the most sales?
select top 10
	category,
	subcategory,
	total_sales
from gold.report_product
order by total_sales desc;

-- 2) Which subcategory has the highest demand?
select top 10
	subcategory,
	sum(quantity_sold) as quantity_sold
from gold.report_product
group by subcategory
order by quantity_sold desc;

-- 3) Which categories have the highest average selling price?
select top 10
	category,
	round(avg(avg_selling_price),0) as avg_selling_price
from gold.report_product
group by category
order by avg_selling_price desc;

-- 4) Which categories attract the highest number of customers?
select top 1
	category,
	sum(total_customers) as total_customers
from gold.report_product
group by category
order by sum(total_customers) desc;

-- 5)Which subcategories underperform in revenue generation?
with cte1 as (
select 
	subcategory,
	sum(total_sales) as total_sales
from gold.report_product
group by subcategory
), cte2 as (
select 
	*, 
	avg(total_sales) over() as avg_sales FROM cte1
), cte3 as (
select 
	*, 
	case when avg_sales > total_sales then 'underperform'
	else 'overperform'
	   end as performance_segment
	from cte2
) 
select * from cte3
where performance_segment = 'underperform'

-- Product Lifecycle & Demand
-- 1) Which products have not been sold recently?
select
	product_name,
	category,
	subcategory,
	recency_in_months
from gold.report_product
order by recency_in_months desc;

-- 2) Which products have the longest sales lifespan?
select
	product_name,
	category,
	subcategory,
	lifespan
from gold.report_product
order by lifespan desc;

-- 3) Which products are near the end of their lifecycle?
select
	product_name,
	category,
	product_segment,
	lifespan,
	recency_in_months
from gold.report_product
order by lifespan asc,
		 recency_in_months desc;

-- 4) Which products show stable long-term demand?
select top 10
	product_name,
	product_segment,
	category,
	lifespan,	
	recency_in_months
from gold.report_product
order by lifespan desc,
		 recency_in_months asc;


-- Product Segment Analysis
-- 1) How do High Performer and Mid-Range products compare in revenue?
select 
	product_segment,
	count(product_name) as count_pr_name,
	sum(total_sales) as total_sales,
	avg(total_sales) as avg_sales
from gold.report_product
where product_segment in ('High Performer', 'Mid-Range')
group by product_segment
order by total_sales;

-- 2) Which product segment drives the highest quantity sold?
select
	product_segment,
	sum(quantity_sold) as total_qty_sold
from gold.report_product
group by product_segment
order by total_qty_sold desc;

-- 3) Which segment has the highest average monthly revenue?
select
	product_segment,
	avg(avg_monthly_revenue) as avg_monthly_revenue
from gold.report_product
group by product_segment
order by avg_monthly_revenue desc;

-- 4) Which segment attracts the most customers?
select 
	product_segment,
	sum(total_customers) as total_customers
from gold.report_product
group by product_segment
order by sum(total_customers) desc;

-- 5) Which product segment has the best revenue consistency?
select 
	product_segment,
	avg(avg_monthly_revenue) as avg_monthly_revenue,
	round(STDEV(avg_monthly_revenue),2) as monthly_revenue_variation
from gold.report_product
group by product_segment
order by monthly_revenue_variation desc;
