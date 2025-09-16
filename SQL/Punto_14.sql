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

Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en
el último año.
No se deberán visualizar NULLs en ninguna columna
*/


SELECT fact_cliente, COUNT(fact_cliente) 'Veces que compro', AVG(fact_total) 'Promedio por compra', 

(SELECT COUNT(distinct(item_producto))
FROM Item_Factura
JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
WHERE fact_cliente = f1.fact_cliente
GROUP BY fact_cliente) 'Cantidad prod dif', MAX(fact_total)

FROM Factura f1
WHERE year(fact_fecha) = (SELECT TOP 1 year(fact_fecha)
                        FROM Factura
                        GROUP BY fact_fecha
                        order by 1 desc)
GROUP BY fact_cliente
order by 2 desc



