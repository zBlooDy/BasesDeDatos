/* Se requiere armar una estadística que retorne para cada año y familia el cliente que menos
productos diferentes compró y que más monto compró para ese año y familia */

/*
Año, Razón Social Cliente, Familia, Cantidad de unidades compradas de esa familia
Los resultados deben ser ordenados por año de menor a mayor y para cada año ordenados por la familia que menos productos tenga asignados
NOTA: No se permite el uso de sub-selects en el FROM.
*/


SELECT year(f.fact_fecha), p.prod_familia, 
(SELECT TOP 1 clie_razon_social
FROM Factura 
JOIN Item_Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal
JOIN Producto p1 ON item_producto = p1.prod_codigo
JOIN Cliente ON fact_cliente = clie_codigo
WHERE year(fact_fecha) = year(f.fact_fecha) AND p1.prod_familia = p.prod_familia
GROUP BY fact_cliente, clie_razon_social
ORDER BY SUM(item_cantidad * item_precio) desc, COUNT(distinct p1.prod_codigo) asc
) 'Cliente',
SUM(item_cantidad) 'Cantidad de unidades vendidas'

FROM Factura f
JOIN Item_Factura ON f.fact_tipo+f.fact_numero+f.fact_sucursal = item_tipo+item_numero+item_sucursal
JOIN Producto p ON item_producto = p.prod_codigo
GROUP BY year(f.fact_fecha), p.prod_familia
ORDER BY year(f.fact_fecha) asc, (SELECT COUNT(distinct(prod_codigo)) FROM Producto WHERE prod_familia = p.prod_familia) asc

/*
2. Realizar un stored procedure que calcule e informe la comisión de un vendedor para un determinado mes.
Los parámetros de entrada es código de vendedor, mes y año.
El criterio para calcular la comisión es: 5% del total vendido tomando como importe base el valor de la factura
sin los impuestos del mes a comisionar, a esto se le debe sumar un plus de 3% más en el caso de que sea el vendedor
que más vendió los productos nuevos en comparación al resto de los vendedores, es decir este plus se le aplica solo
a un vendedor y en caso de igualdad se le otorga al que posea el código de vendedor más alto.

Se considera que un producto es nuevo cuando su primera venta en la empresa se produjo durante el mes en curso
o en alguno de los 4 meses anteriores. De no haber ventas de productos nuevos en ese periodo, ese plus nunca se aplica. */

GO
CREATE PROCEDURE calculo_comision (@vendedor char(6), @mes char(2), @anio char(4), @comision numeric(12,2) OUTPUT)
AS
BEGIN
	DECLARE @comision_ejercicio numeric(5,2)
	SELECT @comision_ejercicio = 0.05

	IF @vendedor = (SELECT TOP 1 fact_vendedor FROM Factura 
					JOIN Item_Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal
					WHERE dbo.producto_nuevo(item_producto, @mes, @anio) = 1
					ORDER BY SUM(item_cantidad*item_precio) desc, fact_vendedor desc)
	SELECT @comision_ejercicio = 0.08

	RETURN SELECT SUM(fact_total)*@comision_ejercicio FROM Factura WHERE fact_vendedor = @vendedor AND year(fact_fecha) = @anio AND month(fact_fecha) = @mes


END

GO
CREATE OR ALTER FUNCTION producto_nuevo (@producto char(8), @mes char(2), @anio char(4)) 
RETURNS INT
AS
BEGIN
	DECLARE @es_nuevo INT
	SELECT @es_nuevo = 0
	IF @producto IN (SELECT item_producto FROM Item_Factura i
					JOIN Factura ON fact_tipo+fact_numero+fact_sucursal = i.item_tipo+i.item_numero+i.item_sucursal 
					AND fact_fecha = (SELECT TOP 1 fact_fecha FROM Factura 
										JOIN Item_Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal 
										WHERE item_producto = i.item_producto 
										ORDER BY fact_fecha asc) 
					WHERE year(fact_fecha) = @anio AND (month(fact_fecha) >= @mes-4 AND month(fact_fecha) <= @mes))
	SELECT @es_nuevo = 1
	
	RETURN @es_nuevo
END




