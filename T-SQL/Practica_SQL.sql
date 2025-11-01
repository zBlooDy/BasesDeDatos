use GD2015C1
-------------
-- PUNTO 1 --
-------------

/*
Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es
menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
% de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”.
*/
GO
CREATE FUNCTION deposito(@articulo char(8), @deposito char(2))
RETURNS char(50)

BEGIN
    DECLARE @stock numeric(12,2), @maximo numeric(12,2)
    

    RETURN 'HOLA'
END
GO

-------------
-- PUNTO 3 --
-------------

/*
Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. 
Se sabe que debería existir un único gerente general (debería ser el único empleado sin jefe). 
Si detecta que hay más de un empleado sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario. 
Si hay más de uno se seleccionara el de mayor antigüedad en la empresa. 
Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución.

<---- Tengo que hacer una variable OUTPUT ---->
*/


CREATE PROC gerenteGeneral (@emplSinJefe numeric(12,2) OUTPUT)
AS
    SELECT @emplSinJefe=COUNT(*) FROM Empleado WHERE empl_jefe is NULL
    IF (@emplSinJefe > 1)
        BEGIN
                DECLARE @gerenteGen numeric(6)
                SELECT TOP 1 @gerenteGen=empl_codigo FROM Empleado WHERE empl_jefe is NULL ORDER BY empl_salario desc, empl_ingreso asc
                UPDATE Empleado SET empl_jefe = @gerenteGen WHERE empl_jefe IS NULL and empl_codigo <> @gerenteGen
        END
GO

/*
--> Para ejecutarlo
BEGIN
    DECLARE @cantidad_emp INT
    EXEC dbo.gerenteGeneral @cantidad_emp OUTPUT
    SELECT @cantidad_emp
END
*/


-------------
-- PUNTO 4 --
-------------

/*
Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese
empleado a lo largo del último año. Se deberá retornar el código del vendedor
que más vendió (en monto) a lo largo del último año.
*/

CREATE PROC sumarComisiones (@codVendedor numeric(6) OUTPUT)
AS
    DECLARE @comisionTotal decimal(12,2)
    UPDATE Empleado
    SET empl_salario = empl_salario + ((SELECT SUM(fact_total) 
                                        FROM Factura 
                                        WHERE fact_vendedor = empl_codigo AND year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura)) * empl_comision)


    SELECT TOP 1 @codVendedor=fact_vendedor FROM Factura WHERE year(fact_fecha) = (SELECT MAX(year(fact_fecha)) FROM Factura)) * empl_comision) ORDER BY SUM(fact_total) desc

GO
-- foRMA LOGICA DE HACER EL TP ES MINIMIZAR LOS ACCESOS. Si lo hago 1x1, me fijo que es y donde lo meto

-- Hacer un INSERT de un SELECT, lo tengo que hacer en ORDEN (por la integridad referencial)
    

-------------
-- PUNTO 6 --
-------------

/*
Realizar un procedimiento que si en alguna factura se facturaron componentes
que conforman un combo determinado (o sea que juntos componen otro
producto de mayor nivel), en cuyo caso deberá reemplazar las filas 
correspondientes a dichos productos por una sola fila con el producto que
componen con la cantidad de dicho producto que corresponda.
*/


-------------
-- PUNTO 7 --
-------------

/*
7. Hacer un procedimiento que dadas dos fechas complete la tabla Ventas. 
Debe insertar una línea por cada artículo con los movimientos de stock generados por las ventas entre esas fechas. 
La tabla se encuentra creada y vacía. 
*/
CREATE PROCEDURE estadisticas_por_fechas @desde datetime, @hasta datetime
AS
BEGIN 
    DECLARE @nroRenglon int, @producto char(8), @detalle char(50), @precio_prom numeric (12,4), @cantidad numeric(12,2) 
    DECLARE c1 CURSOR FOR 
    SELECT prod_codigo, prod_detalle, SUM(item_cantidad), avg(item_precio), SUM(item_precio * item_cantidad) - sum(item_cantidad)*prod_precio 
    FROM Item_Factura
    JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
    JOIN Producto ON prod_codigo = item_producto
    WHERE fact_fecha >= @desde AND fact
END
GO
-------------
-- PUNTO 8 --
-------------

/*
Realizar un procedimiento que complete la tabla Diferencias de precios, 
para los productos facturados que tengan composición 
y en los cuales el precio de facturación sea diferente 
al precio del cálculo de los precios unitarios por cantidad de sus componentes, 
se aclara que un producto que compone a otro, también puede estar compuesto por otros y así sucesivamente, 
la tabla se debe crear y está formada por las siguientes columnas: */

