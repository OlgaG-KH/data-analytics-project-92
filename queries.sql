--подсчет количества клиентов с покупками
select count(distinct customer_id) as customers_count
from sales s 