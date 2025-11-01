--------------
-- PUNTO 24 --
--------------

/*
Escriba una consulta que considerando solamente las facturas correspondientes a los
dos vendedores con mayores comisiones, retorne los productos con composición
facturados al menos en cinco facturas,
La consulta debe retornar las siguientes columnas:
- Código de Producto
- Nombre del Producto
- Unidades facturadas
El resultado deberá ser ordenado por las unidades facturadas descendente
*/

SELECT prod_codigo, prod_detalle, SUM(item_cantidad)
FROM Factura
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
JOIN Composicion ON item_producto = comp_producto
JOIN Producto ON comp_producto = prod_codigo
WHERE fact_vendedor IN (SELECT TOP 2 empl_codigo
						FROM Empleado
						ORDER BY empl_comision desc)
GROUP BY prod_codigo, prod_detalle
HAVING COUNT(fact_tipo+fact_sucursal+fact_numero) >= 5
ORDER BY SUM(item_cantidad) DESC

