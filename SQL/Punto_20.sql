--------------
-- PUNTO 20 --
--------------

/*
Escriba una consulta sql que retorne un ranking de los mejores 3 empleados del 2012
Se debera retornar legajo, nombre y apellido, anio de ingreso, puntaje 2011, puntaje
2012. 

El puntaje de cada empleado se calculara de la siguiente manera: para los que
hayan vendido al menos 50 facturas el puntaje se calculara como la cantidad de facturas
que superen los 100 pesos que haya vendido en el año, para los que tengan menos de 50
facturas en el año el calculo del puntaje sera el 50% de cantidad de facturas realizadas
por sus subordinados directos en dicho año.
*/


SELECT e.empl_codigo, e.empl_nombre, e.empl_apellido, year(e.empl_ingreso),
(SELECT 
CASE WHEN COUNT(*) >= 50 
THEN (SELECT COUNT(*) from Factura f2 where fact_vendedor = e.empl_codigo and f2.fact_total > 100 and year(f2.fact_fecha) = 2011) 
ELSE (SELECT COUNT(*)/2 FROM Empleado JOIN Factura ON fact_vendedor = empl_codigo where empl_jefe = e.empl_codigo and year(fact_fecha) = 2011 GROUP BY fact_vendedor)
END
FROM Factura f1
WHERE f1.fact_vendedor = empl_codigo --and year(f1.fact_fecha) = 2011
GROUP BY f1.fact_vendedor
) as 'Puntaje2011',

					(SELECT 
					CASE WHEN COUNT(distinct fact_numero) >= 50 
					THEN (SELECT COUNT(*) from Factura where fact_vendedor = e.empl_codigo and fact_total > 100 and year(fact_fecha) = 2012) 
					ELSE (SELECT COUNT(*)/2 FROM Empleado JOIN Factura ON fact_vendedor = empl_codigo where empl_jefe = e.empl_codigo and year(fact_fecha) = 2012 GROUP BY fact_vendedor)
					END
					FROM Factura
					WHERE fact_vendedor = empl_codigo and year(fact_fecha) = 2012
					GROUP BY fact_vendedor
					) as 'Puntaje2012'
FROM Empleado e


