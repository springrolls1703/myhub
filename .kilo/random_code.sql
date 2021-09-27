SELECT u.phone, s.short_name, d.created_at as "Code Created At",o.number, o.created_at as order_date,dc.code, dc.dsr_name
FROM dsr_codes d
         INNER JOIN user_dsr_codes udc ON d.id = udc.dsr_code_id
         INNER JOIN dsr_codes dc ON udc.dsr_code_id = dc.id
         INNER JOIN users u ON u.id = udc.user_id
         INNER JOIN sellers s ON d.seller_id = s.id
         LEFT JOIN orders o ON o.user_id = u.id
WHERE 
lower(s.short_name) LIKE '%phuc cong%'
-- u.phone = '0793468388'
-- AND o.state = 'SELLER_APPROVED' OR o.state = 'COMPLETE'
-- AND u.full_name LIKE '%vinh%'
-- AND (dc.seller_id = o.seller_id OR dc.seller_id IS NULL)
ORDER BY order_date DESC;

-- ****this is for DSR code****
-- SELECT o.number, u.full_name, u.phone, s.short_name, dc.code, dc.dsr_name, dc.created_at, o.created_at as order_date
-- FROM orders o
--          INNER JOIN users u ON o.user_id = u.id
--          INNER JOIN user_dsr_codes udc ON u.id = udc.user_id
--          INNER JOIN dsr_codes dc ON udc.dsr_code_id = dc.id
--          INNER JOIN sellers s ON o.seller_id = s.id
-- WHERE u.phone = '0708291029'
--   AND (dc.seller_id = o.seller_id OR dc.seller_id IS NULL)
-- ORDER BY dc.seller_id DESC


-- ****OTP SEARCH****
-- SELECT u.phone, u.full_name, o.code, o.created_at, o.esms_requested_at, o.esms_callback_response
-- FROM users u
--          INNER JOIN otps o ON u.id = o.user_id
-- WHERE phone = '0934741805'
-- ORDER BY o.id DESC
-- -- LIMIT 1;

--- ****OTP time****
-- SELECT u.phone
--      , u.full_name
--      , o.code
--      , o.created_at
--      , o.esms_requested_at
--      , o.esms_callback_response
--      , abs(extract(epoch from o.esms_requested_at - o.created_at))
-- FROM users u
--          INNER JOIN otps o ON u.id = o.user_id
-- ORDER BY o.id DESC

-- ****ORDER ITEM LEVEL****
-- SELECT o.completed_at as date, u.id, u.full_name, o.id, o.number, o.state, o.total_price, o.total_item, o.total_discount, l.unit_price as item_price, v.unit_price as variant_price, l.discount as item_discount, p.title, po.promotion_id as promoid_order, promo.type as promo_type, o.completed_at
-- FROM orders o
-- LEFT JOIN users u ON o.user_id = u.id
-- LEFT JOIN line_items l ON o.id = l.order_id
-- LEFT JOIN variants v ON l.variant_id = v.id
-- LEFT JOIN products p ON p.id = v.product_id
-- LEFT JOIN promotion_orders po ON o.id = po.order_id
-- LEFT JOIN promotion_variants pv ON v.id = pv.variant_id
-- LEFT JOIN promotions promo ON promo.id = po.promotion_id
-- WHERE 
-- -- (o.state = 'COMPLETE' OR o.state = 'SELLER_APPROVED')
-- -- AND 
-- -- promo.type = 'volume_based'
-- u.phon
-- ORDER BY o.completed_at DESC


-- ****THIS IS FOR RETAILER ORDER COUNT****
-- SELECT u.phone, u.full_name, s.short_name as seller_name, dc.code, COUNT(o.number) as order_count
-- FROM orders o
--          INNER JOIN users u ON o.user_id = u.id
--          INNER JOIN user_dsr_codes udc ON u.id = udc.user_id
--          INNER JOIN dsr_codes dc ON udc.dsr_code_id = dc.id
--          INNER JOIN sellers s ON o.seller_id = s.id
-- WHERE (dc.seller_id = o.seller_id OR dc.seller_id IS NULL)
-- AND u.role = 'retailer'
-- AND u.phone = '0904270346'
-- GROUP BY 1,2,3,4
-- ORDER BY 5 DESC




