---------
-- SQL --
---------

/* 1. Sabiendo que si un producto no es vendido en un deposito determinado entonces no posee registros en él.
Se requiere una consulta sql que para todos los productos que se quedaron sin stock en un deposito (cantidad 0 o nula) y
poseen un stock con mayor al punto de reposicion en otro deposito devuelva:

    - Codigo de producto 
    - Detalle de producto 
    - Domicilio del depósito sin stock 
    - Cantidad de depositos con un stock superior al punto de reposicion

La consulta debe ser ordenada por el codigo de producto 
*/

SELECT prod_codigo, prod_detalle, depo_domicilio 'Depo sin stock', COUNT(distinct s2.stoc_deposito) '# Depo con stoc mayor'
FROM Producto
JOIN Stock s1 ON prod_codigo = s1.stoc_producto AND (stoc_cantidad = 0 OR stoc_cantidad IS NULL)
JOIN Stock s2 ON prod_codigo = s2.stoc_producto AND (s2.stoc_cantidad > s2.stoc_punto_reposicion)
JOIN Deposito ON s1.stoc_deposito = depo_codigo
GROUP BY prod_codigo, prod_detalle, depo_domicilio
ORDER BY prod_codigo
GO

----------
-- TSQL --
----------


/* 2. Dado el contexto inflacionario se tieen que aplicar el control en el cual nunca se permita vender un producto
a un precio que no esté entre el 0%-5% del precio de venta del producto el mes anterior, ni tampoco que esté más de un 50%
el precio del mismo producto que hace 12 meses atrás. Aquellos productos nuevos, o que no estuvieron ventas en meses anteriores
no debe considerar esta regla ya que no hay precio de referencia
*/

CREATE TRIGGER verificar_inflacion ON Item_Factura FOR INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM Inserted JOIN Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal
                WHERE dbo.supera_inflacion(item_producto, item_precio, fact_fecha) = 1)
        ROLLBACK
END
GO

CREATE FUNCTION supera_inflacion(@prod char(8), @precio numeric(12,2), @fecha smalldatetime)
RETURNS INT
AS
BEGIN
    DECLARE @resultado INT = 0
    DECLARE @precioMesAnterior numeric(12,2), @precioAnioAnterior numeric(12,2)

    SELECT TOP 1 @precioMesAnterior=item_precio FROM Item_Factura 
    JOIN Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal
    WHERE item_producto = @prod AND year(@fecha) = year(fact_fecha) AND month(@fecha) - 1 = month(fact_fecha) 
    ORDER BY item_precio desc

    SELECT TOP 1 @precioAnioAnterior=item_precio FROM Item_Factura 
    JOIN Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal
    WHERE item_producto = @prod AND year(@fecha) - 1 = year(fact_fecha) AND month(@fecha) = month(fact_fecha) 
    ORDER BY item_precio desc

    IF (@precio > 1.5 * @precioAnioAnterior OR (@precio < @precioMesAnterior AND @precio > @precioMesAnterior * 1.05))
        SET @resultado = 1

    RETURN @resultado
END
