--------------
-- PUNTO 30 --
--------------
/*
Se desea obtener una estadistica de ventas del año 2012, para los empleados que sean
jefes, o sea, que tengan empleados a su cargo, para ello se requiere que realice la
consulta que retorne las siguientes columnas:
 Nombre del Jefe
 Cantidad de empleados a cargo
 Monto total vendido de los empleados a cargo
 Cantidad de facturas realizadas por los empleados a cargo
 Nombre del empleado con mejor ventas de ese jefe
Debido a la perfomance requerida, solo se permite el uso de una subconsulta si fuese
necesario.
Los datos deberan ser ordenados por de mayor a menor por el Total vendido y solo se
deben mostrarse los jefes cuyos subordinados hayan realizado más de 10 facturas.
*/

SELECT j.empl_nombre,

COUNT(distinct e.empl_nombre) '# Empleados',

SUM(fact_total) 'Monto total vendido por empl.',

COUNT(fact_numero) '# Facturas',

(SELECT TOP 1 empl_nombre 
FROM Empleado
JOIN Factura ON fact_vendedor = empl_codigo
WHERE empl_jefe = j.empl_codigo
GROUP BY fact_vendedor, empl_nombre
ORDER BY SUM(fact_total) desc) 'Empl. que mas vendio'

FROM Empleado j
JOIN Empleado e ON e.empl_jefe = j.empl_codigo
LEFT JOIN Factura ON fact_vendedor = e.empl_codigo 
WHERE year(fact_fecha) = 2012
GROUP BY j.empl_nombre, j.empl_codigo

