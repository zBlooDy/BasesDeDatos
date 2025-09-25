--------------
-- PUNTO 15 --
--------------

/*Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos
(en la misma factura) más de 500 veces. 
El resultado debe mostrar el código y descripción de cada uno de los productos y la cantidad de veces que fueron vendidos
juntos. 

El resultado debe estar ordenado por la cantidad de veces que se vendieron juntos dichos productos. 
Los distintos pares no deben retornarse más de una vez.

Ejemplo de lo que retornaría la consulta:
PROD1 DETALLE1          PROD2 DETALLE2                VECES
1731 MARLBORO KS        1718   PHILIPS MORRIS KS      507
1718 PHILIPS MORRIS KS  1705   PHILIPS MORRIS BOX 10  562*/


-- Contar las veces que aparecen en una misma factura p1 y i2

SELECT p1.prod_codigo, p1.prod_detalle, i2.item_producto, p2.prod_detalle, COUNT(i2.item_producto) 'Cant veces vendidos juntos'
FROM Producto p1
JOIN Item_Factura i1 ON p1.prod_codigo = i1.item_producto
JOIN Item_Factura i2 ON i1.item_numero+i1.item_tipo+i1.item_sucursal = i2.item_numero+i2.item_tipo+i2.item_sucursal and (i2.item_producto > p1.prod_codigo)
JOIN Producto p2 ON p2.prod_codigo = i2.item_producto
GROUP BY p1.prod_codigo, p1.prod_detalle, i2.item_producto, p2.prod_detalle
HAVING COUNT(i2.item_producto) > 500
--JOIN Producto p2 ON p2.prod_codigo = i1.item_producto
order by 5
