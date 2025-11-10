---------
-- SQL --
---------

/* 1. Realizar una consulta que muestre, para los clientes que compraron 
únicamente en años pares, la siguiente información: 
    - El numero de fila
    - el codigo de cliente
    - el nombre del producto más comprado por el cliente
    - la cantidad total comprada por el cliente en el último año

El resultado debe estar ordenado en función de la cantidad máxima comprada por cliente
de mayor a menor    
*/ 


SELECT f.fact_cliente, 
(SELECT TOP 1 prod_detalle
FROM Item_Factura
JOIN Factura ON fact_numero+fact_tipo+fact_sucursal = item_numero+item_tipo+item_sucursal
JOIN Producto ON prod_codigo = item_producto
WHERE fact_cliente = f.fact_cliente
GROUP BY prod_detalle
ORDER BY SUM(item_cantidad) desc),

(SELECT SUM(item_cantidad)
FROM Item_Factura
JOIN Factura ON fact_numero+fact_tipo+fact_sucursal = item_numero+item_tipo+item_sucursal
WHERE fact_cliente = f.fact_cliente AND year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura))

FROM Factura f
JOIN Item_Factura ON f.fact_numero+f.fact_tipo+f.fact_sucursal = item_numero+item_tipo+item_sucursal
WHERE f.fact_cliente NOT IN (SELECT fact_cliente FROM Factura
                    WHERE year(fact_fecha) % 2 <> 0 )
GROUP BY f.fact_cliente
ORDER BY SUM(item_cantidad) desc

GO
----------
-- TSQL --
----------


/*
Implementar un sistema de auditoria para registrar cada operacion realizada en la tabla 
cliente. El sistema debera almacenar, como minimo, los valores(campos afectados), el tipo 
de operacion a realizar, y la fecha y hora de ejecucion. SOlo se permitiran operaciones individuales
(no masivas) sobre los registros, pero el intento de realizar operaciones masivas deberá ser registrado
en el sistema de auditoria
*/
CREATE TABLE AUDITORIA(
    audi_operacion char(100),
    audi_fecha datetime,
    audi_codigo char(6),
    audi_razon_social char(10),
    audi_telefono char(100),
    audi_domicilio char(100),
    audi_limite_credito decimal(12, 2),
    audi_vendedor numeric(6)
)
GO

CREATE TRIGGER auditoria ON Cliente FOR INSERT,UPDATE,DELETE
AS 
BEGIN
    DECLARE @operacion char(6)
    DECLARE @fecha datetime = GETDATE()
    IF EXISTS (SELECT * FROM Inserted)
    BEGIN
        -- Puede ser UPDATE o INSERT
        IF EXISTS (SELECT * FROM Deleted)
        BEGIN
        -- <-- UPDATE -->
            SET @operacion = 'UPDATE'
            INSERT INTO AUDITORIA(
            audi_operacion,
            audi_fecha,
            audi_codigo,
            audi_razon_social,
            audi_telefono, 
            audi_domicilio,
            audi_limite_credito, 
            audi_vendedor 
        ) SELECT @operacion, @fecha, clie_codigo, clie_razon_social, clie_telefono, clie_domicilio, clie_limite_credito, clie_vendedor FROM Inserted
            
            INSERT INTO AUDITORIA(
            audi_operacion,
            audi_fecha,
            audi_codigo,
            audi_razon_social,
            audi_telefono, 
            audi_domicilio,
            audi_limite_credito, 
            audi_vendedor 
        ) SELECT @operacion, @fecha, clie_codigo, clie_razon_social, clie_telefono, clie_domicilio, clie_limite_credito, clie_vendedor FROM deleted
        END
        
        -- <-- INSERT --> 
        SET @operacion = 'INSERT'
        INSERT INTO AUDITORIA(
            audi_operacion,
            audi_fecha,
            audi_codigo,
            audi_razon_social,
            audi_telefono, 
            audi_domicilio,
            audi_limite_credito, 
            audi_vendedor 
        ) SELECT @operacion, @fecha, clie_codigo, clie_razon_social, clie_telefono, clie_domicilio, clie_limite_credito, clie_vendedor FROM Inserted

    END
    ELSE
    BEGIN
        -- <-- DELETE -->
        SET @operacion = 'DELETE'
        INSERT INTO AUDITORIA(
            audi_operacion,
            audi_fecha,
            audi_codigo,
            audi_razon_social,
            audi_telefono, 
            audi_domicilio,
            audi_limite_credito, 
            audi_vendedor 
        ) SELECT @operacion, @fecha, clie_codigo, clie_razon_social, clie_telefono, clie_domicilio, clie_limite_credito, clie_vendedor FROM deleted
    END
END
