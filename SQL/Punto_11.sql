--------------
-- PUNTO 11 --
--------------


/*Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
productos vendidos y el monto de dichas ventas sin impuestos. 
Los datos se deberán ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga.

Solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para
el año 2012.*/

/*Ventas sin impuestos: Cantidad * precio 
-> 
*/

SELECT fami_detalle, COUNT(distinct(prod_codigo)) 'PROD.VENDIDOS', SUM(item_cantidad * item_precio) 'SUMA DE VENTAS'
FROM Familia 
JOIN Producto ON prod_familia = fami_id
JOIN Item_Factura ON prod_codigo = item_producto
GROUP BY fami_detalle
HAVING fami_detalle IN (
    SELECT fami_detalle
    FROM Familia 
    JOIN Producto ON prod_familia = fami_id
    JOIN Item_Factura ON prod_codigo = item_producto
    JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
    WHERE year(fact_fecha) = 2012
    GROUP BY fami_detalle
    HAVING SUM(item_cantidad * item_precio) > 20000
)
ORDER BY COUNT(item_producto) desc