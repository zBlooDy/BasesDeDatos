--------------
-- PUNTO 12 --
--------------

/*Mostrar nombre de producto, cantidad de clientes distintos que lo compraron, importe
promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del
producto y stock actual del producto en todos los depósitos. 

Se deberán mostrar aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
ordenarse de mayor a menor por monto vendido del producto.*/

SELECT prod_detalle, COUNT(distinct(fact_cliente)) '# CLIENTES', AVG(item_precio) 'IMPORTE PRECIO', COUNT(stoc_producto)
FROM Producto
LEFT JOIN Item_Factura ON item_producto = prod_codigo
JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
JOIN Stock ON prod_codigo = stoc_producto and stoc_cantidad > 0
GROUP BY prod_detalle
