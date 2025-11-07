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

GO
CREATE TRIGGER verificar_stock_producto ON Producto INSTEAD OF DELETE
AS
BEGIN

	IF (SELECT COUNT(*) FROM Deleted d JOIN Stock ON d.prod_codigo = stoc_producto WHERE stoc_cantidad > 0) > 0
		BEGIN
			RAISERROR('El producto tiene stock, no se puede borrar',1,1)
		END

	DELETE FROM Stock WHERE stoc_producto IN (SELECT prod_codigo FROM Deleted)
	DELETE FROM Item_Factura WHERE item_producto IN (SELECT prod_codigo FROM Deleted)
	DELETE FROM Composicion WHERE comp_producto IN (SELECT prod_codigo FROM Deleted) OR comp_componente IN (SELECT prod_codigo FROM Deleted)
	DELETE FROM Producto WHERE prod_codigo IN (SELECT prod_codigo FROM Deleted)

END

GO

--------------
-- PUNTO 11 --
--------------

/*
Cree el/los objetos de base de datos necesarios para que 
dado un código de empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o indirectamente). 
Solo contar aquellos empleados (directos o indirectos) que tengan un código mayor que su jefe directo. 
*/
GO

CREATE FUNCTION contar_empleados (@jefe numeric(8)) 
RETURNS INT
AS
BEGIN
	DECLARE @acumulador int, @empleado numeric(6)
	SET @acumulador = 0
	DECLARE cursorEmpleados CURSOR FOR (SELECT empl_codigo FROM Empleado WHERE empl_jefe = @jefe AND empl_codigo > @jefe)
	OPEN cursorEmpleados
	FETCH cursorEmpleados INTO @empleado
	-- Si no tiene empleados, no entra al cursor y devuelve acumulador (esta en 0)
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @acumulador = @acumulador + 1 + dbo.contar_empleados(@empleado)
		FETCH cursorEmpleados INTO @empleado
	END
	CLOSE cursorEmpleados
	DEALLOCATE cursorEmpleados
	RETURN @acumulador

END

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

GO
CREATE TRIGGER verificar_comp_propia ON Composicion FOR INSERT
AS
BEGIN
	IF(SELECT COUNT(*) FROM Inserted WHERE dbo.verificar_comp(comp_producto, comp_componente) = 1) > 0
		ROLLBACK TRANSACTION
END
GO

CREATE FUNCTION verificar_comp (@producto char(8), @componente char(8))
RETURNS INT
AS
BEGIN
	DECLARE @compuesto INT
	IF(@producto = @componente)
		SET @compuesto = 1
	ELSE
		BEGIN
			DECLARE @comp char(8)
			DECLARE cursorComponentes CURSOR FOR (SELECT comp_componente FROM Composicion WHERE comp_producto = @componente)
			OPEN cursorComponentes
			FETCH cursorComponentes INTO @comp
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @compuesto = dbo.verificar_comp(@producto, @comp)
				FETCH cursorComponentes INTO @comp
			END
			CLOSE cursorComponentes
			DEALLOCATE cursorComponentes
		END

	RETURN @compuesto
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

-- Si agrego un empleado a un jefe, el salario va a seguir siendo menor 
-- Si actualizo un salario o saco a un empleado, puede ser que se modifique la regla

CREATE TRIGGER verificar_sal_jefe ON Empleado FOR UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM deleted)
        BEGIN
            IF EXISTS (SELECT * FROM Deleted d JOIN Empleado e ON d.empl_jefe = e.empl_codigo WHERE e.empl_salario > 0.2 * dbo.salarios_emp(e.empl_codigo))
            ROLLBACK TRANSACTION
        END
    IF EXISTS (SELECT * FROM inserted)
        BEGIN
            IF EXISTS (SELECT * FROM Inserted i JOIN Empleado e ON i.empl_jefe = e.empl_codigo WHERE e.empl_salario > 0.2 * dbo.salarios_emp(e.empl_codigo))
            ROLLBACK TRANSACTION
        END
END
GO

