--------------
-- PUNTO 23 --
--------------

/*
Realizar una consulta SQL que para cada año muestre :
 Año
 El producto con composición más vendido para ese año.
 Cantidad de productos que componen directamente al producto más vendido
 La cantidad de facturas en las cuales aparece ese producto.
 El código de cliente que más compro ese producto.
 El porcentaje que representa la venta de ese producto respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año en forma descendente.
*/

--En las subqueries para sacar el TOP 1, no pongo la comparacion de fact_fecha porque el enunciado es confuso. 
--No se sabe si se quiere para ese anio o en general

SELECT year(f.fact_fecha), (SELECT TOP 1 comp_producto
							FROM Composicion
							JOIN Item_Factura i1 ON i1.item_producto = comp_producto
							JOIN Factura f1 ON i1.item_tipo+i1.item_sucursal+i1.item_numero = f1.fact_tipo+f1.fact_sucursal+f1.fact_numero AND year(f1.fact_fecha) = year(f.fact_fecha)
							GROUP BY comp_producto
							ORDER BY SUM(i1.item_cantidad) desc),
							
							(SELECT COUNT(*) FROM Composicion
							WHERE comp_producto = (SELECT TOP 1 comp_producto
													FROM Composicion
													JOIN Item_Factura i1 ON i1.item_producto = comp_producto
													GROUP BY comp_producto
													ORDER BY SUM(i1.item_cantidad) desc)),
							
							(SELECT COUNT(distinct fact_tipo+fact_sucursal+fact_numero)
							FROM Item_Factura  
							JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero AND year(fact_fecha) = year(f.fact_fecha)
							WHERE item_producto = (SELECT TOP 1 comp_producto
													FROM Composicion
													JOIN Item_Factura i1 ON i1.item_producto = comp_producto
													GROUP BY comp_producto
													ORDER BY SUM(i1.item_cantidad) desc)),

							(SELECT TOP 1 fact_cliente
							FROM Factura  
							JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero 
							WHERE item_producto = (SELECT TOP 1 comp_producto
													FROM Composicion
													JOIN Item_Factura i1 ON i1.item_producto = comp_producto
													GROUP BY comp_producto
													ORDER BY SUM(i1.item_cantidad) desc) AND year(fact_fecha) = year(f.fact_fecha)
							GROUP BY fact_cliente
							ORDER BY SUM(item_cantidad)),

							(SELECT SUM(item_cantidad *item_precio)
							FROM Item_Factura  
							JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero AND year(fact_fecha) = year(f.fact_fecha)
							WHERE item_producto = (SELECT TOP 1 comp_producto
													FROM Composicion
													JOIN Item_Factura i1 ON i1.item_producto = comp_producto
													GROUP BY comp_producto
													ORDER BY SUM(i1.item_cantidad) desc)
							) * 100 / SUM(f.fact_total)

FROM Factura f
GROUP BY year(f.fact_fecha)
GO

-- Version mas simple

SELECT 
	YEAR(f1.fact_fecha), 
	item_producto, 
	COUNT(distinct comp_componente), 
	COUNT(distinct f1.fact_tipo+f1.fact_sucursal+f1.fact_numero), 
	(SELECT TOP 1 f2.fact_cliente
	FROM Factura f2
	JOIN Item_Factura i2 ON i2.item_tipo+i2.item_sucursal+i2.item_numero = f2.fact_tipo+f2.fact_sucursal+f2.fact_numero
	WHERE i2.item_producto = i.item_producto AND YEAR(f1.fact_fecha) = YEAR(fact_fecha) -- Tiene que ser el cliente de ese año
	GROUP BY f2.fact_cliente
	ORDER BY SUM(i2.item_cantidad)), --Me aseguro de traer solo los renglones que aparece el mas vendido

SUM(i.item_cantidad * i.item_precio) * 100 / (SELECT SUM(f3.fact_total) FROM Factura f3 WHERE year(f3.fact_fecha) = year(f1.fact_fecha)) 

FROM Factura f1
JOIN Item_Factura i ON i.item_tipo+i.item_sucursal+i.item_numero = f1.fact_tipo+f1.fact_sucursal+f1.fact_numero
JOIN Composicion ON item_producto = comp_producto
GROUP BY year(f1.fact_fecha), item_producto
HAVING item_producto IN (SELECT TOP 1 comp_producto
							FROM Composicion
							JOIN Item_Factura i2 ON i2.item_producto = comp_producto
							JOIN Factura f2 ON i2.item_tipo+i2.item_sucursal+i2.item_numero = f2.fact_tipo+f2.fact_sucursal+f2.fact_numero 
							WHERE year(f1.fact_fecha) = year(f2.fact_fecha)
							GROUP BY comp_producto
							ORDER BY SUM(i2.item_cantidad) desc)

-- Por cada año que va recorriendo, me devuelve el TOP 1 ==> Lo que hago poniendolo en el HAVING es trabajar directamente con el TOP 1 en ventas
-- Entonces no tengo que hacer una subquery para cada elemento sino que ya tengo las facturas del mismo, los componentes, el producto
