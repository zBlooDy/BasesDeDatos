-------------
-- PUNTO 9 --
-------------

/*Mostrar el c�digo del jefe, c�digo del empleado que lo tiene como jefe, nombre del mismo y 
la cantidad de dep�sitos que ambos tienen asignados. */


SELECT ISNULL(empl_jefe, empl_codigo) 'Codigo Jefe', empl_codigo 'COD.EMPLEADO DEL JEFE', empl_nombre
FROM Empleado



SELECT depo_encargado, COUNT(*)
from Deposito
GROUP BY depo_encargado

SELECT * from Deposito




