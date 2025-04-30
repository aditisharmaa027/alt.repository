create database ev_vehicles 


select top 2 * from order_tbl
select top 2 * from payments

-- Analyze order status and sales data to provide insights into order
--  fulfillment and revenue trends. Identify key metrics and trends related to
--  order status and sales.

--1  total no. of rows in each table? 
select count(*) from order_tbl  
select count(*) from payments 

-- total orders by order status 
select order_status, count(*) as total_orders
from order_tbl 
group by order_status 



-- count of cust_id which have payment status as completed? 
select  count(*) from (
select customer_id from order_tbl as a 
join payments as b 
on a.order_id = b.order_id
where payment_status = 'completed' ) as A


-- failed payment status 
select  count(*) from (
select customer_id from order_tbl as a 
join payments as b 
on a.order_id = b.order_id
where payment_status = 'failed' ) as A


-- percentage of sales where according to customer_id
select customer_id,(sum(cast(payment_amount as float))/(select sum(cast(payment_amount as float)) 
as total_sales from payments ))as percent_sales, sum(payment_amount) as total_sales from payments as a 
join order_tbl as b 
on a.order_id = b.order_id  
group by customer_id
order by total_sales, percent_sales desc

-- count of last 30 days transaction 
select count(*) from (
select order_id , convert(date,payment_date ,105) as trans_date from payments
group by order_id ,convert(date, payment_date,105)
having convert(date,payment_date,105) >= (select dateadd(day, -30,max(convert(date, payment_date,105)))
as cutoff_date  from payments) 
) as A 

-- total orders which got deliverd 

select sum(order_amount) as total_sales from order_tbl
where order_status = 'Delivered'

-- monthly sales trend 
select format(order_date,'yyyy-MM') as month,sum(order_amount) as total_sales from order_tbl 
where order_status = 'Delivered'
group by format(order_date,'yyyy-MM')
order by  month

-- total revenue from payments 

select format(payment_date ,'yyyy-MM') AS MONTH,SUM(payment_amount)as payment_received
from payments as a 
join order_tbl as b 
on a.order_id = b.order_id 
where b.order_status = 'Delivered'
group by format(payment_date ,'yyyy-MM')
order by month 





-- CUSTOMER ANALYSIS 
--     Explore customer ordering behavior to identify patterns such as repeat 
--     ordering, customer segmentation, and trends over time.


-- Which payment method is most frequently used for transactions?
select payment_method,count(payment_method) as cnt from payments
group by payment_method
order by cnt desc


-- customers ordred more than five times ? 
select count(*) as ttl_cnt from (				 
				             select customer_id,count(distinct(order_id)) as trans from order_tbl
                             group by customer_id
                             having count(distinct(order_id)) > 5
							 ) as A 


-- count of cust_id which have payment status as pending ? 
select  count(*) from (
select customer_id from order_tbl as a 
join payments as b 
on a.order_id = b.order_id
where payment_status = 'pending' ) as A



-- PAYMENT STATUS 

--PAYMENT SUCCESS RATE, FAILING RATE AND PENDING RATE 
SELECT 
       count(case when payment_status = 'completed' then 1 end) * 1.0 / count(*) * 100 as success_rate,
       count(case when payment_status = 'failed' then 1 end) * 1.0 / count(*) * 100 as failure_rate,
	   count(case when payment_status = 'pending' then 1 end) * 1.0 / count(*) * 100 as pending_rate
from payments

-- failure rate at payment_method 
select payment_method,
        count(case when payment_status = 'failed' then 1 end) as failed_count,
		count(*) as total_count,
		count(case when payment_status = 'failed' then 1 end) * 1.0 / count(*) * 100 as failure_rate
from payments
group by payment_method


--                                         ORDER REPORT and PAYMENT REPORT  
SELECT 
COUNT(DISTINCT a.order_id) as total_orders,
sum(a.order_amount) as total_revenue,
sum(b.payment_amount) as total_payments,
count(case when b.payment_status = 'completed' then 1 end) as completed_payments, 
count(case when a.order_status = 'delivered' then 1 end) as delivered_orders
from order_tbl as a
join payments as b 
on a.order_id = b.order_id
