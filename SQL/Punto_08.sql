-------------
-- PUNTO 8 --
-------------

/*Mostrar para el o los art�culos que tengan stock en todos los dep�sitos, 
nombre del art�culo, stock del dep�sito que m�s stock tiene. */

-- Primera opcion que se me ocurrio, hay un SELECT de mas en realidad, y es el de stoc_producto
SELECT  prod_detalle, MAX(stoc_cantidad)
FROM Producto
JOIN Stock ON prod_codigo = stoc_producto 
WHERE prod_codigo IN (SELECT stoc_producto
						FROM Stock
						GROUP BY stoc_producto
						HAVING COUNT(*) = (SELECT COUNT(distinct(stoc_deposito))
											FROM Stock))
GROUP BY prod_detalle


-- Segunda version, mejorada.
SELECT prod_detalle, MAX(stoc_cantidad)
FROM Producto
JOIN Stock ON prod_codigo = stoc_producto 					
GROUP BY prod_detalle
HAVING COUNT(*) = (SELECT COUNT(*)
					FROM Deposito)


-- Otra interpretacion de la consigna ==> Que tengan stock en todos los depositos que haya

SELECT prod_detalle, MAX(stoc_cantidad)
FROM Producto
JOIN Stock ON prod_codigo = stoc_producto 					
GROUP BY prod_detalle
HAVING MIN(stoc_cantidad) > 0


