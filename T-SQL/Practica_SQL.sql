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
