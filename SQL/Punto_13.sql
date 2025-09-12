--------------
-- PUNTO 13 --
--------------

/*Realizar una consulta que retorne para cada producto que posea composición 
nombre del producto, precio del producto, precio de la sumatoria de los precios por la cantidadde los productos que lo componen. 

Solo se deberán mostrar los productos que estén
compuestos por más de 2 productos y deben ser ordenados de mayor a menor por
cantidad de productos que lo componen.*/



SELECT prod_detalle, prod_precio, 
(
    SELECT SUM(prod_precio * comp_cantidad)
    FROM Producto
    JOIN Composicion ON prod_codigo = comp_componente
    GROUP BY comp_producto
) 'Precio sumatoria de componentes'

FROM Producto p
JOIN Composicion ON prod_codigo = comp_producto

GROUP BY prod_codigo, prod_detalle, prod_precio
HAVING COUNT(*) > 2
ORDER BY COUNT(*) desc






SELECT SUM(prod_precio * comp_cantidad)
FROM Producto
JOIN Composicion ON prod_codigo = comp_componente
GROUP BY comp_producto


select p_compuesto.prod_detalle,
	p_compuesto.prod_precio,
	sum(p_componente.prod_precio * comp_cantidad) 'Sumatoria de precios por la cantidad de los productos que lo componen'
from producto p_compuesto
	join composicion on comp_producto = prod_codigo
	join producto p_componente on p_componente.prod_codigo = comp_componente
group by p_compuesto.prod_detalle, p_compuesto.prod_precio
having count(*) > 2
order by count(*) desc

