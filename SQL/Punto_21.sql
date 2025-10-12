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


SELECT year(f1.fact_fecha), (SELECT COUNT(*) 
						FROM Factura f2
						WHERE year(f2.fact_fecha) = year(f1.fact_fecha)
						AND ((f2.fact_total - f2.fact_total_impuestos) - (SELECT SUM(item_cantidad * item_precio)
																			FROM Item_Factura
																			WHERE item_tipo = f2.fact_tipo AND item_sucursal = f2.fact_sucursal AND item_numero = f2.fact_numero
																			) > 1) 
						) '# Facturas incorrectas',
						(SELECT COUNT(distinct f2.fact_cliente) 
						FROM Factura f2
						WHERE year(f2.fact_fecha) = year(f1.fact_fecha)
						AND ((f2.fact_total - f2.fact_total_impuestos) - (SELECT SUM(item_cantidad * item_precio)
																			FROM Item_Factura
																			WHERE item_tipo = f2.fact_tipo AND item_sucursal = f2.fact_sucursal AND item_numero = f2.fact_numero
																			) > 1)) 

FROM Factura f1
GROUP BY year(f1.fact_fecha)

