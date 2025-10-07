--------------
-- PUNTO 19 --
--------------

/*
19. En virtud de una recategorizacion de productos referida a la familia de los mismos se
solicita que desarrolle una consulta sql que retorne para todos los productos:

- Codigo de producto
- Detalle del producto
- Codigo de la familia del producto
- Detalle de la familia actual del producto
- Codigo de la familia sugerido para el producto
- Detalle de la familia sugerido para el producto

La familia sugerida para un producto es la que poseen la mayoria de los productos cuyo
detalle coinciden en los primeros 5 caracteres.
En caso que 2 o mas familias pudieran ser sugeridas se debera seleccionar la de menor
codigo. 

Solo se deben mostrar los productos para los cuales la familia actual sea
diferente a la sugerida
Los resultados deben ser ordenados por detalle de producto de manera ascendente
*/


SELECT p1.prod_codigo, p1.prod_detalle, p1.prod_familia, fami_detalle, 
								(SELECT TOP 1 p2.prod_familia
								FROM Producto p2
								where left(p1.prod_detalle, 5) = left(p2.prod_detalle,5)
								GROUP BY p2.prod_familia
								ORDER BY COUNT(*) desc
								) 'Cod. familia sugerida',

								(SELECT TOP 1 f2.fami_detalle
								FROM Producto p2
								JOIN Familia f2 ON f2.fami_id = p2.prod_familia
								where left(p1.prod_detalle, 5) = left(p2.prod_detalle,5)
								GROUP BY f2.fami_detalle
								ORDER BY COUNT(*) desc
								) 'Det. Familia sugerida'
FROM Producto p1
JOIN Familia ON prod_familia = fami_id
group by p1.prod_codigo, p1.prod_detalle, p1.prod_familia, fami_detalle
having fami_detalle <> (SELECT TOP 1 f2.fami_detalle
						FROM Producto p2
						JOIN Familia f2 ON f2.fami_id = p2.prod_familia
						where left(p1.prod_detalle, 5) = left(p2.prod_detalle,5)
						GROUP BY f2.fami_detalle
						ORDER BY COUNT(*) desc
						)
order by 2 












/*
SELECT p1.prod_codigo, p1.prod_detalle, p1.prod_familia, fami_detalle, p2.prod_familia, MIN(p2.prod_familia)
FROM Producto p1
JOIN Familia ON prod_familia = fami_id
JOIN Producto p2 ON p2.prod_familia != p1.prod_familia and p2.prod_detalle like concat(left(p1.prod_detalle, 5), '%') 
group by p1.prod_codigo, p1.prod_detalle, p1.prod_familia, fami_detalle, p2.prod_familia
ORDER BY p1.prod_detalle asc


SELECT left(prod_detalle, 5)
FROM Producto
*/