--------------
-- PUNTO 12 --
--------------

/*Mostrar nombre de producto, cantidad de clientes distintos que lo compraron, importe
promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del
producto y stock actual del producto en todos los depósitos. 

Se deberán mostrar aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
ordenarse de mayor a menor por monto vendido del producto.*/

SELECT prod_detalle, COUNT(distinct(fact_cliente)) '# CLIENTES', AVG(item_precio) 'IMPORTE PRECIO', 

(SELECT COUNT(*)					
FROM Stock
WHERE stoc_producto = prod_codigo and stoc_cantidad > 0 
),

(SELECT SUM(stoc_cantidad)					
FROM Stock
WHERE stoc_producto = prod_codigo 
)

FROM Producto
LEFT JOIN Item_Factura ON item_producto = prod_codigo
JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE prod_codigo IN
					(SELECT prod_codigo
					FROM Producto
					LEFT JOIN Item_Factura ON item_producto = prod_codigo
					JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
					WHERE year(fact_fecha) = 2012
					GROUP BY prod_codigo, prod_detalle
					)
GROUP BY prod_codigo, prod_detalle
ORDER BY prod_detalle



