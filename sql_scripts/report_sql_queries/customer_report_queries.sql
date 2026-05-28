/* 
====================================================================================
Customer Report
====================================================================================
Purpose:
	 - This report consolidates key customer metrics and behaviours

Highlights:
	1. Gather essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
	   - Total Orders
	   - Total Sales
	   - Total quantity purchased
	   - Total Products
	   - Lifespan (in months)
	4. Calculates valuabale KPIs:
	   - Recency (months sinve last last orders)
	   - Average Order Value
	   - Average monthly spend
====================================================================================
*/

CREATE VIEW gold.report_customer as
with base_query as (
/*--------------------------------------------------------------------------------
1) Base Query: Retreives core columns from tables
----------------------------------------------------------------------------------*/
select 
	 f.order_number,
	 f.product_key,
	 f.order_date,
	 f.sales_amount,
	 f.quantity,
	 c.customer_key,
	 c.customer_number,
	 CONCAT(c.first_name, ' ', c.last_name) as customer_name,
	 DATEDIFF(YEAR, c.birth_date, getdate()) as age
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
where order_date is not null)

, customer_aggregation as (
/*--------------------------------------------------------------------------------
2) Customer Aggregation: Summarizes key metricsat the customer level
----------------------------------------------------------------------------------*/
select 
	 customer_key,
	 customer_number,
	 customer_name,
	 age,
	 COUNT(distinct order_number) as total_orders,
	 SUM(sales_amount) as total_sales,
	 SUM(quantity) as total_quantity,
	 COUNT(distinct product_key) as total_products,
	 MAX(order_date) as last_order_date,
	 DATEDIFF(month, min(order_date), max(order_date)) as lifespan
from 
base_query
group by 
     customer_key,
	 customer_number,
	 customer_name,
	 age
)
select 
	 customer_key,
	 customer_number,
	 customer_name,
	 age,
	 case when age between 40 and 49 then '40-49'
		  when age between 50 and 59 then '50-59'
		  when age between 60 and 69 then '60-69'
		  when age between 70 and 79 then '70-79'
	 else '80 and Above'
	 end as age_group,
	 case when lifespan >= 12 and total_sales > 5000 then 'VIP'
				 when lifespan >= 12 and total_sales <= 5000 then 'Regular'
				 else 'New'
	 end as customer_segment,
	 last_order_date,
	 DATEDIFF(month, last_order_date, getdate()) as recency,
	 total_orders,
	 total_sales,
	 total_quantity,
	 total_products,
	 lifespan,
-- Compute average order value (AVO)
	 case when total_orders = 0 then 0
		  else total_sales / total_orders
	 end as avg_order_value,
-- Compute average monthly spend
	 case when lifespan = 0 then total_sales
		else total_sales / lifespan
	 end as avg_monthly_spend
from customer_aggregation