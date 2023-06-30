--подсчет количества клиентов с покупками
select count(distinct customer_id) as customers_count
from sales s 

--топ-10 продавцов
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

--продавцы со средней сделкой ниже общей средней суммы сделки
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

--выручка продавцов по дням недели
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

