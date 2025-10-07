--------------
-- PUNTO 14 --
--------------

/*Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que
debe retornar son:

Código del cliente
Cantidad de veces que compro en el último año
Promedio por compra en el último año
Cantidad de productos diferentes que compro en el último año
Monto de la mayor compra que realizo en el último año

Se deberán retornar TODOS los clientes ordenados por la cantidad de veces que compro en
el último año.
No se deberán visualizar NULLs en ninguna columna
*/


SELECT clie_codigo, COUNT(distinct fact_tipo+fact_numero+fact_sucursal) 'Veces que compro', isnull(AVG(fact_total),0) 'Promedio por compra', isnull(COUNT(distinct(item_producto)),0 ), isnull(MAX(fact_total),0)

FROM Cliente
LEFT JOIN Factura ON clie_codigo = fact_cliente AND year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura)
LEFT JOIN Item_Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
GROUP BY clie_codigo
order by 2 desc

-- Hago el LEFT porque quierto que traiga todos los clientes, no solo los que compraron
