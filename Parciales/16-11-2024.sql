---------
-- SQL --
---------

/* 1. Realizar una consulta SQL que muestre la siguiente informacion para los clientes que hayan
comprado productos en mpas de tres rubros diferentes en 2012 y que no compro en años impares   
    - El numero de fila
    - El codigo del cliente 
    - el nombre del cliente
    - la cantidad total comprada por el cliente
    - la categoria en la que más compro en 2012
El resultado debe estar ordenado por la cantidad total comprada de mayor a menor 
*/ 

SELECT clie_codigo, clie_razon_social, SUM(item_cantidad), (SELECT TOP 1 prod_familia
                                                            FROM Producto
                                                            JOIN Item_Factura ON item_producto = prod_codigo
                                                            JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
                                                            WHERE year(fact_fecha) = 2012 AND fact_cliente = clie_codigo
                                                            GROUP BY prod_familia
                                                            ORDER BY SUM(item_cantidad) desc)
FROM Cliente
JOIN Factura ON fact_cliente = clie_codigo 
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE clie_codigo IN (SELECT fact_cliente FROM Factura 
                     JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
                     JOIN Producto ON prod_codigo = item_producto
                     WHERE year(fact_fecha) = 2012 
                     GROUP BY fact_cliente
                     HAVING COUNT(distinct prod_rubro) > 3)
AND clie_codigo NOT IN (SELECT fact_cliente FROM Factura
                    WHERE year(fact_fecha) % 2 <> 0 )
GROUP BY clie_codigo, clie_razon_social
GO


----------
-- TSQL --
----------

/* 2. Implementar los objetos necesarios para registrar, en tiempo real, los 10 productos
mas vendidos por anio en una tabla especifica. Esta tabla debe contener exclusivamente la info requerida
sin incluir filas adicionales. 

Los mas vendidos se define como aquellos productos con el mayor numero de unidades vendidas.
*/

CREATE TABLE MAS_VENDIDOS (
    prod_codigo char(8),
    cantidad_vendida numeric(12,2),
    anio datetime2
)
GO

CREATE PROCEDURE registrar_mas_vendidos(@anio datetime2)
AS
BEGIN
    INSERT INTO MAS_VENDIDOS (
        prod_codigo,
        cantidad_vendida,
        anio
    ) SELECT TOP 10 prod_codigo, SUM(item_cantidad), @anio
    FROM Producto
    JOIN Item_Factura ON item_producto = prod_codigo
    JOIN Factura ON item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
    WHERE year(fact_fecha) = @anio
    GROUP BY prod_codigo
    ORDER BY SUM(item_cantidad) desc
END

