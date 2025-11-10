---------
-- SQL --
---------

/*
0. Realizar una consulta SQL que permita saber 
los clientes que compraron todos los rubros disponibles del sistema en el 2012.

De estos clientes mostrar, siempre para el 2012:
1. El codigo del cliente !
2. Codigo de producto que en cantidades mas compro. !
3. El nombre del producto del punto 2. !
4. Cantidad de productos distintos comprados por el cliente. !
5. Cantidad de productos con composicion comprados por el cliente. !
6a. El resultado debera ser ordenado por razon social del cliente alfabeticamente primero !
6b.	y luego, los clientes que compraron entre un
	20 % y 30% del total facturado en el 2012 primero, luego, los restantes
*/

SELECT clie_codigo, 
(SELECT TOP 1 item_producto
FROM Factura
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE year(fact_fecha) = 2012 AND fact_cliente = clie_codigo
GROUP BY item_producto
ORDER BY SUM(item_cantidad) desc
),
(SELECT TOP 1 prod_detalle
FROM Factura
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
JOIN Producto ON item_producto = prod_codigo
WHERE year(fact_fecha) = 2012 AND fact_cliente = clie_codigo
GROUP BY prod_detalle
ORDER BY SUM(item_cantidad) desc
),
COUNT(distinct prod_codigo),
(SELECT SUM(item_cantidad) 
FROM Factura
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE year(fact_fecha) = 2012 AND fact_cliente = clie_codigo AND item_producto IN (SELECT comp_producto FROM Composicion)
GROUP BY item_producto
)
FROM Cliente
JOIN Factura ON clie_codigo = fact_cliente
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
JOIN Producto ON prod_codigo = item_producto
WHERE year(fact_fecha) = 2012
GROUP BY clie_codigo, clie_razon_social
HAVING COUNT(distinct prod_rubro) = (SELECT COUNT(*) FROM Rubro)
ORDER BY clie_razon_social, SUM(item_cantidad * item_precio) * 100 / (SELECT SUM(fact_total) FROM Factura WHERE year(fact_fecha) = 2012) desc


/*

. Implementar una regla de negocio en línea que al realizar una venta (SOLO INSERCION) permita componer los productos descompuestos,
	es decir, si se guardan en la factura 2 hamb, 2 papas 2 gaseosas se deberá guardar en la factura 2 (DOS) combo1, 
	. Si 1 combo1 equivale a: 1 hamb. 1 papa y 1 gaseosa.

.Nota: Considerar que cada vez que se guardan los items, se mandan todos los productos de ese item a la vez, y no de manera parcial.
*/

-- Ahi va che


