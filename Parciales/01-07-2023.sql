
---------
-- SQL --
---------

/*
Realizar una consulta SQL que retorne para todas las zonas que tengan
3 (tres) o más depósitos.
    1) Detalle Zona
    2) Cantidad de Depósitos x Zona
    3) Cantidad de Productos distintos compuestos en sus depósitos
    4) Producto mas vendido en el año 2012 que tenga stock en al menos
    uno de sus depósitos.
    5) Mejor encargado perteneciente a esa zona (El que mas vendió en la
        historia).
El resultado deberá ser ordenado por monto total vendido del encargado
descendiente.
NOTA: No se permite el uso de sub-selects en el FROM ni funciones
definidas por el usuario para este punto.
*/

SELECT zona_detalle, 
COUNT(distinct depo_codigo) , 
ISNULL(COUNT(distinct comp_producto),0),

(SELECT TOP 1 item_producto
FROM Item_Factura
JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE year(fact_fecha) = 2012 AND item_producto IN (SELECT stoc_producto FROM Stock JOIN Deposito ON stoc_deposito = depo_codigo WHERE depo_zona = zona_codigo AND stoc_cantidad > 0)
GROUP BY item_producto
ORDER BY SUM(item_cantidad) desc),

(SELECT TOP 1 fact_vendedor
FROM Factura
JOIN Empleado ON fact_vendedor = empl_codigo
JOIN Departamento ON empl_departamento = depa_codigo
WHERE depa_zona = zona_codigo
GROUP BY fact_vendedor
ORDER BY SUM(fact_total) desc)

FROM Zona
JOIN Deposito ON depo_zona = zona_codigo
LEFT JOIN Stock ON stoc_deposito = depo_codigo
LEFT JOIN Composicion ON stoc_producto = comp_producto
GROUP BY zona_detalle, zona_codigo
HAVING COUNT(distinct depo_codigo) >= 3
ORDER BY 5
GO
----------
-- TSQL --
----------

/*2. Actualmente el campo fact_vendedor representa al empleado que vendió
la factura. Implementar el/los objetos necesarios para respetar
integridad referenciales de dicho campo suponiendo que no existe una
foreign key entre ambos.

NOTA: No se puede usar una foreign key para el ejercicio, deberá buscar
otro método */

/*
Si alguien intenta insertar una factura con un fact_vendedor que no existe en la tabla Empleado, no debería permitirse.

Y si alguien intenta borrar un empleado que todavía tiene facturas asociadas, tampoco debería permitirse.
*/


CREATE TRIGGER verificar_fk_factura ON Factura FOR INSERT
AS
BEGIN
    IF EXISTS(SELECT * FROM Inserted WHERE fact_vendedor NOT IN (SELECT empl_codigo FROM Empleado))
        ROLLBACK
END
GO

CREATE TRIGGER verificar_fk_empleado ON Empleado FOR DELETE
AS
BEGIN
    IF EXISTS(SELECT * FROM deleted WHERE empl_codigo  IN (SELECT fact_vendedor FROM Factura))
        ROLLBACK
END
