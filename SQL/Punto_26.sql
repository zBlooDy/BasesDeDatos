--------------
-- PUNTO 26 --
--------------

/*
Escriba una consulta sql que retorne un ranking de empleados devolviendo las
siguientes columnas:
- Empleado
- Depósitos que tiene a cargo
- Monto total facturado en el año corriente
- Codigo de Cliente al que mas le vendió 
- Producto más vendido
- Porcentaje de la venta de ese empleado sobre el total vendido ese año.
Los datos deberan ser ordenados por venta del empleado de mayor a menor.

*/

-- Suponiendo que es todo de año corriente


SELECT empl_codigo, 
(SELECT COUNT(*) FROM DEPOSITO where depo_encargado = empl_codigo),

SUM(fact_total),

(SELECT TOP 1 fact_cliente
FROM Factura
WHERE fact_vendedor = empl_codigo AND year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura)
GROUP BY fact_cliente
ORDER BY SUM(fact_total) desc
),

(SELECT TOP 1 item_producto
FROM Factura
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE fact_vendedor = empl_codigo AND year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura)
GROUP BY item_producto
ORDER BY SUM(item_cantidad) desc),

SUM(fact_total) * 100 / (SELECT SUM(fact_total) FROM Factura WHERE year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura))

FROM Empleado
JOIN Factura ON fact_vendedor = empl_codigo AND year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura)
GROUP BY empl_codigo
order by 3 desc