CREATE PROCEDURE Diferencias 
AS
BEGIN
    SELECT DISTINCT p1.prod_codigo, prod_detalle, (SELECT COUNT(*) FROM Composicion where comp_producto = p1.prod_codigo),
    (SELECT SUM(comp_cantidad * prod_precio) FROM Composicion JOIN Producto ON comp_componente = prod_codigo AND comp_producto = p1.prod_codigo)
    FROM Item_Factura JOIN Producto p1 ON item_producto = p1.prod_codigo
    WHERE p1.prod_codigo IN (SELECT comp_producto FROM Composicion)
    AND item_precio <> (SELECT SUM(comp_cantidad * prod_precio) FROM Composicion JOIN Producto ON comp_componente = prod_codigo AND comp_producto = p1.prod_codigo)
END
GO

-------------
-- PUNTO 9 --
-------------

/*
Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
factura de un artículo con composición realice el movimiento de sus
correspondientes componentes.
*/

CREATE TRIGGER actualizarComposicion ON Item_Factura FOR UPDATE
AS
BEGIN
    DECLARE @componente char(8), @cantidad decimal(12,2)
    DECLARE cursorComponentes CURSOR FOR (SELECT comp_componente, (resta)*comp_cantidad FROM Composicion JOIN Inserted JOIN Deleted )        
END
go


-------------
-- PUNTO 10 --
-------------

/*
Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.
*/

CREATE TRIGGER verificarBajaArticulo ON Producto INSTEAD OF DELETE 
AS 
BEGIN
    DECLARE @producto char(8)
    SELECT @producto=p. prod_codigo FROM Producto p  JOIN Deleted d ON p.prod_codigo = d.prod_codigo
    
    -- Me fijo si existe algun producto de los que borra (puede ser 1 o varios) que tenga stock
    IF EXISTS(SELECT * FROM Stock JOIN Deleted ON stoc_producto = prod_codigo WHERE stoc_producto > 0 )
        BEGIN
            RAISERROR('El arituclo posee stock', 1, 1)
        END
    DELETE FROM Stock WHERE stoc_producto IN (SELECT prod_codigo from Deleted)
    DELETE FROM Composicion WHERE comp_producto IN (SELECT prod_codigo from Deleted)
    DELETE FROM Producto WHERE prod_codigo IN (SELECT prod_codigo from Deleted)
END
GO


--------------
-- PUNTO 11 --
--------------

/*
Cree el/los objetos de base de datos necesarios para que 
dado un código de empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o indirectamente). Solo contar aquellos empleados (directos o indirectos) 
que tengan un código mayor que su jefe directo. 
*/


CREATE FUNCTION cantidad_empleados (@jefe numeric(6))
RETURNS INT
AS 
BEGIN
    DECLARE @empleado numeric(6), @cantidad int
    DECLARE c1 CURSOR FOR SELECT empl_codigo FROM Empleado WHERE empl_jefe = @jefe
    open c1
    fetch c1 into @empleado
    SELECT @cantidad = 0
    WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @cantidad = @cantidad + 1 + dbo.cantidad_empleados(@empleado) -- Sumo 1 por el directo + los directos del empleado

            fetch c1 into @empleado
        END
    CLOSE c1
    DEALLOCATE c1

    RETURN @cantidad
END
GO


--------------
-- PUNTO 12 --
--------------

/*
Cree el/los objetos de base de datos necesarios para que nunca un producto 
pueda ser compuesto por sí mismo. 
Se sabe que en la actualidad dicha REGLA SE CUMPLE (no tengo que arreglar nada) 
y que la base de datos 
es accedida por n aplicaciones de diferentes tipos y tecnologías 
(puede venir un INSERT de un SELECT). 
No se conoce la cantidad de niveles de composición existentes (Tenes que buscar la comp directa o indirecta). 
*/



CREATE FUNCTION verificar_composicion(@producto char(8), @componente char(8)) 
RETURNS INT
AS
BEGIN
    IF(@componente = @producto)
        RETURN 1
    declare @comp char(8)
    DECLARE cursorComponentes CURSOR FOR SELECT comp_componente FROM Composicion WHERE comp_producto = @componente
    OPEN cursorComponentes
    FETCH cursorComponentes INTO @comp
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF(dbo.verificar_composicion(@producto, @comp) = 1)
           RETURN 1
        FETCH cursorComponentes INTO @comp
    END
    RETURN 0

   END
