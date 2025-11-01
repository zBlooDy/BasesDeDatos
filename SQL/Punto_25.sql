--------------
-- PUNTO 25 --
--------------

/*
25. Realizar una consulta SQL que para cada año y familia muestre :
a. Año
b. El código de la familia más vendida en ese año.
c. Cantidad de Rubros que componen esa familia.
d. Cantidad de productos que componen directamente al producto más vendido de
esa familia.
e. La cantidad de facturas en las cuales aparecen productos pertenecientes a esa
familia.
f. El código de cliente que más compro productos de esa familia.
g. El porcentaje que representa la venta de esa familia respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año y familia en forma
descendente.
*/


SELECT year(f.fact_fecha), 
p.prod_familia,
-- Hago un subselect solo traigo los productos que tienen facturas en la consulta general
(SELECT COUNT(distinct prod_rubro)
FROM Producto
WHERE prod_familia = p.prod_familia),

(SELECT COUNT(*)
FROM Composicion
WHERE comp_producto IN (SELECT TOP 1 item_producto
						FROM Item_Factura
						JOIN Producto ON item_producto = prod_codigo
						WHERE prod_familia = p.prod_familia AND year(fact_fecha) = year(f.fact_fecha)
						GROUP BY item_producto
						ORDER BY SUM(item_cantidad))
),

COUNT(distinct fact_numero),

(SELECT TOP 1 fact_cliente
FROM Factura 
JOIN Item_Factura ON item_numero+item_tipo+item_sucursal = fact_numero+fact_tipo+fact_sucursal
JOIN Producto ON prod_codigo = item_producto
WHERE prod_familia = p.prod_familia AND year(fact_fecha) = year(f.fact_fecha)
GROUP BY fact_cliente
ORDER BY SUM(item_cantidad) desc),

SUM(item_cantidad * item_precio) / (SELECT SUM(fact_total) FROM Factura WHERE year(fact_fecha) = year(f.fact_fecha)) * 100

FROM Factura f
JOIN Item_Factura ON item_numero+item_tipo+item_sucursal = f.fact_numero+f.fact_tipo+f.fact_sucursal
JOIN Producto p ON p.prod_codigo = item_producto
WHERE prod_familia = (SELECT TOP 1 prod_familia
						FROM Producto
						JOIN Item_Factura ON prod_codigo = item_producto
						JOIN Factura ON item_numero+item_tipo+item_sucursal = fact_numero+fact_tipo+fact_sucursal
						WHERE year(fact_fecha) = year(f.fact_fecha)
						GROUP BY prod_familia
						ORDER BY COUNT(fact_numero) DESC)
GROUP BY year(f.fact_fecha), p.prod_familia
ORDER BY SUM(fact_total), prod_familia




