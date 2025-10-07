--------------
-- PUNTO 21 --
--------------

/*
Escriba una consulta sql que retorne para todos los años, en los cuales se haya hecho al
menos una factura, la cantidad de clientes a los que se les facturo de manera incorrecta
al menos una factura y que cantidad de facturas se realizaron de manera incorrecta. Se
considera que una factura es incorrecta cuando la diferencia entre el total de la factura
menos el total de impuesto tiene una diferencia mayor a $ 1 respecto a la sumatoria de
los costos de cada uno de los items de dicha factura.
*/


SELECT year(fact_fecha), COUNT(*) '# Facturas incorrectas', COUNT(distinct fact_cliente) '# Clientes afectados'
FROM Factura 
WHERE ABS(ABS(fact_total - fact_total_impuestos) - (SELECT SUM(item_cantidad * item_precio) FROM Item_Factura WHERE item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero GROUP BY item_tipo+item_sucursal+item_numero)) > 1
GROUP BY year(fact_fecha)


