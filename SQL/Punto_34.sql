--------------
-- PUNTO 34 --
--------------

/*
Escriba una consulta sql que retorne para todos los rubros la cantidad de facturas mal
facturadas por cada mes del año 2011. Se considera que una factura es incorrecta cuando
en la misma factura se factutan productos de dos rubros diferentes. Si no hay facturas
mal hechas se debe retornar 0. Las columnas que se deben mostrar son:
1- Codigo de Rubro
2- Mes
3- Cantidad de facturas mal realizadas.
*/

SELECT rubr_id, month(fact_fecha), ISNULL(COUNT(distinct fact_numero),0)
FROM Producto
JOIN Item_Factura ON prod_codigo = item_producto
JOIN Factura ON item_numero+item_tipo+item_sucursal = fact_numero+fact_tipo+fact_sucursal
JOIN Rubro ON prod_rubro = rubr_id
WHERE year(fact_fecha) = 2011 AND fact_numero IN (SELECT fact_numero
												  FROM Factura
												  JOIN Item_Factura i1 ON i1.item_numero+i1.item_tipo+i1.item_sucursal = fact_numero+fact_tipo+fact_sucursal
												  JOIN Item_Factura i2 ON i2.item_numero+i2.item_tipo+i2.item_sucursal = fact_numero+fact_tipo+fact_sucursal
												  JOIN Producto p1 ON p1.prod_codigo = i1.item_producto
												  JOIN Producto p2 ON p2.prod_codigo = i2.item_producto
												  WHERE p1.prod_rubro <> p2.prod_rubro
												  GROUP BY fact_numero)
GROUP BY rubr_id, month(fact_fecha)
ORDER BY 1,2



