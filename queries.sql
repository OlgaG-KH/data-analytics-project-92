--количество покупателей с покупками
select count(distinct customer_id) as customers_count
from sales s 

--топ-10 продавцов по выручке
select 
	concat(e.first_name, ' ', e.last_name) as name,
	count(s.sales_id) as operations,
	sum(s.quantity * p.price) as income
from sales s 
left join employees e on s.sales_person_id = e.employee_id 
left join products p on s.product_id = p.product_id
group by
	concat(e.first_name, ' ', e.last_name)
order by income desc 
limit 10

--продавцы со средней выручкой от сделки меньше общей средней выручки от сделки
select
	concat(e.first_name, ' ', e.last_name) as name,
	round(avg(s.quantity * p.price), 0) as average_income
from sales s 
left join employees e on s.sales_person_id = e.employee_id 
left join products p on s.product_id = p.product_id
group by
	concat(e.first_name, ' ', e.last_name)
having round(avg(s.quantity * p.price), 0) < (select 
	avg(s.quantity * p.price)
from sales s 
left join products p on s.product_id = p.product_id)
order by average_income asc 

--выручка по продавцам и дням недели
select 
	concat(e.first_name, ' ', e.last_name) as name,
	to_char(s.sale_date, 'day') as weekday,
	round(sum(s.quantity * p.price), 0) as income
from sales s 
left join employees e on s.sales_person_id = e.employee_id 
left join products p on s.product_id = p.product_id
group by
	concat(e.first_name, ' ', e.last_name),
	to_char(s.sale_date, 'day'),
	extract (isodow from s.sale_date)
order by
	extract (isodow from s.sale_date),
	concat(e.first_name, ' ', e.last_name)

--распределение покупателей по возрастным группам
select
case
	when c.age between 16 and 25 then '16-25'
	when c.age between 26 and 40 then '26-40'
	else '40+'
end as age_category,
count(distinct s.customer_id)
from sales s 
left join customers c on s.customer_id = c.customer_id  
group by age_category
order by age_category

--выручка и количество покупателей по месяцам
select 
	concat(to_char(s.sale_date, 'YYYY'), '-', to_char(s.sale_date, 'MM')) as date,
	count(distinct s.customer_id) as total_customers,
	sum(s.quantity * p.price) as income 
from sales s 
left join customers c on s.customer_id = c.customer_id 
left join products p on s.product_id = p.product_id 
group by date
order by date

--покупатели с акционным товаром в первой покупке
with tab as (
select 
	concat(c.first_name, ' ', c.last_name) as customer,
	c.customer_id,
	first_value (p.price) over (partition by s.customer_id order by s.sale_date) as first_price,
	first_value (s.sale_date) over (partition by s.customer_id order by s.sale_date) as sale_date,
	first_value (concat(e.first_name, ' ', e.last_name)) over (partition by s.customer_id order by s.sale_date) as seller
from customers c 
left join sales s on c.customer_id = s.customer_id 
left join products p on s.product_id = p.product_id 
left join employees e ON s.sales_person_id = e.employee_id 
group by
	c.customer_id,
	s.customer_id,
	p.price,
	s.sale_date,
	e.employee_id 
)
select
	customer,
	sale_date,
	seller
from tab
where first_price = 0
group by
	customer,
	customer_id,
	sale_date,
	seller
order by customer_id 