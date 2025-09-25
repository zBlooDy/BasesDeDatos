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
				WHERE stoc_producto = prod_codigo and stoc_cantidad > 0),

				ISNULL((SELECT SUM(stoc_cantidad)					
				FROM Stock
				WHERE stoc_producto = prod_codigo 
				),0)

FROM Producto
JOIN Item_Factura ON item_producto = prod_codigo
JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE prod_codigo IN
					(SELECT item_producto
					FROM Item_Factura
					JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
					WHERE year(fact_fecha) = 2012
					)
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad * item_precio)

-- Estoy utilizando prod codigo para vincularme en el exterior, 
-- si no lo pongo cuando hago el GROUP BY me quedo sin el prod_codigo


-- Si da igual, es mejor hacerlo en el WHERE porque cuando haga el FOR para el
-- GROUP BY ya son menos elementos


-- La condicion va en el having cuando lo que condiciono es una funcion de GRUPO


-- Si tengo 2 filas de item y 2 de stock, trae 4 veces, entonces suma 4 veces