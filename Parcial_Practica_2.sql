/* 1.  Realizar una consulta SQL que retorne para el último año, los 5 vendedores con menos clientes asignados,
que más vendieron en pesos (si hay varios con menos clientes asignados debe traer el que más vendió), solo deben
considerarse las facturas que tengan más de dos ítems facturados:

1)   Apellido y Nombre  del Vendedor.
2)   Total de unidades de Producto Vendidas.
3)   Monto promedio de venta por factura.
4)   Monto total de ventas.

El resultado deberá mostrar ordenado la cantidad de ventas descendente, en caso de igualdad de cantidades,
ordenar por código de vendedor.
NOTA: No se permite el uso de sub-selects en el FROM. */


-- La subconsulta del TOP 5 va separada porque despues tenes que ordenar por cant ventas y cod vendedor
SELECT empl_nombre, empl_apellido, SUM(item_cantidad), AVG(fact_total), SUM(item_cantidad * item_precio)
FROM Empleado
JOIN Factura ON fact_vendedor = empl_codigo AND year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura) AND (SELECT COUNT(*) FROM Item_Factura WHERE item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero) > 2
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
GROUP BY fact_vendedor,  empl_nombre, empl_apellido
HAVING fact_vendedor IN (SELECT TOP 5 clie_vendedor
                        FROM Cliente
                        JOIN Factura ON clie_vendedor = fact_vendedor 
                        GROUP BY clie_vendedor
                        ORDER BY COUNT(distinct clie_codigo) asc, SUM(fact_total) desc)
ORDER BY SUM(item_cantidad) desc, fact_vendedor 

/* 2. Dado el contexto inflacionario se tiene que aplicar un control en el cual nunca se permita vender un producto a un 
precio que no esté entre 0%–5% del precio de venta del producto el mes anterior, ni tampoco que esté en más de un 50% el 
precio del mismo producto que hace 12 meses atrás. Aquellos productos nuevos, o que no tuvieron ventas en meses anteriores 
no debe considerar esta regla ya que no hay precio de referencia. */

GO
CREATE TRIGGER verificar_precio ON Item_Factura FOR INSERT 
AS 
BEGIN
    IF (SELECT COUNT(*) FROM Inserted i JOIN Factura f ON i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
                WHERE dbo.cumpleControl(i.item_producto, f.fact_fecha, i.item_precio) = 0) > 0
                ROLLBACK TRANSACTION
    END
END

GO
CREATE FUNCTION cumpleControl(@producto char(8), @fecha datetime, @precio numeric(12,2)) 
RETURNS INT
AS
BEGIN
    DECLARE @precioMesAnterior numeric(12,2), @precioAnioAnterior numeric(12,2)
    SELECT TOP 1 @precioMesAnterior=item_precio FROM Item_Factura JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero WHERE item_producto = @producto AND MONTH(fact_fecha) = MONTH(@fecha)-1 AND year(fact_fecha) = year(@fecha)
    
    SELECT TOP 1 @precioAnioAnterior=item_precio FROM Item_Factura JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero WHERE item_producto = @producto AND YEAR(fact_fecha) = YEAR(@fecha)-1 AND month(fact_fecha) = month(@fecha)

    IF @precioAnioAnterior IS NOT NULL AND @precioAnioAnterior IS NOT NULL
    BEGIN
        IF(@precio < 0.5 * @precioAnioAnterior OR ((ABS(@precio-@precioMesAnterior))/@precioMesAnterior)*100 <= 0.05 )
            RETURN 1
    END
    RETURN 0

END