--------------
-- PUNTO 22 --
--------------


/*Escriba una consulta sql que retorne una estadistica de venta para TODOS los rubros por
trimestre contabilizando TODOS los años. Se mostraran como maximo 4 filas por rubro (1
por cada trimestre).
Se deben mostrar 4 columnas:
- Detalle del rubro
- Numero de trimestre del año (1 a 4)
- Cantidad de facturas emitidas en el trimestre en las que se haya vendido al
menos un producto del rubro
- Cantidad de productos diferentes del rubro vendidos en el trimestre

El resultado debe ser ordenado alfabeticamente por el detalle del rubro y dentro de cada
rubro primero el trimestre en el que mas facturas se emitieron.

No se deberan mostrar aquellos rubros y trimestres para los cuales las facturas emitiadas
no superen las 100.
En ningun momento se tendran en cuenta los productos compuestos para esta
estadistica.
*/

SELECT rubr_detalle, datepart(quarter, f.fact_fecha), COUNT(*) '# Facturas vendidas', COUNT(distinct p.prod_codigo) '# Prod diferentes'
FROM Producto p
JOIN Item_Factura i1 ON i1.item_producto = p.prod_codigo
JOIN Factura f ON f.fact_tipo+f.fact_sucursal+f.fact_numero = i1.item_tipo+i1.item_sucursal+i1.item_numero
JOIN Rubro ON prod_rubro = rubr_id
GROUP BY rubr_id, rubr_detalle, datepart(quarter, f.fact_fecha)
HAVING COUNT(*) > 100
ORDER BY 1, COUNT(*) desc