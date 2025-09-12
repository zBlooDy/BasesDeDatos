--------------
-- PUNTO 13 --
--------------

/*Realizar una consulta que retorne para cada producto que posea composición 
nombre del producto, precio del producto, precio de la sumatoria de los precios por la cantidadde los productos que lo componen. 

Solo se deberán mostrar los productos que estén
compuestos por más de 2 productos y deben ser ordenados de mayor a menor por
cantidad de productos que lo componen.*/



SELECT p.prod_detalle, p.prod_precio, SUM(prodcomponente.prod_precio * comp_cantidad)
FROM Producto p
JOIN Composicion ON p.prod_codigo = comp_producto
JOIN Producto prodcomponente ON prodcomponente.prod_codigo = comp_componente
GROUP BY p.prod_codigo, p.prod_detalle, p.prod_precio
HAVING COUNT(*) > 2
ORDER BY COUNT(*) desc


-- Esta opcion es mejor que la anterior porque la subquery que hacia no era estatica, sino que dinamica. Y ademas en teoria tenia mas FOR que meterle un join mas