GO

CREATE TRIGGER evitar_misma_comp ON Composicion FOR INSERT
AS
BEGIN
    DECLARE @producto char(8), @componente char(8)
    IF EXISTS (SELECT * FROM Inserted WHERE dbo.verificarComposicion(comp_producto, comp_componente) = 1)
        ROLLBACK
END
GO


--------------
-- PUNTO 13 --
--------------

/*
Cree el/los objetos de base de datos necesarios para implantar la siguiente regla 
“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de sus empleados totales (directos + indirectos)”. 
Se sabe que en la actualidad dicha regla se cumple y que la base de datos 
es accedida por n aplicaciones de diferentes tipos y tecnologías 
*/



-- "La regla se cumple" --> No tengo  que cambiar nada 
CREATE TRIGGER verificar_salario_jefe ON Empleado FOR DELETE, UPDATE
AS
BEGIN
    IF (SELECT COUNT(*) FROM Inserted) = 0
        BEGIN
            IF EXISTS (SELECT * FROM Deleted d where (SELECT empl_salario FROM Empleado WHERE empl_codigo = d.empl_jefe) > dbo.suma_salarios(d.empl_jefe) * 0.2)
                ROLLBACK
        END
    ELSE
        BEGIN
            IF EXISTS (SELECT * FROM Inserted i where (SELECT empl_salario FROM Empleado WHERE empl_codigo = i.empl_jefe) > dbo.suma_salarios(i.empl_jefe) * 0.2)
                ROLLBACK
        END
END
GO



CREATE FUNCTION suma_salarios (@jefe numeric(6))
RETURNS numeric(12,2)
AS 
BEGIN
    DECLARE @empleado numeric(6), @salarios numeric(12,2)
    DECLARE c1 CURSOR FOR SELECT empl_codigo FROM Empleado WHERE empl_jefe = @jefe
    open c1
    fetch c1 into @empleado
    SELECT @salarios = 0
    WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @salarios = @salarios + (SELECT empl_salario FROM Empleado WHERE empl_codigo = @empleado) + dbo.suma_salarios(@empleado) 

            fetch c1 into @empleado
        END
    CLOSE c1
    DEALLOCATE c1

    RETURN @salarios
END
GO

--------------
-- PUNTO 14 --
--------------

/*
Agregar el/los objetos necesarios para que si un cliente compra un producto compuesto
a un precio menor  que la suma de los precios de sus componentes  
que imprima la  fecha, que cliente, que productos y a qué precio se realizó la compra. 

No se deberá permitir que dicho precio sea menor a la mitad de la suma de los componentes. 
*/

-- USO INSTEAD OF CUANDO TENGO QUE HACER PARA ALGUNOS CASOS 1 COSA Y PARA OTROS, OTRA COSA.
CREATE TRIGGER ej_t14 ON Item_Factura INSTEAD OF INSERT
AS
BEGIN
    DECLARE @tipo char(1), @sucursal char(4), @numero char(8), @cliente char(6), @fecha smalldatetime, @producto char(8), @precio numeric(12,4), @cantidad numeric(12,2)
    DECLARE c1 CURSOR FOR SELECT item_tipo, item_sucursal, item_numero, fact_cliente, fact_fecha, item_producto, item_precio, item_cantidad
    FROM Inserted  
    JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
    OPEN C1
    FETCH C1 INTO @tipo, @sucursal, @numero, @cliente, @fecha, @producto, @precio
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF(@precio > dbo.suma_precio_componentes(@producto)/ 2)
            BEGIN
                IF @precio < dbo.suma_precio_componentes(@producto)
                BEGIN
                    SELECT @fecha, @cliente, @producto, @precio
                    INSERT Item_Factura values (@tipo,@sucursal,@numero,@producto,@cantidad,@precio)
                END
            END
        ELSE
            INSERT Item_Factura values (@tipo,@sucursal,@numero,@producto,@cantidad,@precio)
        
    FETCH C1 INTO @tipo, @sucursal, @numero, @cliente, @fecha, @producto, @precio
    END
END
GO