CREATE FUNCTION salarios_emp (@jefe char(6)) 
RETURNS INT
AS
BEGIN
	DECLARE @acumulador int, @empleado numeric(6), @salario numeric(12,2)
	SET @acumulador = 0
	DECLARE cursorEmpleados CURSOR FOR (SELECT empl_codigo, empl_salario FROM Empleado WHERE empl_jefe = @jefe)
	OPEN cursorEmpleados
	FETCH cursorEmpleados INTO @empleado, @salario
	-- Si no tiene empleados, no entra al cursor y devuelve acumulador (esta en 0)
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @acumulador = @acumulador + @salario + dbo.salarios_emp(@empleado)
		FETCH cursorEmpleados INTO @empleado
	END
	CLOSE cursorEmpleados
	DEALLOCATE cursorEmpleados
	RETURN @acumulador

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


CREATE TRIGGER compra_prod_comp ON Item_Factura INSTEAD OF INSERT
AS
BEGIN
    DECLARE @tipo char(1), @sucursal char(4), @numero char(8), @cliente char(6), @fecha smalldatetime, @producto char(8), @precio numeric(12,4), @cantidad numeric(12,2)
    DECLARE c1 CURSOR FOR SELECT item_tipo, item_sucursal, item_numero, fact_cliente, fact_fecha, item_producto, item_precio, item_cantidad
    FROM Inserted 
    JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
    OPEN c1
    FETCH c1 INTO @tipo, @sucursal, @numero, @cliente, @fecha, @producto, @precio
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (@precio > dbo.suma_componentes(@producto) / 2)
            BEGIN
                IF (@precio < dbo.suma_componentes(@producto))
                    BEGIN
                        -- Imprimo lo que me pide y lo inserto
                        SELECT @fecha, @cliente, @producto, @precio
                        INSERT Item_Factura VALUES (@tipo, @sucursal, @numero, @cliente, @fecha, @producto, @precio) 
                    END
                ELSE
                INSERT Item_Factura VALUES (@tipo, @sucursal, @numero, @cliente, @fecha, @producto, @precio) -- Si no es menor, tengo que insertarlo ya que el enunciado no aclara que tengo q hacer
            END     
     FETCH c1 INTO @tipo, @sucursal, @numero, @cliente, @fecha, @producto, @precio
     END
     CLOSE c1
     DEALLOCATE c1

END
GO

CREATE FUNCTION suma_componentes (@producto char(8))
RETURNS numeric(12,4)
AS
BEGIN
	DECLARE @suma numeric(12,4), @comp char(8)
    select @suma = (select isnull(sum(comp_cantidad*prod_precio),0) from composicion join producto on comp_componente = prod_codigo
                            where comp_producto = @producto)
    DECLARE cursorComponentes CURSOR FOR (SELECT comp_componente, prod_precio FROM Composicion JOIN Producto ON comp_componente = prod_codigo WHERE comp_producto = @producto )
    OPEN cursorComponentes
    FETCH cursorComponentes INTO @salario, @comp
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @suma = @suma + dbo.suma_componentes(@comp)
        FETCH cursorComponentes INTO @salario, @comp
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
        SELECT @suma = prod_precio FROM Producto WHERE prod_codigo = @producto
    
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


CREATE TRIGGER actualizar_stock_venta ON Item_Factura FOR INSERT
AS
BEGIN
    DECLARE @prod char(8), @cantidad decimal(12,2)
    DECLARE c1 CURSOR FOR (SELECT item_producto, item_cantidad FROM Inserted)
    OPEN c1
    FETCH c1 INTO @prod, @cantidad
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC descontar_stock_depos(@prod, @cantidad)
        FETCH c1 INTO @prod, @cantidad
    END
    CLOSE c1
    DEALLOCATE c1
END
GO

CREATE PROCEDURE descontar_stock_depos(@prod char(8), @cantidad numeric(12,2))
as
BEGIN
    DECLARE @depo char(2), @cantidad_depo numeric(12,2), @restante numeric(12,2), @ultimoDeposito char(2)
    DECLARE cursorDepositos CURSOR FOR SELECT stoc_cantidad, stoc_deposito FROM Stock WHERE stoc_producto = @prod ORDER BY stoc_cantidad DESC
    SET @restante = @cantidad
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

/*
Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que en una factura no puede contener productos de
diferentes familias. En caso de que esto ocurra no debe grabarse esa factura y
debe emitirse un error en pantalla.
*/

