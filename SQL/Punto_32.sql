--------------
-- PUNTO 32 --
--------------

/*
Se desea conocer las familias que sus productos se facturaron juntos en las mismas
facturas para ello se solicita que escriba una consulta sql que retorne los pares de
familias que tienen productos que se facturaron juntos. Para ellos debera devolver las
siguientes columnas:
- Codigo de familia
- Detalle de familia
- Codigo de familia
- Detalle de familia
- Cantidad de facturas
- Total vendido
Los datos deberan ser ordenados por Total vendido y solo se deben mostrar las familias
que se vendieron juntas mas de 10 veces.
*/

SELECT f1.fami_id, f1.fami_detalle, f2.fami_id, f2.fami_detalle, 
COUNT(distinct fact_numero) '# Facturas', 
SUM(i1.item_cantidad * i1.item_precio + i2.item_cantidad * i2.item_precio) 'Total vendido'
FROM Factura
JOIN Item_Factura i1 ON i1.item_tipo+i1.item_sucursal+i1.item_numero = fact_tipo+fact_sucursal+fact_numero
JOIN Item_Factura i2 ON i2.item_tipo+i2.item_sucursal+i2.item_numero = fact_tipo+fact_sucursal+fact_numero  
JOIN Producto p1 ON p1.prod_codigo = i1.item_producto
JOIN Producto p2 ON p2.prod_codigo = i2.item_producto
JOIN Familia f1 ON p1.prod_familia = f1.fami_id
JOIN Familia f2 ON p2.prod_familia = f2.fami_id 
WHERE f1.fami_id > f2.fami_id
GROUP BY f1.fami_id, f1.fami_detalle, f2.fami_id, f2.fami_detalle
HAVING COUNT(distinct fact_numero) > 10  
ORDER BY SUM(i1.item_cantidad * i1.item_precio + i2.item_cantidad * i2.item_precio)