CREATE FUNCTION suma_precio_componentes(@producto char(8)) 
RETURNS numeric(12,4)
AS
BEGIN
    
    declare @suma numeric(12,4)
    declare @comp char(8)
    DECLARE cursorComponentes CURSOR FOR SELECT comp_componente FROM Composicion WHERE comp_producto = @producto
    OPEN cursorComponentes
    FETCH cursorComponentes INTO @comp
    SELECT @suma = (SELECT isnull(SUM(comp_cantidad * prod_precio),0) FROM Composicion JOIN Producto ON comp_componente = prod_codigo WHERE comp_producto = @producto)
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @suma = @suma + dbo.suma_precio_componentes(@comp)
        FETCH cursorComponentes INTO @comp
    END
    CLOSE cursorComponentes
    DEALLOCATE cursorComponentes
    RETURN @suma

   END
GO

--------------
-- PUNTO 15 --
--------------

/*
Cree el/los objetos de base de datos necesarios para que el objeto principal
reciba un producto como parametro y retorne el precio del mismo.
Se debe prever que el precio de los productos compuestos sera la sumatoria de
los componentes del mismo multiplicado por sus respectivas cantidades. 

No se conocen los niveles de anidamiento posibles de los productos. Se asegura que
nunca un producto esta compuesto por si mismo a ningun nivel. El objeto
principal debe poder ser utilizado como filtro en el where de una sentencia
select.
*/

CREATE FUNCTION suma_precio(@producto char(8)) 
RETURNS numeric(12,4)
AS
BEGIN
    IF (SELECT COUNT(*) FROM Composicion WHERE comp_producto = @producto) > 0 
    BEGIN 
        declare @suma numeric(12,4)
        declare @comp char(8)
        DECLARE cursorComponentes CURSOR FOR SELECT comp_componente FROM Composicion WHERE comp_producto = @producto
        OPEN cursorComponentes
        FETCH cursorComponentes INTO @comp
        SELECT @suma = (SELECT isnull(SUM(comp_cantidad * prod_precio),0) FROM Composicion JOIN Producto ON comp_componente = prod_codigo WHERE comp_producto = @producto)
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @suma = @suma + dbo.suma_precio(@comp)
            FETCH cursorComponentes INTO @comp
        END
        CLOSE cursorComponentes
        DEALLOCATE cursorComponentes
    END
    ELSE
        SELECT @suma = prod_precio FROM Producto WHERE prod_codigo = @prod
    
return @suma
END
GO

--------------
-- PUNTO 16 --
--------------

/*
Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se descuenten del stock los articulos vendidos. Se descontaran
del deposito que mas producto poseea y se supone que el stock se almacena
tanto de productos simples como compuestos (si se acaba el stock de los
compuestos no se arman combos)
En caso que no alcance el stock de un deposito se descontara del siguiente y asi
hasta agotar los depositos posibles. En ultima instancia se dejara stock negativo
en el ultimo deposito que se desconto.
*/

CREATE TRIGGER actualizar_stock ON Item_Factura AFTER INSERT
AS
BEGIN
    DECLARE @prod char(8), @cantidad numeric(12,2) 
    DECLARE c1 CURSOR FOR SELECT item_producto, item_cantidad FROM inserted
    OPEN c1
    FETCH c1 INTO @prod, @cantidad
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC descontar_stock_depositos(@prod, @cantidad)

        FETCH c1 INTO @prod, @cantidad
    END
END
GO

CREATE PROCEDURE descontar_stock_depositos(@prod char(8), @cantidad numeric(12,2))
as
BEGIN
    DECLARE @depo char(2), @cantidad_depo numeric(12,2), @restante numeric(12,2) = @cantidad, @ultimoDeposito char(2)
    DECLARE cursorDepositos CURSOR FOR SELECT stoc_cantidad, stoc_deposito FROM Stock WHERE stoc_producto = @prod ORDER BY stoc_cantidad DESC
    OPEN cursorDepositos
    FETCH cursorDepositos INTO @cantidad_depo, @depo
    WHILE @@FETCH_STATUS = 0 AND @restante > 0
    BEGIN
        DECLARE @descuento decimal(12,2) = 
            CASE
            WHEN @cantidad_depo >= @restante THEN @restante
            ELSE @cantidad_depo
        END

        UPDATE STOCK
        SET stoc_cantidad = stoc_cantidad - @descuento WHERE stoc_producto = @prod AND stoc_deposito = @depo

        SET @restante = @restante - @descuento

        SET @ultimoDeposito = @depo

        FETCH cursorDepositos INTO @cantidad_depo, @depo


    END
    close cursorDepositos
    DEALLOCATE cursorDepositos

    IF(@restante > 0)
    BEGIN
        UPDATE STOCK
        SET stoc_cantidad = stoc_cantidad - @restante WHERE stoc_producto = @prod AND stoc_deposito = @ultimoDeposito
    END
END
go

