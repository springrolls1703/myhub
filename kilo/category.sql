select 
	to_char(o.created_at, 'YYYY-MM') as orderscreated_date,
	c.name,
	sum((li.unit_price * li.quantity*0.000044)-(li.discount*0.000044)) as usd_gmv_post_discount,
	sum(li.unit_price * li.quantity*0.000044) as usd_gmv_pre_discount	
from orders o
Left join line_items li
	on o.id = li.order_id 
	and li.order_id is not null
left join products p
	on p.id = li.variant_id
left join categories c
	on c.id = p.category_id
where o.state in ('COMPLETE','SELLER_APPROVED')
group by 1,2 order by 1 desc