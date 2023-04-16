
--1 Cuáles son los clientes que viven en las ciudades donde se compran el TOP 5% de las órdenes más costosas?
WITH top_orders AS (
    SELECT placed_order_id, SUM(price * quantity) AS order_total
    FROM order_item
    GROUP BY placed_order_id
    ORDER BY order_total DESC
    LIMIT (SELECT COUNT(*) * 0.05 FROM placed_order)
), top_cities AS (
    SELECT delivery_city_id, COUNT(*) AS city_orders
    FROM placed_order
    WHERE id IN (SELECT placed_order_id FROM top_orders)
    GROUP BY delivery_city_id
    ORDER BY city_orders DESC
    LIMIT 5
)
SELECT c.first_name, c.last_name, ct.city_name
FROM customer c
JOIN top_cities tc ON c.city_id = tc.delivery_city_id
JOIN city ct ON c.city_id = ct.id;


--Cuales son los 10 mejores clientes (en monto total de compras)
SELECT c.*, SUM(oi.quantity * oi.price) as precio_total
FROM customer as c
JOIN placed_order as po on c.id = po.customer_id
JOIN order_item as oi on oi.placed_order_id = po.id
GROUP BY c.id
ORDER BY precio_total DESC
LIMIT 10;


--Cuáles son las 5 ciudades donde las órdenes tardan en promedio más tiempo en ser despachadas/// Tengo mis dudas no se si es placed_order o la del delivery puse esta por
SELECT c.city_name, AVG(EXTRACT(epoch FROM (d.delivery_time_actual - po.time_placed))) / 3600 AS promedio_delivery
FROM city c
JOIN placed_order po ON po.delivery_city_id = c.id
JOIN delivery d ON d.placed_order_id = po.id
WHERE d.delivery_time_actual IS NOT NULL
GROUP BY c.id
ORDER BY promedio_delivery DESC
LIMIT 5;


--¿Cuál es el ítem que causa más retrasos en el despacho de órdenes?
SELECT i.item_name, SUM(EXTRACT(EPOCH FROM (d.delivery_time_actual - p.time_placed))) AS total_delivery_time
FROM item i
JOIN order_item oi ON oi.item_id = i.id
JOIN placed_order p ON p.id = oi.placed_order_id
JOIN delivery d ON d.placed_order_id = p.id
WHERE d.delivery_time_actual IS NOT NULL
GROUP BY i.item_name
ORDER BY total_delivery_time DESC
LIMIT 10;
