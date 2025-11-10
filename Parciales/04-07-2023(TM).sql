---------
-- SQL --
---------

/*
0. Realizar una consulta SQL que retorne para los 10 clientes que más compraron en el 2012 y 
que fueron atendidos por más de 3 vendedores distintos:
1. Apellido y Nombre del Cliente. !
2. Cantidad de Productos distintos comprados en el 2012. !
3. Cantidad de unidades compradas dentro del primer semestre del 2012. !

4a. El resultado deberá mostrar ordenado la cantidad de ventas descendente del 2012 de cada cliente, 
4b.	en caso de igualdad de ventas, ordenar por código de cliente.
*/

SELECT TOP 10 clie_razon_social, COUNT(distinct item_producto), (SELECT SUM(item_cantidad)
																FROM Factura
																JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
																WHERE fact_cliente = clie_codigo AND month(fact_fecha) >= 1 AND month(fact_fecha) <= 6)
FROM Cliente
JOIN Factura ON fact_cliente = clie_codigo
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE year(fact_fecha) = 2012
GROUP BY clie_codigo, clie_razon_social
HAVING COUNT(distinct fact_vendedor) > 3
ORDER BY SUM(item_cantidad * item_precio) DESC, clie_codigo
GO


----------
-- TSQL --
----------

/*
Realizar un stored procedure que reciba un código de producto y una
	fecha y devuelva la mayor cantidad de días consecutivos a partir de esa
	fecha que el producto tuvo al menos la venta de una unidad en el día, el
	sistema de ventas on line está habilitado 24-7 por lo que se deben evaluar
	todos los días incluyendo domingos y feriados.
*/

CREATE PROCEDURE calcular_racha(@prod char(8), @fecha smalldatetime, @racha INT OUTPUT)
AS
BEGIN
    DECLARE @acumulador INT = 0, @proximaFecha smalldatetime
    SET @racha = @acumulador

    DECLARE cursorFechas CURSOR FOR SELECT fact_fecha FROM Factura 
    JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
    WHERE fact_fecha > @fecha AND item_producto = @prod
    GROUP BY fact_fecha
    ORDER BY fact_fecha asc

    OPEN cursorFechas
    FETCH cursorFechas INTO @proximaFecha
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (DATEDIFF(day, @fecha, @proximaFecha) = 1)
            SET @acumulador = @acumulador + 1
        ELSE
        BEGIN
            IF (@acumulador > @racha)
            BEGIN
                SET @racha = @acumulador
                SET @acumulador = 0
            END
        END

        SET @fecha = @proximaFecha

        
        FETCH cursorFechas INTO @proximaFecha

    END

    IF (@acumulador > @racha)
        SET @racha = @acumulador

    CLOSE cursorFechas
    DEALLOCATE cursorFechas

    RETURN @racha
END
GO