-------------
-- PUNTO 2 --
-------------

/*Mostrar el código, detalle 
de todos los !! artículos vendidos !! en el año 2012 
ordenados por cantidad vendida.*/

SELECT prod_codigo, prod_detalle, SUM(item_cantidad)
FROM Producto
JOIN Item_Factura ON prod_codigo = item_producto   -- Traigo de mas, entonces agrupo
JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE year(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad)


