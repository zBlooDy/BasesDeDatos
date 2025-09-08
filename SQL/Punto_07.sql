-------------
-- PUNTO 7 --
-------------

/*Generar una consulta que muestre para cada artículo código, detalle, mayor precio, menor precio y % de la diferencia de precios 
(respecto del menor Ej.: menor precio = 10, mayor precio =12 => mostrar 20 %). 
Mostrar solo aquellos artículos que posean stock. 
*/

-- 1373 productos con stock

SELECT prod_codigo, prod_detalle, ISNULL(MIN(item_precio),0) 'MENOR PRECIO', ISNULL(MAX(item_precio),0) 'MAYOR PRECIO', STR((ISNULL(((MAX(item_precio) - MIN(item_precio))*100)/MIN(item_precio),0)),15,2)+' %' as 'DIF %'
FROM Producto
JOIN Stock ON prod_codigo = stoc_producto				-- Limito a solo los que tienen stock
LEFT JOIN Item_Factura ON prod_codigo = item_producto		-- Tengan o no una factura, quiero mostrar los que posean stock
GROUP BY prod_codigo, prod_detalle
order by 5 desc