CREATE TRIGGER verificar_familia ON Factura FOR INSERT
AS
BEGIN
    DECLARE @tipo char(1), @sucursal char(4), @numero char(8)
    DECLARE cursorFacturas CURSOR FOR SELECT fact_tipo, fact_numero, fact_sucursal FROM Inserted
    OPEN cursorFacturas
    FETCH cursorFacturas INTO @tipo, @sucursal,@numero
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (SELECT COUNT(*) 
            FROM Item_Factura
            JOIN Producto ON item_producto = prod_codigo
            WHERE item_tipo+item_sucursal+item_numero = @tipo+@sucursal+@numero
            GROUP BY prod_familia) > 1
        BEGIN
           -- Tengo que borrar todos los items y despues la factura, esta es otra opcion para ver los que cumplen la condicion
           delete from item_factura where item_tipo + item_sucursal + item_numero in (
            select item_tipo + item_sucursal + item_numero
			from inserted
				join producto on item_producto = prod_codigo
			group by item_tipo + item_sucursal + item_numero
			having count(distinct prod_familia) > 1
		    )
            ROLLBACK -- Aca tiro toda la transaccion para atras
            RAISERROR('La factura tiene items de distintas familias',1,1)
        END

        FETCH cursorFacturas INTO @tipo, @sucursal,@numero

    END
    CLOSE cursorFacturas
    DEALLOCATE cursorFacturas
END
GO

--------------
-- PUNTO 22 --
--------------

/*
Se requiere recategorizar los rubros de productos, de forma tal que nigun rubro
tenga más de 20 productos asignados, si un rubro tiene más de 20 productos
asignados se deberan distribuir en otros rubros que no tengan mas de 20
productos y si no entran se debra crear un nuevo rubro en la misma familia con
la descirpción “RUBRO REASIGNADO”, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio quede implementada
*/

-- Lo que interpreto es que RUBRO REASIGNADO no tiene limite de productos, pero tiene que ser tu ultima opcion
CREATE PROCEDURE recategorizar_rubros 
AS
BEGIN
    DECLARE cursorRubros CURSOR FOR SELECT rubr_id, COUNT(prod_codigo) FROM Rubro JOIN Producto ON prod_rubro = rubr_id GROUP BY rubr_id
    DECLARE @rubro char(4), @cantidad INT
    FETCH cursorRubros INTO @rubro, @cantidad
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @cantidad > 20 
        BEGIN
            EXEC reasignar_productos_rubro(@rubro, @cantidad)
        END



        FETCH cursorRubros INTO @rubro, @cantidad

    END
END
GO


CREATE PROCEDURE reasignar_productos_rubro (@rubro char(4), @cantidadRubro INT)
AS
BEGIN
    DECLARE cursorProductos CURSOR FOR SELECT prod_codigo FROM Producto WHERE prod_rubro = @rubro
    DECLARE @prod char(8), @nuevoRubro char(4), @idRubroReasignado char(4)
    FETCH cursorProductos INTO @prod
    WHILE @@FETCH_STATUS = 0 OR @cantidadRubro > 20
    BEGIN
        SELECT TOP 1 @nuevoRubro=rubr_id FROM Rubro JOIN Producto ON prod_rubro = rubr_id WHERE rubr_detalle <> 'RUBRO REASIGNADO'GROUP BY rubr_id HAVING COUNT(*) < 20 ORDER BY COUNT(*) asc
        IF @nuevoRubro IS NOT NULL
        BEGIN
            UPDATE Producto SET prod_rubro = @nuevoRubro WHERE prod_codigo = @prod
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT * FROM Rubro WHERE rubr_detalle = 'RUBRO REASIGNADO')
            BEGIN
                INSERT INTO Rubro (rubr_detalle) VALUES ('RUBRO REASIGNADO') 
            END
            SELECT @idRubroReasignado=rubr_id FROM Rubro WHERE rubr_detalle = 'RUBRO REASIGNADO'
            UPDATE Producto SET prod_rubro = @idRubroReasignado WHERE prod_codigo = @prod
        END
        
        SET @cantidadRubro -= 1
        FETCH cursorProductos INTO @prod
    END
END
GO


--------------
-- PUNTO 23 --
--------------

/*
Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se controle que en una misma factura no puedan venderse más
de dos productos con composición. Si esto ocurre debera rechazarse la factura.
*/

