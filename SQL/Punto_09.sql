-------------
-- PUNTO 9 --
-------------

/*Mostrar el codigo del jefe, codigo del empleado que lo tiene como jefe, nombre del mismo y 
la cantidad de depositos que ambos tienen asignados. */


SELECT ISNULL(empl_jefe, empl_codigo) 'Codigo Jefe', empl_codigo 'COD.EMPLEADO DEL JEFE', empl_nombre, COUNT(*)
FROM Empleado
JOIN Deposito ON empl_jefe = depo_encargado OR empl_codigo = depo_encargado
GROUP BY empl_jefe, empl_codigo, empl_nombre



SELECT depo_encargado, COUNT(*)
from Deposito
GROUP BY depo_encargado

SELECT * from Deposito
