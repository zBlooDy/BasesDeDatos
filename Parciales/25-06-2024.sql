---------
-- SQL --
---------

/* Dada la crisis que atraviesa la empresa, el directorio solicia un informe especial para poder analizar y definir
la nueva estrategia a adoptar
Este informe consta de un listado de aquellos productos cuyas ventas de lo que va del año 2012 fueron superiores
al 15% del promedio de ventas de los productos vendidos entre los años 2010 y 2011
En base a lo solicitado, armar una consulta SQL que retorne la siguiente informacion:
    1) Detalle producto 
    2) Mostrar la leyenda "Popular" si dicho producto figura en más de 100 facturas realizadas en el 2012. Caso 
        contrario, mostrar la leyenda "SIN INTERES"
    3) Cantidad de facturas en las que aparece el producto en el año 2012
    4) Codigo del cliente que más compro dicho producto en el año 2012 (en caso de existi más de un cliente
     mostrar solamente el de menor codigo)

*/


SELECT prod_detalle, 
CASE WHEN COUNT(distinct fact_numero) > 100
THEN 'Popular'
ELSE 'SIN INTERES'
END,
COUNT(distinct fact_numero) '# Facturas en 2012',
(SELECT TOP 1 fact_cliente
FROM Factura
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE item_producto = prod_codigo AND year(fact_fecha) = 2012
GROUP BY fact_cliente
ORDER BY SUM(item_cantidad) desc, fact_cliente asc) 'Cliente que mas compro'

FROM Factura
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
JOIN Producto ON prod_codigo = item_producto
WHERE year(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
HAVING SUM(item_cantidad * item_precio) > 0.15 * (SELECT AVG(fact_total)
                                                  FROM Factura
                                                  WHERE year(fact_fecha) = 2010 OR year(fact_fecha) = 2011)


GO
----------
-- TSQL --
----------
/*
Realizar el o los objetos de base de datos necesarios para que dado un codigo de producto y una fecha devuelva
la mayor cantidad de dias consecutivos a partir de esa fecha que el producto tuvo al menos la venta de una unidad en el dia, 
el sistema de ventas on line esta habilitado 24-7 por lo que se deben evaluar tidos los dias incluyendo domingos y feriados
*/


CREATE FUNCTION calcular_racha(@prod char(8), @fecha smalldatetime)
RETURNS INT
AS
BEGIN
    DECLARE @racha INT, @acumulador INT = 0, @proximaFecha smalldatetime
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
-- Otra version de quique:

create procedure ej2 @producto char(8),  @fecha date, @max int output
as
declare @cont int, @fecha_actual date, @fecha_proxima date
select @max = 0
select @cont = 0
declare c1 cursor for   select fact_fecha from Factura join Item_Factura on item_tipo + item_sucursal + item_numero = fact_tipo + fact_sucursal + fact_numero
where item_producto = @producto and fact_fecha > @fecha 
group by fact_fecha order by fact_fecha --agrego este group by por si tengo varias ventas de ese producto en el dia
open c1
fetch c1 into @fecha_actual
while @@FETCH_STATUS = 0
BEGIN
    select @fecha = @fecha_actual
    select @cont = 0
    while @@FETCH_STATUS = 0 and @fecha + 1 = @fecha_actual
    BEGIN
        select @cont = @cont +1
        fetch c1 into @fecha_actual
    END 

    if(@cont>@max)
        select @max = @cont
    if @cont = 0
        fetch c1 into @fecha_actual
END
close c1
deallocate c1
go