/*
--------------
-- PUNTO 17 --
--------------

Sabiendo que el punto de reposicion del stock es la menor cantidad de ese objeto
que se debe almacenar en el deposito y que el stock maximo es la maxima
cantidad de ese producto en ese deposito, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio se cumpla automaticamente. No se
conoce la forma de acceso a los datos ni el procedimiento por el cual se
incrementa o descuenta stock
*/

CREATE TRIGGER verificar_stock ON STOCK after INSERT, UPDATE
AS
BEGIN
    IF (SELECT COUNT(*) FROM Inserted WHERE stoc_cantidad < stoc_punto_reposicion OR stoc_cantidad > stoc_stock_maximo) > 0
    BEGIN
        RAISERROR('No esta cumpliendo la regla de stock',1,1)
        ROLLBACK
    END

END
GO



--------------
-- PUNTO 18 --
--------------

/*
Sabiendo que el limite de credito de un cliente es el monto maximo que se le
puede facturar mensualmente, cree el/los objetos de base de datos necesarios
para que dicha regla de negocio se cumpla automaticamente. No se conoce la
forma de acceso a los datos ni el procedimiento por el cual se emiten las facturas
*/

GO
CREATE TRIGGER controlar_limite_cred ON Factura FOR INSERT
AS
BEGIN
    IF (SELECT COUNT(*) FROM Inserted i2 JOIN Cliente ON i2.fact_cliente = clie_codigo WHERE (SELECT SUM(fact_total) FROM Inserted WHERE fact_cliente = clie_codigo) + (SELECT SUM(fact_total) FROM Factura WHERE i2.fact_cliente = fact_cliente AND fact_fecha >= (SELECT MAX(fact_fecha) - 30)) > clie_limite_credito) > 0
     BEGIN
        RAISERROR('El cliente se excede del limite ',1,1)
        ROLLBACK
    END  
END
GO



--------------
-- PUNTO 19 --
--------------

/*
Cree el/los objetos de base de datos necesarios para que se cumpla la siguiente
regla de negocio automáticamente “Ningún jefe puede tener menos de 5 años de
antigüedad y tampoco puede tener más del 50% del personal a su cargo
(contando directos e indirectos) a excepción del gerente general”. Se sabe que en
la actualidad la regla se cumple y existe un único gerente general.
*/


-- Como tengo que controlar la regla, controlo TODOS LOS EMPLEADOS, no unicamente 
-- los de Inserted
CREATE TRIGGER controlar_jefes ON Empleado AFTER INSERT, UPDATE, DELETE
AS
BEGIN
      IF EXISTS (SELECT 1 FROM Empleado WHERE empl_codigo in (SELECT empl_jefe FROM Empleado) 
                AND (DATEDIFF(year, empl_ingreso, GETDATE()) > 5  OR
                dbo.cantidad_empleados(empl_codigo) > (SELECT COUNT(*)/2 FROM Empleado)))
        BEGIN
            ROLLBACK 
        END
END

go


CREATE FUNCTION cantidad_empleados (@jefe numeric(6))
RETURNS INT
AS 
BEGIN
    DECLARE @empleado numeric(6), @cantidad int
    DECLARE c1 CURSOR FOR SELECT empl_codigo FROM Empleado WHERE empl_jefe = @jefe
    open c1
    fetch c1 into @empleado
    SELECT @cantidad = 0
    WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @cantidad = @cantidad + 1 + dbo.cantidad_empleados(@empleado) -- Sumo 1 por el directo + los directos del empleado

            fetch c1 into @empleado
        END
    CLOSE c1
    DEALLOCATE c1

    RETURN @cantidad
END
GO


--------------
-- PUNTO 20 --
--------------

/*
Crear el/los objeto/s necesarios para mantener actualizadas las comisiones del
vendedor.
El cálculo de la comisión está dado por el 5% de la venta total efectuada por ese
vendedor en ese mes, más un 3% adicional en caso de que ese vendedor haya
vendido por lo menos 50 productos distintos en el mes.
*/

create trigger ej_t20 on factura for insert
AS
begin
    update empleado set empl_comision = (select sum(fact_total) + (select sum(fact_total) from factura 
                where clie_codigo = fact_cliente and year(fact_fecha) = year(i2.fact_fecha) 
                and month(fact_fecha) = month(i2.fact_fecha))
                from inserted where empl_codigo = fact_vendedor) * 0.05
    where empl_codigo IN (select distinct 
end
go

--------------
-- PUNTO 21 --
--------------