-- Es lo mismo que el ejercicio 21 pero hecho de otra forma, en vez de utilizar cursores lo hago directo con el IF EXISTS
CREATE TRIGGER verificar_factura_compuesta ON Factura FOR INSERT
AS
BEGIN
    -- Me fijo si existe una factura que tenga mas de 2 items compuestos
    IF EXISTS (SELECT fact_tipo+fact_numero+fact_sucursal FROM Inserted 
    JOIN Item_Factura ON item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
    JOIN Producto ON item_producto = prod_codigo
    WHERE prod_codigo IN (SELECT comp_producto FROM Composicion)
    GROUP BY item_tipo+item_numero+item_sucursal
    HAVING COUNT(distinct prod_codigo) > 2)

    BEGIN
        DELETE FROM Item_Factura WHERE item_tipo+item_numero+item_sucursal IN (SELECT item_tipo+item_numero+item_sucursal FROM Item_Factura
                                                   JOIN Producto ON item_producto = prod_codigo
                                                   WHERE prod_codigo IN (SELECT comp_producto FROM Composicion)
                                                   GROUP BY item_tipo+item_numero+item_sucursal
                                                   HAVING COUNT(distinct prod_codigo) > 2)
        
        DELETE FROM Factura WHERE fact_tipo+fact_numero+fact_sucursal IN (SELECT item_tipo+item_numero+item_sucursal FROM Item_Factura
                                                   JOIN Producto ON item_producto = prod_codigo
                                                   WHERE prod_codigo IN (SELECT comp_producto FROM Composicion)
                                                   GROUP BY item_tipo+item_numero+item_sucursal
                                                   HAVING COUNT(distinct prod_codigo) > 2) 

    END
END
GO


--------------
-- PUNTO 24 --
--------------

/*
Se requiere recategorizar los encargados asignados a los depositos. Para ello
cree el o los objetos de bases de datos necesarios que lo resueva, teniendo en
cuenta que un deposito no puede tener como encargado un empleado que
pertenezca a un departamento que no sea de la misma zona que el deposito, 

Si esto ocurre a dicho deposito debera asignársele el empleado con menos
depositos asignados que pertenezca a un departamento de esa zona.
*/

CREATE PROCEDURE recategorizar_empleados 
AS
BEGIN
    DECLARE cursorDepositos CURSOR FOR SELECT depo_codigo, depo_zona FROM Empleado 
    JOIN Deposito ON empl_codigo = depo_encargado
    JOIN Departamento ON empl_departamento = depa_codigo
    WHERE depa_zona <> depo_zona

    DECLARE @deposito char(6), @zona char(3)
    DECLARE @nuevoEncargado char(6)
    OPEN cursorDepositos
    FETCH cursorDepositos INTO @deposito, @zona
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT TOP 1 @nuevoEncargado=empl_codigo FROM Empleado
        JOIN Deposito ON empl_codigo = depo_encargado
        JOIN Departamento ON empl_departamento = depa_codigo 
        WHERE depa_zona = @zona
        GROUP BY empl_codigo
        ORDER BY COUNT(distinct depo_codigo) asc


        UPDATE Deposito SET depo_encargado = @nuevoEncargado WHERE depo_codigo = @deposito
        
        
        FETCH cursorDepositos INTO @deposito

    END
    CLOSE cursorDepositos
    DEALLOCATE cursorDepositos
END
GO

--------------
-- PUNTO 25 --
--------------

/*
Desarrolle el/los elementos de base de datos necesarios para que no se permita
que la composición de los productos sea recursiva, o sea, que si el producto A
compone al producto B, dicho producto B no pueda ser compuesto por el
producto A, hoy la regla se cumple.
*/

CREATE TRIGGER verificar_comp ON Composicion FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted i WHERE dbo.verificar_comp_recursiva(i.comp_producto) = 1)
        ROLLBACK
END
GO

CREATE FUNCTION verificar_comp_recursiva (@producto char(8))
RETURNS INT
AS
BEGIN
    DECLARE cursorComponentes CURSOR FOR SELECT comp_componente FROM Composicion WHERE comp_producto = @producto
    DECLARE @componente char(8)
    DECLARE @recursivo INT = 0
    OPEN cursorComponentes
    FETCH cursorComponentes INTO @componente
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF EXISTS (SELECT * FROM Composicion WHERE @componente = comp_producto AND comp_componente = @producto)
            SET @recursivo = 1
        
        FETCH cursorComponentes INTO @componente
    END
    CLOSE cursorComponentes
    DEALLOCATE cursorComponentes
    RETURN @recursivo
