/* 1.	Mostrar dos filas con los 2  empleados del mes: Estos son:

a)	El empleado que en el último año que haya ventas (en el cual se ejecuta la query) vendió 
más en dinero (fact_total)
b)	El segundo empleado del año, es aquel que en el mismo año (en el cual se ejecuta la query)
 tiene más facturas emitidas

Se deberá mostrar Apellido y nombre del empleado en una sola columna y para el primero
 un string que diga 
(Mejor Facturación y para el Segundo Vendió Más Facturas).

No se permiten sub select en el FROM.*/

SELECT TOP 1 CONCAT(empl_nombre, empl_apellido), 'Mejor Facturacion'
FROM Factura
JOIN Empleado ON fact_vendedor = empl_codigo
WHERE empl_codigo = (SELECT TOP 1 fact_vendedor
                        FROM Factura 
                        WHERE year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura)
                        GROUP BY fact_vendedor
                        ORDER BY SUM(fact_total) desc)
UNION
SELECT TOP 1 CONCAT(empl_nombre, empl_apellido), 'Vendio mas Facturas'
FROM Factura
JOIN Empleado ON fact_vendedor = empl_codigo
WHERE empl_codigo = (SELECT TOP 1 fact_vendedor
                        FROM Factura 
                        WHERE year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura)
                        GROUP BY fact_vendedor
                        ORDER BY COUNT(fact_numero) desc)
GO

/* 2.	Realizar un stored procedure que reciba un código de producto y una fecha y devuelva
 la mayor cantidad de días 
consecutivos a partir de esa fecha que el producto tuvo al menos la venta de una unidad en el día,
el sistema de ventas on line está habilitado 24-7 por lo que se deben evaluar 
todos los días incluyendo domingos y feriados
*/



CREATE PROCEDURE racha_vendidos_2 (@prod char(8), @fecha datetime, @racha int OUTPUT)
AS
BEGIN
    DECLARE cursorFechas CURSOR FOR SELECT fact_fecha FROM Factura JOIN Item_Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal 
                         WHERE item_producto = @prod and fact_fecha > @fecha
    DECLARE @fechaSiguiente DATETIME, @ultimoDia DATETIME
    DECLARE @acumulador INT
    DECLARE @rachaAcumulada INT 
    SET @acumulador = 0
    SET @rachaAcumulada = @acumulador
    OPEN cursorFechas
    FETCH cursorFechas INTO @fechaSiguiente
    WHILE @@FETCH_STATUS = 0 
    BEGIN
        SELECT @fecha = @fechaSiguiente
        SET @acumulador = 0
        WHILE @@FETCH_STATUS = 0 AND @fecha + 1 = @fechaSiguiente
        BEGIN
            SELECT @acumulador = @acumulador + 1
            FETCH cursorFechas INTO @fechaSiguiente
        END
        IF(@acumulador > @rachaAcumulada)
            SET @rachaAcumulada = @acumulador
        IF @acumulador = 0
            FETCH cursorFechas INTO @fechaSiguiente    
    END
    CLOSE cursorFechas
    DEALLOCATE cursorFechas
END
GO

-- Esta version es menos eficiente me parece, por los cursores
CREATE PROCEDURE racha_vendidos (@prod char(8), @fecha datetime, @racha int OUTPUT)
AS
BEGIN
    SET @racha = dbo.calcular_racha(@prod, @fecha, 0)
    RETURN @racha
END
GO

CREATE FUNCTION calcular_racha (@prod char(8), @fecha datetime, @rachaActual INT) 
RETURNS INT
AS
BEGIN
    DECLARE cursorFechas CURSOR FOR SELECT fact_fecha FROM Factura JOIN Item_Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal 
                         WHERE item_producto = @prod and fact_fecha > @fecha GROUP BY fact_fecha ORDER BY fact_fecha
    DECLARE @fechaSiguiente DATETIME
    DECLARE @rachaProxima INT

    OPEN cursorFechas
    FETCH cursorFechas INTO @fechaSiguiente
    WHILE @@FETCH_STATUS = 0 
    BEGIN
        IF(DATEDIFF(day, @fecha, @fechaSiguiente) = 1)
            SET @rachaActual = @rachaActual + 1
        ELSE 
            BEGIN
                SET @rachaProxima = dbo.calcular_racha(@prod, @fechaSiguiente, @rachaActual)
                BREAK
            END
        SET @fecha = @fechaSiguiente
        FETCH cursorFechas INTO @fechaSiguiente
    END
    CLOSE cursorFechas
    DEALLOCATE cursorFechas

    IF (@rachaActual >= @rachaProxima)
        RETURN @rachaActual
    
    RETURN @rachaProxima
END
GO

