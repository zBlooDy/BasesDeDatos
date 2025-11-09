---------
-- SQL --
---------

/*
Realizar una consulta SQL que muestre aquellos productos que tengan
3 componentes a nivel producto y cuyos componentes tengan 2 rubros
distintos.
De estos productos mostrar:
    i) El código de producto.
    ii) El nombre del producto.
    iii) La cantidad de veces que fueron vendidos sus componentes en el 2012.
    iv) Monto total vendido del producto.

El resultado deberá ser ordenado por cantidad de facturas del 2012 en
las cuales se vendieron los componentes.
Nota: No se permiten select en el from, es decir, select... from (select ...) as T....
*/

SELECT prod_codigo, 
prod_detalle, 

(SELECT SUM(item_cantidad)
FROM Item_Factura
JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
WHERE item_producto IN (SELECT comp_componente FROM Composicion WHERE comp_producto = prod_codigo)
AND year(fact_fecha) = 2012) 'Cantidad vendida comp en 2012', 

SUM(item_cantidad * item_precio) 'Monto total vendido'

FROM Producto 
JOIN Item_Factura ON item_producto = prod_codigo
WHERE prod_codigo IN (SELECT comp_producto
                        FROM Composicion
                        JOIN Producto ON comp_componente = prod_codigo
                        GROUP BY comp_producto
                        HAVING COUNT(distinct prod_rubro) = 2 AND COUNT(distinct comp_componente) = 3)
GROUP BY prod_codigo, prod_detalle
GO

----------
-- TSQL --
----------

/*
Implementar una regla de negocio en linea donde se valide que nuncа
un producto compuesto pueda estar compuesto por componentes de rubros distintos a el.
*/


CREATE TRIGGER validar_recursividad ON Composicion FOR INSERT
AS
BEGIN
    IF EXISTS(SELECT * FROM inserted 
              JOIN Producto p1 ON p1.prod_codigo = comp_producto
              JOIN Producto p2 ON p2.prod_codigo = comp_componente
              WHERE p1.prod_rubro <> p2.prod_rubro)
        ROLLBACK
              
END