END
GO
--------------
-- PUNTO 26 --
--------------

/*
Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de otros productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.
*/



--------------
-- PUNTO 27 --
--------------

/*
Se requiere reasignar los encargados de stock de los diferentes depósitos. Para
ello se solicita que realice el o los objetos de base de datos necesarios para
asignar a cada uno de los depósitos el encargado que le corresponda,

Entendiendo que el encargado que le corresponde es cualquier empleado que no
es jefe y que no es vendedor, o sea, que no está asignado a ningun cliente, se
deberán ir asignando tratando de que un empleado solo tenga un deposito
asignado, en caso de no poder se irán aumentando la cantidad de depósitos
progresivamente para cada empleado.
*/

CREATE PROCEDURE reasignar_encargados 
AS 
BEGIN
    -- Depositos que su encargando es vendedor y jefe || Podria simplemente traerme todos los depositos y reasignar todos
    DECLARE cursorDepositos CURSOR FOR SELECT depo_codigo FROM Deposito 
                                        WHERE depo_encargado IN (SELECT clie_vendedor FROM Cliente) AND depo_encargado IN (SELECT empl_jefe FROM Empleado)
    DECLARE @depo char(2), @nuevoEncargado char(6)
    OPEN cursorDepositos
    FETCH cursorDepositos INTO @depo
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT TOP 1 @nuevoEncargado=empl_codigo FROM Empleado 
        LEFT JOIN Deposito ON depo_encargado = empl_codigo
        WHERE empl_codigo NOT IN (SELECT clie_vendedor FROM Cliente) AND empl_codigo NOT IN (SELECT empl_jefe FROM Empleado)
        GROUP BY empl_codigo
        ORDER BY COUNT(*) asc

        UPDATE Deposito SET depo_encargado = @nuevoEncargado WHERE depo_codigo = @depo

        FETCH cursorDepositos INTO @depo
    END
    CLOSE cursorDepositos
    DEALLOCATE cursorDepositos
END
GO

--------------
-- PUNTO 28 --
--------------

/*
Se requiere reasignar los vendedores a los clientes. Para ello se solicita que
realice el o los objetos de base de datos necesarios para asignar a cada uno de los
clientes el vendedor que le corresponda, 

Entendiendo que el vendedor que le corresponde es aquel que le vendio mas facturas a ese cliente, 
si en particular un cliente no tiene facturas compradas se le debera asignar el vendedor con mas
venta de la empresa, o sea, el que en monto haya vendido mas.
*/


CREATE PROCEDURE reasignar_vendedores
AS
BEGIN
    DECLARE cursorClientes CURSOR FOR SELECT clie_codigo FROM Cliente 
    DECLARE @cliente char(6), @nuevoVendedor char(6)
    OPEN cursorClientes
    FETCH cursorClientes INTO @cliente
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT TOP 1 @nuevoVendedor=fact_vendedor FROM Factura 
        WHERE fact_cliente = @cliente
        GROUP BY fact_vendedor
        ORDER BY COUNT(*) desc

        IF @nuevoVendedor IS NULL
            SELECT TOP 1 @nuevoVendedor=fact_vendedor FROM Factura 
            GROUP BY fact_vendedor 
            ORDER BY SUM(fact_total) desc
        
        UPDATE Cliente SET clie_vendedor = @nuevoVendedor WHERE clie_codigo = @cliente

        FETCH cursorClientes INTO @cliente
    END
    CLOSE cursorClientes
    DEALLOCATE cursorClientes
END
GO
--------------
-- PUNTO 29 --
--------------


-- No entiendo la consigna


--------------
-- PUNTO 30 --
--------------
/*
Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar mas de 100 unidades en el mes de ningun producto, si esto
ocurre no se debera ingresar la operacion y se debera emitir un mensaje 

"Se ha superado el limite maximo de compra de un producto". 

--> Se sabe que esta regla se cumple y que las facturas no pueden ser modificadas.
*/

