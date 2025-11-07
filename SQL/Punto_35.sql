--------------
-- PUNTO 35 --
--------------

/*
Se requiere realizar una estadística de ventas por año y producto, para ello se solicita
que escriba una consulta sql que retorne las siguientes columnas:
-> Año
-> Codigo de producto
-> Detalle del producto
-> Cantidad de facturas emitidas a ese producto ese año
-> Cantidad de vendedores diferentes que compraron ese producto ese año.
-> Cantidad de productos a los cuales compone ese producto, si no compone a ninguno
se debera retornar 0.
-> Porcentaje de la venta de ese producto respecto a la venta total de ese año.
Los datos deberan ser ordenados por año y por producto con mayor cantidad vendida.
*/

SELECT year(f.fact_fecha) 'Año', 
prod_codigo, 
prod_detalle,
COUNT(distinct fact_numero) '# Facturas',
COUNT(distinct fact_cliente) '# Clientes',
ISNULL((SELECT COUNT(*) FROM Composicion WHERE comp_producto = prod_codigo),0) '# Componentes',
SUM(item_cantidad * item_precio) * 100 / (SELECT SUM(fact_total) FROM Factura WHERE year(fact_fecha) = year(f.fact_fecha))  '%'
FROM Factura f
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
JOIN Producto ON item_producto = prod_codigo
GROUP BY year(f.fact_fecha), prod_codigo, prod_detalle
ORDER BY year(f.fact_fecha), SUM(item_cantidad) desc