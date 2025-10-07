--------------
-- PUNTO 18 --
--------------

/*
Escriba una consulta que retorne una estadística de ventas para todos los rubros.
La consulta debe retornar:

DETALLE_RUBRO: Detalle del rubro
VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
PROD1: Código del producto más vendido de dicho rubro
PROD2: Código del segundo producto más vendido de dicho rubro
CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30
días
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
por cantidad de productos diferentes vendidos del rubro.
*/

SELECT rubr_detalle, SUM(item_cantidad * item_precio),
		(SELECT TOP 1 i1.item_producto
		FROM Item_Factura i1
		JOIN Producto p ON i1.item_producto = p.prod_codigo and p.prod_rubro = rubr_id
		group by i1.item_producto
		ORDER BY SUM(i1.item_cantidad) desc),

		(SELECT TOP 1 item_producto
		FROM Item_Factura
		JOIN Producto p ON item_producto = p.prod_codigo and p.prod_rubro = rubr_id
		where item_producto in (SELECT TOP 2 i1.item_producto
		                        FROM Item_Factura i1
		                        JOIN Producto p ON i1.item_producto = p.prod_codigo and p.prod_rubro = rubr_id
		                        group by i1.item_producto
		                        ORDER BY SUM(i1.item_cantidad) desc)
		                        
        group by item_producto
		ORDER BY SUM(item_cantidad) asc)
,
							(SELECT TOP 1 fact_cliente
							FROM Item_Factura i2
							JOIN Factura ON i2.item_numero+i2.item_tipo+i2.item_sucursal = fact_numero+fact_tipo+fact_sucursal and fact_fecha >= (select max(fact_fecha)-30 from Factura)
							JOIN Producto p2 ON (p2.prod_rubro = rubr_id and i2.item_producto = p2.prod_codigo)
							group by fact_cliente
							order by SUM(item_cantidad) desc
							)  

FROM Rubro
JOIN Producto ON prod_rubro = rubr_id
LEFT JOIN Item_Factura ON item_producto = prod_codigo
group by rubr_id, rubr_detalle
order by count(distinct prod_codigo ) 