CREATE TRIGGER verificar_maximo_unidades ON Factura FOR INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM Inserted WHERE dbo.supera_maximo(fact_numero, fact_sucursal, fact_tipo, fact_cliente, fact_fecha) = 1)
    BEGIN
        DELETE FROM Item_Factura 
        WHERE item_numero+item_sucursal+item_tipo IN (SELECT item_tipo+item_numero+item_sucursal FROM Item_Factura
                                                        JOIN Factura ON item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
                                                        WHERE dbo.supera_maximo(fact_numero, fact_sucursal, fact_tipo, fact_cliente, fact_fecha) = 1)
        -- DELETE FROM Factura 
        -- WHERE fact_tipo+fact_numero+fact_sucursal IN (SELECT item_tipo+item_numero+item_sucursal FROM Item_Factura
        --                                                 JOIN Factura ON item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
        --                                                 WHERE dbo.supera_maximo(fact_numero, fact_sucursal, fact_tipo, fact_cliente, fact_fecha) = 1)
        ROLLBACK -- En teoria dice que "no se debe ingresar la operacion" si se refiere a la factura que incumple se hace lo de arriba. Si se refiere a toda la transaccion se hace esto
    END
END
GO


-- Interpreto que el enunciado te dice que no podes comprar por ejemplo mas de 100 cocacolas en un mes, osea es por producto
CREATE FUNCTION supera_maximo(@tipo char(1), @sucursal char(4), @numero char(8), @cliente char(6), @fecha datetime) 
RETURNS INT
AS
BEGIN
    DECLARE @supera INT = 0, @producto char(8), @total numeric(12,2)
    DECLARE cursorItems CURSOR FOR SELECT item_producto FROM Item_Factura 
    WHERE @numero+@tipo+@sucursal = item_numero+item_tipo+item_sucursal

    OPEN cursorItems
    FETCH cursorItems INTO @producto
    WHILE @@FETCH_STATUS = 0
    BEGIN

        SELECT @total=SUM(item_cantidad) FROM Factura
        JOIN Item_Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal 
        WHERE item_producto = @producto AND fact_cliente = @cliente AND month(fact_fecha) = month(@fecha) AND year(fact_fecha) = year(@fecha)

        IF @total > 100
        BEGIN
            PRINT('Se ha superado el limite maximo de compra del producto: ' + @producto)
            SET @supera = 1
        END

        FETCH cursorItems INTO @producto
    END
    CLOSE cursorItems
    DEALLOCATE cursorItems

    RETURN @supera
END
GO


-- Otra version tomando el trigger en Item_Factura

CREATE TRIGGER verificar_maximo_unidades_v2 ON Item_Factura FOR INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM Inserted i JOIN Factura f ON i.item_tipo+i.item_numero+i.item_sucursal = f.fact_tipo+f.fact_numero+f.fact_sucursal
    WHERE (SELECT SUM(item_cantidad) FROM Item_Factura
            JOIN Factura ON item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
            WHERE i.item_producto = item_producto AND year(fact_fecha) = year(f.fact_fecha) AND month(fact_fecha) = month(f.fact_fecha) AND f.fact_cliente = fact_cliente
            GROUP BY item_producto)
            > 100)
        ROLLBACK
    
END
GO




--------------
-- PUNTO 31 --
--------------

/*
Desarrolle el o los objetos de base de datos necesarios, para que un jefe no pueda
tener más de 20 empleados a cargo, directa o indirectamente, si esto ocurre
debera asignarsele un jefe que cumpla esa condición, si no existe un jefe para
asignarle se le deberá colocar como jefe al gerente general que es aquel que no
tiene jefe.
*/

CREATE TRIGGER limitar_jefes ON Empleado FOR INSERT,UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM Empleado WHERE dbo.cantidad_empleados(empl_codigo) > 20)
    BEGIN
        DECLARE cursorEmpleados CURSOR FOR SELECT empl_codigo FROM Inserted WHERE dbo.cantidad_empleados(empl_jefe) > 20
        DECLARE @empleado char(6), @nuevoJefe char(6)
        OPEN cursorEmpleados
        FETCH cursorEmpleados INTO @empleado
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT TOP 1 @nuevoJefe=empl_codigo FROM Empleado 
            WHERE dbo.cantidad_empleados(empl_codigo) < 20 
            ORDER BY dbo.cantidad_empleados(empl_codigo) asc

            IF @nuevoJefe IS NULL
                SELECT @nuevoJefe=empl_codigo FROM Empleado WHERE empl_jefe IS NULL

            UPDATE Empleado SET empl_jefe = @nuevoJefe WHERE empl_codigo = @empleado

            FETCH cursorEmpleados INTO @empleado
        END
        CLOSE cursorEmpleados
        DEALLOCATE cursorEmpleados
    END
END