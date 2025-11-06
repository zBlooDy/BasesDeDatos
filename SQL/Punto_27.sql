--------------
-- PUNTO 27 --
--------------

/*
Escriba una consulta sql que retorne una estadística basada en la facturacion por año y
envase devolviendo las siguientes columnas:

- Año
- Codigo de envase
- Detalle del envase
- Cantidad de productos que tienen ese envase
- Cantidad de productos facturados de ese envase
- Producto mas vendido de ese envase
- Monto total de venta de ese envase en ese año
- Porcentaje de la venta de ese envase respecto al total vendido de ese año

Los datos deberan ser ordenados por año y dentro del año por el envase con más
facturación de mayor a menor
*/


SELECT year(f.fact_fecha),
enva_codigo, 
enva_detalle,
(SELECT COUNT(*) FROM Producto WHERE prod_envase = enva_codigo) '# Productos envase',
COUNT(distinct prod_codigo) '# Productos facturados',
(SELECT TOP 1 prod_codigo 
FROM Producto 
JOIN Item_Factura ON item_producto = prod_codigo
JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE prod_envase = enva_codigo AND year(fact_fecha) = year(f.fact_fecha)
GROUP BY prod_codigo
ORDER BY SUM(item_cantidad) desc
) 'Prod. mas vendido',
SUM(item_cantidad * item_precio) '# Total facturado',
SUM(item_cantidad * item_precio) * 100 / (SELECT SUM(fact_total) FROM Factura WHERE year(fact_fecha) = year(f.fact_fecha)) '% Del año'

FROM Factura f
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
JOIN Producto ON prod_codigo = item_producto
JOIN Envases ON prod_envase = enva_codigo
GROUP BY year(f.fact_fecha), enva_codigo, enva_detalle
ORDER BY year(f.fact_fecha), SUM(item_cantidad * item_precio) desc





/*
WHERE prod_envase = (SELECT TOP 1 prod_envase
                    FROM Producto 
                    JOIN Item_Factura ON prod_codigo = item_producto
                    JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
                    WHERE year(fact_fecha) = year(f.fact_fecha) 
                    GROUP BY prod_envase
                    ORDER BY SUM(item_cantidad * item_precio) desc)
*/
