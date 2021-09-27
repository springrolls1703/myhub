WITH raw as 
(SELECT
user_id,
COUNT(DISTINCT title) as item_count
FROM
(SELECT u.id as user_id, u.full_name, o.id, o.number, o.state, o.total_price, o.total_item, o.total_discount, l.unit_price as item_price, v.unit_price as variant_price, l.discount as item_discount, p.title, po.promotion_id as promoid_order, promo.type as promo_type, o.completed_at
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
LEFT JOIN line_items l ON o.id = l.order_id
LEFT JOIN variants v ON l.variant_id = v.id
LEFT JOIN products p ON p.id = v.product_id
LEFT JOIN promotion_orders po ON o.id = po.order_id
LEFT JOIN promotion_variants pv ON v.id = pv.variant_id
LEFT JOIN promotions promo ON promo.id = po.promotion_id
WHERE 
(o.state = 'COMPLETE' OR o.state = 'SELLER_APPROVED')
AND u.role = 'retailer'
) raw_order
GROUP BY 1)

SELECT DISTINCT
CASE 
WHEN item_count > 0 AND item_count < 5 THEN '0-5'
WHEN item_count > 5 AND item_count < 10 THEN '5-10'
WHEN item_count > 10 AND item_count < 15 THEN '10-15'
WHEN item_count > 15 AND item_count < 20 THEN '15-20'
WHEN item_count > 20 AND item_count < 25 THEN '20-25'
WHEN item_count > 25 AND item_count < 50 THEN '25-50'
ELSE '>50'
END AS count_group,
COUNT(user_id)
FROM raw
GROUP BY 1