SELECT fact_vendedor, prod_familia, COUNT(distinct prod_envase) '# Envases ', SUM(item_cantidad) '# Cantidad total vendida de productos'
FROM Factura f
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
JOIN Producto ON prod_codigo = item_producto
WHERE prod_familia IN (SELECT fami_id FROM Familia
                        JOIN Producto ON prod_familia = fami_id
                        WHERE prod_codigo = (SELECT TOP 1 prod_codigo
                                            FROM Factura
                                            JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
                                            JOIN Producto ON item_producto = prod_codigo
                                            WHERE fact_vendedor = f.fact_vendedor
                                            GROUP BY prod_codigo
                                            ORDER BY SUM(item_cantidad * item_precio) desc )) -- Entendi que es la familia del producto que mas se vendio
GROUP BY fact_vendedor, prod_familia
HAVING fact_vendedor IN (SELECT clie_vendedor
                        FROM Cliente
                        WHERE clie_vendedor = fact_vendedor
                        GROUP BY clie_vendedor
                        HAVING COUNT(*) > 100)
ORDER BY (SELECT COUNT(*)
          FROM Cliente
          WHERE clie_vendedor = fact_vendedor) DESC
 
----------- TSQL ----------------

GO
CREATE OR ALTER TRIGGER verificar_vendedor ON Factura FOR INSERT, DELETE
AS 
BEGIN
    DECLARE cursorFacturas CURSOR FOR SELECT clie_codigo, clie_vendedor FROM Factura JOIN Cliente ON fact_cliente = clie_codigo GROUP BY clie_codigo, clie_vendedor
    DECLARE @cliente char(6), @vendedor numeric(6), @nuevoVendedor numeric(6)
    OPEN cursorFacturas
    FETCH cursorFacturas INTO @cliente, @vendedor
    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        IF @vendedor <> (SELECT TOP 1 fact_vendedor FROM Factura WHERE fact_cliente = @cliente GROUP BY fact_vendedor ORDER BY COUNT(*) desc)
        BEGIN
            SET @nuevoVendedor = (SELECT TOP 1 fact_vendedor FROM Factura WHERE fact_cliente = @cliente GROUP BY fact_vendedor ORDER BY COUNT(fact_vendedor) desc)
            UPDATE Cliente SET clie_vendedor = @nuevoVendedor WHERE clie_codigo = @cliente
        END

        FETCH cursorFacturas INTO @cliente, @vendedor
    END
    CLOSE cursorFacturas
    DEALLOCATE cursorFacturas
END
