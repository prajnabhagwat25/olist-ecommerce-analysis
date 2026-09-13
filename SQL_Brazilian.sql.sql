create database olist_db ;
use olist_db; 

select order_status,count(*) as total_order 
from olist_orders_dataset 
group by order_status 
order by total_order desc;

select round(sum(price + freight_value),2) as total_revenue 
from olist_order_items_dataset oi 
join olist_orders_dataset o on oi.order_id = o.order_id 
where o.order_status = 'delivered';

select YEAR(order_purchase_timestamp) AS order_year,MONTH(order_purchase_timestamp)AS order_month, count(*) as total_orders
from olist_orders_dataset 
where order_status = 'delivered' 
group by order_year,order_month 
order by order_year,order_month desc;

select t.product_category_name_english as category,count(oi.order_item_id)as items_sold 
from olist_order_items_dataset oi
join olist_products_dataset p on oi.product_id = p.product_id 
join product_category_name_translation t on p.product_category_name = t.product_category_name_english
group by category 
order by count(oi.order_item_id) desc limit 10;

select customer_state,count(distinct customer_unique_id)as unique_customer 
from olist_customers_dataset 
group by customer_state
order by unique_customer desc;

select payment_type, count(*) as total_transactions, round(sum(payment_value),2)as total_value 
from olist_order_payments_dataset 
group by payment_type 
order by total_transactions desc;

select seller_id,count(distinct order_id) as total_orders,round(sum(price),2)as total_revenue
from olist_order_items_dataset 
group by seller_id 
order by total_orders desc limit 10;

select round(avg(datediff( order_delivered_customer_date,order_purchase_timestamp)),2) as avg_delivery_days 
from olist_orders_dataset  
where order_status = 'delivered' and order_delivered_customer_date is not null;

select o.order_id ,r.review_score, datediff(o.order_delivered_customer_date,o.order_purchase_timestamp) as delivered_days
from olist_orders_dataset o 
join olist_order_reviews_dataset r on o.order_id = r.order_id 
where r.review_score = 1 and order_delivered_customer_date is not null 
order by delivered_days desc limit 20;

select case when datediff(o.order_delivered_customer_date,o.order_purchase_timestamp) <= 7 then 'Fast (1-7 days)' 
			when datediff(o.order_delivered_customer_date,o.order_purchase_timestamp) <= 14 then 'Normal (8-14 days)'
            when datediff(o.order_delivered_customer_date,o.order_purchase_timestamp) <= 30 then 'Slow (15-30 days)'
            else 'Very_Low (30+ days)'end as delivery_bucket, count(*) as total_order ,
round(count(*)/sum(count(*))over()*100,2) as pct_of_orders 
from olist_orders_dataset o 
where o.order_status = 'delivered' and o.order_delivered_customer_date is not null 
group by delivery_bucket 
order by min(datediff(o.order_delivered_customer_date,o.order_purchase_timestamp));

select c.customer_state,count(distinct o.order_id) as total_orders,round(sum(oi.price+oi.freight_value),2) as total_revenue,
round(avg(oi.price+oi.freight_value),2)as avg_order_value 
from olist_customers_dataset c 
join olist_orders_dataset o on c.customer_id = o.customer_id 
join olist_order_items_dataset oi on o.order_id = oi.order_id 
where o.order_status = 'delivered'
group by c.customer_state 
order by total_revenue limit 10;

select count(*)as total_order,round(avg(r.review_score),0)as avg_review,
case when datediff(o.order_delivered_customer_date,o.order_purchase_timestamp) <= 7 then 'Fast (1-7d)' 
     when datediff(o.order_delivered_customer_date,o.order_purchase_timestamp) <= 14 then 'Normal (8-14d)'
     when datediff(o.order_delivered_customer_date,o.order_purchase_timestamp) <= 30 then 'Slow (15-30d)'
     else 'Very Slow (30d+)'end as delivery_bucket
from olist_orders_dataset o 
join olist_order_reviews_dataset r on o.order_id = r.order_id 
where o.order_status = 'delivered' and o.order_delivered_customer_date is not null 
group by delivery_bucket 
order by avg_review desc;

with customer_orders as
(select c.customer_unique_id,count(distinct o.order_id)as order_count 
from olist_customers_dataset c
join olist_orders_dataset o on c.customer_id = o.customer_id 
where o.order_status = 'delivered' 
group by c.customer_unique_id)
select sum(case when order_count = 1 then 1 else 0 end)as one_time_customers,
       sum(case when order_count > 1 then 1 else 0 end)as repeat_customers,
round(sum(case when order_count > 1 then 1 else 0 end)*100.0/count(*),2)as repeat_rate_pct 
from customer_orders;

select t.product_category_name_english,count(distinct oi.order_id)as total_orders,round(sum(oi.price),2)as total_revenue,
round(avg(r.review_score),2)as avg_review 
from olist_order_items_dataset oi 
join olist_orders_dataset o on oi.order_id = o.order_id 
join olist_products_dataset p on oi.product_id = p.product_id
join product_category_name_translation t on p.product_category_name = t.product_category_name_english 
left join olist_order_reviews_dataset r on o.order_id = r.order_id 
where o.order_status = 'delivered' 
group by t.product_category_name_english 
order by total_revenue desc limit 10;

With seller_revenue as
(select seller_id,round(sum(price),2)as total_revenue,count(distinct order_id)as total_orders 
from olist_order_items_dataset 
group by seller_id )
select 
case when total_revenue >=100000 then 'Platinum' 
     when total_revenue >=50000 then 'Gold' 
	 when total_revenue >=10000 then 'Silver'
     else 'Bronze' end as seller_tier,count(*)as seller_count,round(sum(total_revenue),2)as tier_revenue 
