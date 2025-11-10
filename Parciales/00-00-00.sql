---------
-- SQL --
---------

/*
Realizar una consulta SQL que retorne para todas las zonas que tengan
2 (dos) o mas depositos.
Detalle Zona
Cantidad de Depositos x Zona
Cantidad de Productos distintos en los depositos de esa zona.
Cantidad de Productos distintos vendidos de esos depositos y zona.
El resultado debera ser ordenado por la zona que mas empleados tenga
NOTA: No se permite el uso de sub-selects en el FROM.
*/

SELECT zona_detalle, 
COUNT(distinct depo_codigo) '# Depositos', 
COUNT(distinct stoc_producto) '# Productos', 
COUNT(distinct item_producto) '# Items '
FROM Zona
JOIN Deposito ON depo_zona = zona_codigo
LEFT JOIN Stock ON stoc_deposito = depo_codigo
LEFT JOIN Item_Factura ON item_producto = stoc_producto
GROUP BY zona_codigo, zona_detalle
HAVING COUNT(distinct depo_codigo) >= 2
ORDER BY (SELECT COUNT(*)
          FROM Empleado
          JOIN Departamento ON empl_departamento = depa_codigo
          WHERE depa_zona = zona_codigo) desc
GO

----------
-- TSQL --
----------

/* 2. Cree el o los objetos necesarios para que controlar que un producto no pueda tener asignado 
un rubro que tenga mas de 20 productos asignados, 
si esto ocurre, hay que asignarle el rubro que menos productos tenga asignado e informar a que producto y que rubro se le asigno.
En la actualidad la regla se cumple y no se sabe la forma en que se accede a la Base de Datos.*/

CREATE TRIGGER verificar_cant_rubros ON Producto FOR INSERT
AS
BEGIN
    DECLARE @prod CHAR(8), @rubro char(4)
    
    DECLARE cursorProductos CURSOR FOR SELECT prod_codigo, prod_rubro FROM Inserted
    DECLARE @nuevoRubro char(4)
    OPEN cursorProductos
    FETCH cursorProductos INTO @prod, @rubro 
    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        IF @rubro IN (SELECT rubr_id FROM Rubro JOIN Producto ON prod_rubro = rubr_id GROUP BY rubr_id HAVING COUNT(*) > 20)
        BEGIN
            SELECT TOP 1 @nuevoRubro=rubr_id FROM Rubro JOIN Producto ON prod_rubro = rubr_id GROUP BY rubr_id ORDER BY COUNT(*) asc

            UPDATE Producto SET prod_rubro = @nuevoRubro WHERE prod_codigo = @prod

            PRINT('Producto codigo: '+ prod_codigo+' se le asigna el rubro: '+@nuevoRubro)
        END
        FETCH cursorProductos INTO @prod, @rubro

    END
    CLOSE cursorProductos
    DEALLOCATE cursorProductos
END
