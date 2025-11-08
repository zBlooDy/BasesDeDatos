---------
-- SQL --
---------

/* 1. Consulta SQL para analizar clientes con patrones de cmpra especificos

Se debe identificar clientes que realizarion una compra inicial y luego volvieron a 
comprar despues de 5 meses o mas 

La consulta debe mostrar 
    - El numero de fila: identificador secuencial del resultado
    - el codigo del cliente id unico del cliente
    - el nombre del cliente: nombre asociado al cliente 
    - cantidad total comprada: total de productos distintos adquiridos por el cliente
    - total facturado: importe total factura al cliente 
El resultado debe estsr ordenado de forma descendente por la cantidad de productos 
adquiridos por cada cliente
*/ 

SELECT clie_codigo, clie_razon_social, COUNT(distinct item_producto), SUM(item_cantidad * item_precio)
FROM Cliente c
JOIN Factura f ON f.fact_cliente = c.clie_codigo
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero=f.fact_tipo+f.fact_sucursal+f.fact_numero
GROUP BY clie_codigo, clie_razon_social
HAVING DATEDIFF(MONTH, MIN(f.fact_fecha), (SELECT TOP 1 fact_fecha
                                        FROM Factura
                                        WHERE fact_cliente = c.clie_codigo
                                        GROUP BY fact_fecha
                                            HAVING fact_fecha <> (SELECT MIN(fact_fecha) FROM Factura WHERE fact_cliente = c.clie_codigo)
                                        ORDER BY fact_fecha asc) ) >= 5


SELECT * FROM Factura WHERE fact_cliente = 01772 

----------
-- TSQL --
----------
/* 2. Se detectó un error en el proceso de registro de ventas, donde se almacenaron productos compuestos
en lugar de sus componentes individuales. Para solucionar este problema, se debe:

    1. Diseñar e implmenetar los objetos necesarios para reoganizar las ventas tal como están registradas actualmente 
    2. Desagregar los productos compuestos vendidos en sus componenetes individuales, asegurando
    que cada venta refleje correctamente los elementos que la compronen
    3. Garantizar que la base de datos quede consistente y alineada con las especificaciones requeridas para el manejo de poductos
*/

GO
CREATE PROCEDURE corregir_compuestos
AS
BEGIN
    DECLARE cursorItems CURSOR FOR SELECT item_producto, item_numero, item_tipo, item_sucursal, item_cantidad FROM Item_Factura 
                                    WHERE item_producto IN (SELECT comp_producto FROM Composicion) 
                                    GROUP BY item_producto, item_numero, item_tipo, item_sucursal
    DECLARE @prod char(8), @numero char(8), @tipo char(1), @sucursal char(4), @cant numeric(12,2)
    OPEN cursorItems
    FETCH cursorItems INTO @prod, @numero, @tipo, @sucursal, @cant
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @componente char(8), @cant_comp numeric(12,2), @precio numeric(12,2)
        DECLARE cursorComponentes CURSOR FOR SELECT comp_componente, comp_cantidad, prod_precio FROM Composicion JOIN Producto ON prod_codigo = comp_cantidad WHERE comp_producto = @prod
        OPEN cursorComponentes
        FETCH cursorComponentes INTO @componente, @cant_comp, @precio
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO Item_Factura VALUES(@tipo, @sucursal, @numero, @componente, @cant * @cant_comp, @cant * @cant_comp * @precio)
            FETCH cursorComponentes INTO @componente, @cant_comp, @precio
        END

        DELETE FROM Item_Factura WHERE item_tipo+item_numero+item_sucursal = @tipo+@numero+@sucursal AND item_producto = @prod
        
        FETCH cursorItems INTO @prod, @numero, @tipo, @sucursal, @cant
    END
    CLOSE cursorItems
    DEALLOCATE cursorItems
END