from seller_revenue
group by seller_tier 
order by tier_revenue desc;

select year(o.order_purchase_timestamp)as year,month(o.order_purchase_timestamp)as month,count(distinct o.order_id) as total_orders,
round(sum(oi.price+oi.freight_value),2)as monthly_revenue 
from olist_orders_dataset o 
join olist_order_items_dataset oi on
o.order_id = oi.order_id 
where o.order_status = 'delivered' and year(o.order_purchase_timestamp)in(2017,2018)
group by year,month order by year,month;

with delivery_status as
(select o.order_id,r.review_score,case when o.order_delivered_customer_date <= o.order_estimated_delivery_date 
then 'On time' else 'Late' end as delivery_result 
from olist_orders_dataset o join olist_order_reviews_dataset r on o.order_id = r.order_id 
where o.order_status ='delivered' and o.order_delivered_customer_date is not null and o.order_estimated_delivery_date is not null)
select delivery_result,count(*)as total_orders,round(avg(review_score),2)as avg_review_score 
from delivery_status group by delivery_result; 

with seller_state_rev as
(select s.seller_id,s.seller_state,round(sum(oi.price),2) as revenue,
rank()over(partition by s.seller_state order by sum(oi.price) desc) as state_rnk
from olist_sellers_dataset s 
join olist_order_items_dataset oi on s.seller_id = oi.seller_id 
group by s.seller_id,s.seller_state)
select * 
from seller_state_rev 
where state_rnk <= 3;

with product_sales as
(select t.product_category_name_english as category,oi.product_id,count(*) as unit_sold
from olist_order_items_dataset oi 
join olist_products_dataset p on oi.product_id = p.product_id 
join product_category_name_translation t on p.product_category_name = t.product_category_name_english 
group by t.product_category_name_english,oi.product_id),
ranked as(select * , row_number()over(partition by category order by unit_sold desc)as rnk from product_sales)
select category,product_id,unit_sold,rnk from ranked where rnk <=3 order by category,rnk;

with monthly_rev as
(select date_format(o.order_purchase_timestamp, '%y-%m') as yr_mo,round(sum(oi.price + oi.freight_value),2) as total_revenue
from olist_orders_dataset o 
join olist_order_items_dataset oi on o.order_id = oi.order_id 
where o.order_status = 'delivered'
group by yr_mo)
select *,round(sum(total_revenue)over(order by yr_mo),2)as cumulative_revenue 
from monthly_rev 
order by yr_mo;

with monthly_rev as
(select date_format(o.order_purchase_timestamp, '%y-%m') as yr_mo,round(sum(oi.price + freight_value),2)as total_revenue
from olist_order_items_dataset oi 
join olist_orders_dataset o on oi.order_id = o.order_id 
where o.order_status = 'delivered'
group by yr_mo)
select yr_mo,total_revenue,lag(total_revenue)over(order by yr_mo)as previous_month_rev,round((total_revenue - lag(total_revenue)over(order by yr_mo))
/lag(total_revenue)over(order by yr_mo)*100,2)as profit_growth 
from monthly_rev 
order by yr_mo;

with customer_orders as
(select c.customer_unique_id,o.order_id,o.order_purchase_timestamp,
row_number()over(partition by c.customer_unique_id order by o.order_purchase_timestamp)as order_sequence,
lag(o.order_purchase_timestamp)over(partition by c.customer_unique_id order by o.order_purchase_timestamp) as prev_order_date 
from olist_customers_dataset c join olist_orders_dataset o on c.customer_id = o.customer_id where o.order_status = 'delivered')
select *,datediff(order_purchase_timestamp,prev_order_date) as days_between_orders 
from customer_orders 
order by customer_unique_id,order_sequence;

select p.product_id,t.product_category_name_english,oi.price,round(avg(oi.price)over(partition by t.product_category_name_english),2) as
category_avg_price,round(oi.price - avg(oi.price)over(partition by t.product_category_name_english),2) as price_diff_from_avg
from olist_order_items_dataset oi join olist_products_dataset p on oi.product_id = p.product_id 
join product_category_name_translation t on p.product_category_name = t.product_category_name_english 
order by price_diff_from_avg desc limit 20 ;

with seller_summary as( select s.seller_id ,s.seller_state,round(count(distinct oi.order_id),2) as order_count,
round(sum(oi.price),2)as total_revenue 
from olist_order_items_dataset oi 
join olist_sellers_dataset s on oi.seller_id = s.seller_id
group by s.seller_id,s.seller_state)
select *,rank()over(order by total_revenue) as rnk 
from seller_summary 
order by total_revenue desc limit 5;

SELECT
  oi.order_id,
  oi.order_item_id,
  oi.product_id,
  oi.seller_id,
  o.customer_id,
  oi.price,
  oi.freight_value,
  o.order_status,
  o.order_purchase_timestamp,
  o.order_delivered_customer_date,
  o.order_estimated_delivery_date,
  DATEDIFF(o.order_delivered_customer_date,
            o.order_purchase_timestamp) AS delivered_days,
  CASE WHEN o.order_delivered_customer_date
       <= o.order_estimated_delivery_date
    THEN 'On Time' ELSE 'Late'
  END AS delivered_status,
  r.review_score
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o ON oi.order_id = o.order_id
LEFT JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered';

select distinct customer_id,customer_unique_id,customer_city,customer_state 
from olist_customers_dataset ;

select p.product_id,t.product_category_name_english as category,p.product_weight_g 
from olist_products_dataset p 
left join 
product_category_name_translation t on p.product_category_name = t.product_category_name_english ;

select distinct seller_id,seller_city,seller_state 
from olist_sellers_dataset;



