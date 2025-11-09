---------
-- SQL --
---------


/* 1. Diseñar una consulta SQL que identificque a los vendedores cuya suma de ventas durantes los ultimos dos meses
consecuetivos ha sido inferior a la suma de ventas en los mismos dos meses consecutivos de la años anterior

    - el numero de fila
    - el nombre del vendedor
    - la cantidad de empleados a cargo de cada vendedor
    - la cantidad de clientes a los que vendio en total

El resultado debe estar ordenado en forma descendente segun el monto total de ventas 
del vendedor (de mayor a menor)
*/

-- Habia interpretado que era con respecto a lo ultimo q vendio el cliente y no lo ultimo en general (osea usar max fact_fecha).
-- Igual la otra forma creo que era mas complicada en funcion de que era las subqueries eran mucho mas dinamicas

SELECT empl_nombre, 
(SELECT COUNT(*) FROM Empleado WHERE empl_jefe = e.empl_codigo),
COUNT(distinct fact_cliente)
FROM Empleado e
JOIN Factura ON fact_vendedor = empl_codigo
WHERE (SELECT SUM(fact_total)
        FROM Factura
        WHERE fact_vendedor = empl_codigo
        AND month(fact_fecha) >= month((SELECT TOP 1 fact_fecha
                                           FROM Factura
                                           WHERE year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura)
                                           )) - 1
        AND year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura))
        <
        (SELECT SUM(fact_total)
        FROM Factura
        WHERE fact_vendedor = empl_codigo
        AND month(fact_fecha) >= month((SELECT TOP 1 fact_fecha
                                           FROM Factura
                                           WHERE year(fact_fecha) = (SELECT MAX(year(fact_fecha)-1) FROM Factura)
                                           )) - 1
        AND year(fact_fecha) = (SELECT MAX(year(fact_fecha)-1) FROM Factura))
GROUP BY empl_codigo, empl_nombre
ORDER BY SUM(fact_total) desc
GO


----------
-- TSQL --
----------


/* 2. Se requiere diseñar e implemetar los objetos necesarios para crear una regla que detecte inconsistencias en
las ventas en linea. 
En caso de detectar una incosistencia, deberá registrarse el detalle correspondiente en una estructura
adicional. POr el contrario, si no se encuentra ninguna incosistencia, se deberá registrar que la factura ha sido validada

Inconsistencias a considerar:
    1. Que el valor de fact_total no coincida con la suma de los precios multiplicados por la cantidades que los articulos
    2. Que se genere una factura con una fecha anterior al día actual
    3. Que se intente eliminar algun registro de una venta
*/

CREATE TABLE INCONSISTENCIAS (
    inco_detalle char(50),
    inco_factura char(13)
)
GO

-- Version con CURSOR
CREATE TRIGGER verificar_suma_total ON Item_Factura FOR INSERT
AS
BEGIN
    DECLARE @factura char(13)
    DECLARE cursorFacturas CURSOR FOR SELECT item_tipo+item_sucursal+item_numero FROM Inserted GROUP BY item_tipo+item_sucursal+item_numero
    OPEN cursorFacturas
    FETCH cursorFacturas INTO @factura
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF EXISTS (SELECT *
                   FROM Item_Factura
                   JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
                   WHERE item_tipo+item_sucursal+item_numero = @factura
                   GROUP BY item_tipo+item_sucursal+item_numero, fact_total
                   HAVING SUM(item_cantidad * item_precio) > fact_total)
        INSERT INTO INCONSISTENCIAS VALUES ('NO COINCIDE FACT_TOTAL', @factura)
        ELSE
            INSERT INTO INCONSISTENCIAS VALUES ('VALIDADA', @factura)

        FETCH cursorItems INTO @factura
    END

END
GO

-- Version sin CURSOR

CREATE TRIGGER verificar_dia_factura ON Factura FOR INSERT
AS
BEGIN
    INSERT INTO INCONSISTENCIAS(inco_detalle, inco_factura) 
    SELECT 'DIA ERRONEO', fact_tipo+fact_sucursal+fact_numero
    FROM Inserted
    WHERE fact_fecha < GETDATE()

    INSERT INTO INCONSISTENCIAS(inco_detalle, inco_factura) 
    SELECT 'VALIDADA', fact_tipo+fact_sucursal+fact_numero
    FROM Inserted
    WHERE fact_fecha = GETDATE()

END
GO


CREATE TRIGGER verificar_eliminar_registro ON Item_Factura FOR DELETE
AS
BEGIN
    INSERT INTO INCONSISTENCIAS(inco_detalle, inco_factura) 
    SELECT 'INTENTO DE ELIMINACION', item_tipo+item_sucursal+item_numero
    FROM Deleted



END



