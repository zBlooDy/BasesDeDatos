-------------
-- PUNTO 7 --
-------------

/*Generar una consulta que muestre para cada art�culo c�digo, detalle, mayor precio, menor precio y % de la diferencia de precios 
(respecto del menor Ej.: menor precio = 10, mayor precio =12 => mostrar 20 %). 
Mostrar solo aquellos art�culos que posean stock. 
*/

-- 1373 productos con stock

SELECT prod_codigo, prod_detalle, MIN(item_precio) 'MENOR PRECIO', MAX(item_precio) 'MAYOR PRECIO', STR((((MAX(item_precio) - MIN(item_precio))*100)/MIN(item_precio)),15,2)+' %' as 'DIF %'
FROM Producto
JOIN Item_Factura ON prod_codigo = item_producto		-- Tengan o no una factura, quiero mostrar los que posean stock
WHERE prod_codigo IN (
                        SELECT stoc_producto
                        FROM STOCK
                        WHERE stoc_cantidad > 0
)
GROUP BY prod_codigo, prod_detalle
ORDER BY prod_codigo



