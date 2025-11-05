-------------------
-- PUNTO 28 y 31 --
-------------------

/*
Escriba una consulta sql que retorne una estadística por Año y Vendedor que retorne las
siguientes columnas:

- Año.
- Codigo de Vendedor
- Detalle del Vendedor
- Cantidad de facturas que realizó en ese año
- Cantidad de clientes a los cuales les vendió en ese año.
- Cantidad de productos facturados con composición en ese año
- Cantidad de productos facturados sin composicion en ese año.
- Monto total vendido por ese vendedor en ese año

Los datos deberan ser ordenados por año y dentro del año por el vendedor que haya
vendido mas productos diferentes de mayor a menor.
*/

SELECT year(f.fact_fecha), 
empl_codigo, 
LTRIM(RTRIM(empl_nombre)) + ' ' + LTRIM(RTRIM(empl_apellido)) 'Empleado',
COUNT(distinct fact_numero) '# Facturas',
COUNT(distinct fact_cliente) '# Clientes',

(SELECT COUNT(*) FROM Factura 
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
JOIN Composicion ON item_producto = comp_producto
WHERE year(f.fact_fecha) = year(fact_fecha) AND fact_vendedor = empl_codigo) '# Prod con comp.',
                        
(SELECT COUNT(*) FROM Factura 
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE year(f.fact_fecha) = year(fact_fecha) AND fact_vendedor = empl_codigo AND item_producto NOT IN (SELECT comp_producto FROM Composicion)) '# Prod sin comp.',

SUM(item_cantidad * item_precio) 'Monto total vendido'

FROM Factura f
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
JOIN Empleado ON f.fact_vendedor = empl_codigo                                                                                                                                                                                          
GROUP BY year(f.fact_fecha), empl_codigo, empl_nombre, empl_apellido
ORDER BY year(f.fact_fecha), COUNT(distinct item_producto) desc
