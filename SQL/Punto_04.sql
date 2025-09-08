-------------
-- PUNTO 4 --
-------------


/*
Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de artículos que lo componen. 
Mostrar solo aquellos artículos para los cuales el stock promedio por depósito sea mayor a 100.
*/

SELECT prod_codigo, prod_detalle, COUNT(comp_cantidad)
FROM Producto
-- WHERE prod_codigo cumpla que el stock promedio sea mayor a 100 ==> Esto lo puedo sacar de una consulta especifica
LEFT JOIN Composicion ON prod_codigo = comp_producto
WHERE prod_codigo IN (SELECT stoc_producto
					  FROM Stock
					  GROUP BY stoc_producto
					  HAVING AVG(stoc_cantidad) > 100)
GROUP BY prod_codigo, prod_detalle

-- Con el select en el where, me aseguro que no cambie la atomicidad de mi universo, porque si yo hacia otro JOIN, estaba expandiendolo. 





