--------------
-- PUNTO 29 --
--------------

/*
Se solicita que realice una estadística de venta por producto para el año 2011, solo para
los productos que pertenezcan a las familias que tengan más de 20 productos asignados
a ellas, la cual deberá devolver las siguientes columnas:
a. Código de producto
b. Descripción del producto
c. Cantidad vendida
d. Cantidad de facturas en la que esta ese producto
e. Monto total facturado de ese producto

Solo se deberá mostrar un producto por fila en función a los considerandos establecidos
antes. El resultado deberá ser ordenado por el la cantidad vendida de mayor a menor.
*/

SELECT prod_codigo, prod_detalle, SUM(item_cantidad) 'Cant. vendida', COUNT(distinct fact_numero) 'Cant. facturas', SUM(item_cantidad * item_precio) 'Monto total'
FROM Producto
JOIN Item_Factura ON item_producto = prod_codigo
JOIN Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal
WHERE year(fact_fecha) = 2011 AND prod_familia IN (SELECT prod_familia 
													FROM Producto
													GROUP BY prod_familia
													HAVING COUNT(*) > 20 )
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad) desc

SELECT prod_codigo, prod_detalle, SUM(item_cantidad), COUNT(fact_numero), SUM(fact_total)
FROM Producto
JOIN Item_Factura on item_producto = prod_codigo
JOIN Factura ON item_tipo+item_sucursal+item_numero=fact_tipo+fact_sucursal+fact_numero
group by prod_codigo, prod_detalle
order by 3