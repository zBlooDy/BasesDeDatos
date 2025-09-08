-------------
-- PUNTO 6 --
-------------

/*
Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese rubro y stock total de ese rubro de artículos. 
Solo tener en cuenta aquellos artículos que tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’. 
*/

-- 31 Rubros

SELECT rubr_id, rubr_detalle, COUNT(distinct prod_codigo) as 'CANT.ARTICULOS', SUM(ISNULL(stoc_cantidad,0)) 'CANT.STOCK'
FROM Rubro
LEFT JOIN Producto ON prod_rubro = rubr_id AND 

prod_codigo IN	(SELECT stoc_producto
				FROM Stock
				GROUP BY stoc_producto
				HAVING SUM(stoc_cantidad) >
											(SELECT stoc_cantidad
											FROM Stock
											WHERE stoc_producto = '00000000' AND stoc_deposito = '00'))

LEFT JOIN Stock ON prod_codigo = stoc_producto -- Si tengo stock en distintos lugares, el codigo me lo trae varias veces ==> uso distinct. Uso left x si no tiene stock q lo traiga igual

GROUP BY rubr_id, rubr_detalle
order by 1

--for (rubros)
--	left for(productos)
--		if where
--			filtra los q cumplan la condicion ==> Saco los que no cumplan la condicion y pierdo el rubro si se queda vacio, no tiene el pdoer al LEFT

--Si lo paso al for de productos, no pierdo el rubro, gana el LEFT




