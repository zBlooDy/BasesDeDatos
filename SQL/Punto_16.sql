--------------
-- PUNTO 16 --
--------------

/*
Con el fin de lanzar una nueva campaña comercial para los clientes que menos compran
en la empresa, se pide una consulta SQL que retorne aquellos clientes cuyas compras
son inferiores a 1/3 del monto de ventas del producto que más se vendió en el 2012.
Además mostrar
1. Nombre del Cliente
2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
3. Código de producto que mayor venta tuvo en el 2012 (en caso de existir más de 1,
mostrar solamente el de menor código) para ese cliente.
*/



-- Si no agrupo por clie_codigo, me trae menos elementos porque puede haber cleintes con la misma razon social pero distinto codigo



SELECT clie_razon_social,
            (SELECT SUM(item_cantidad)
            FROM Factura 
            JOIN Item_Factura ON fact_numero+fact_sucursal+fact_tipo = item_numero+item_sucursal+item_tipo
            WHERE fact_cliente = clie_codigo and year(fact_fecha) = 2012
            GROUP BY fact_cliente
            ),
                (
                SELECT TOP 1 item_producto
                FROM Factura
                JOIN Item_Factura ON fact_numero+fact_sucursal+fact_tipo = item_numero+item_sucursal+item_tipo
                WHERE fact_cliente = clie_codigo and year(fact_fecha) = 2012
                GROUP BY fact_cliente, item_producto
                order by SUM(item_cantidad) desc
                )
FROM Cliente
JOIN Factura ON clie_codigo = fact_cliente
GROUP BY clie_codigo, clie_razon_social
HAVING SUM(fact_total) <  
                        (
                        SELECT TOP 1 SUM(item_cantidad * item_precio)
                        FROM Item_Factura
                        JOIN Factura ON fact_numero+fact_sucursal+fact_tipo = item_numero+item_sucursal+item_tipo
                        WHERE year(fact_fecha) = 2012
                        GROUP BY item_producto
                        ORDER BY SUM(item_cantidad) desc
                        ) / 3
                        order by 1
