---------
-- SQL --
---------

/*
 Por tal motivo se solicita un listado con los 5 productos más vendidos y los 5
productos menos vendidos durante el 2012. Comparar la cantidad vendida de
cada uno de estos productos con la cantidad vendida del año anterior e indicar
el string 'Más ventas' o 'Menos ventas', según corresponda. Además indicar el
envase.
A) Producto
B) Comparación año anterior
C) Detalle de Envase
Armar una consulta SQL que retorne esta información.
NOTA: No se permite el uso de sub-selects en el FROM ni funciones definidas
por el usuario para este punto.
NOTA2: Si un producto no tuvo ventas en el año, también debe considerarse
como producto menos vendido. En caso de existir más de 5, solamente mostrar
los 5 primeros en orden alfabético.
*/

SELECT prod_codigo, CASE WHEN (SELECT SUM(item_cantidad)
                                FROM Item_Factura
                                JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
                                WHERE item_producto = prod_codigo AND year(fact_fecha) = 2012
                                ) > (SELECT SUM(item_cantidad)
                                FROM Item_Factura
                                JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
                                WHERE item_producto = prod_codigo AND year(fact_fecha) = 2011
                                )
THEN 'Mas ventas'
ELSE 'Menos ventas'
END,
enva_detalle
FROM Producto
JOIN Envases ON prod_envase = enva_codigo
WHERE prod_codigo IN (SELECT TOP 5 item_producto 
                     FROM Item_Factura
                     JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
                     WHERE year(fact_fecha) = 2012
                     GROUP BY item_producto
                     ORDER BY SUM(item_cantidad) desc)
OR prod_codigo IN (SELECT TOP 5 prod_codigo 
                     FROM Producto 
                     LEFT JOIN Item_Factura ON prod_codigo = item_producto
                     LEFT JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
                     AND year(fact_fecha) = 2012
                     GROUP BY prod_codigo, prod_detalle
                     ORDER BY SUM(ISNULL(item_cantidad, 0)) ASC, prod_detalle)
ORDER BY 2
GO

----------
-- TSQL --
----------

/*
Se pide crear el/los objetos necesarios para que se imprima un cupón
con la leyenda "Recuerde solicitar su regalo sorpresa en su próxima compra" a
los clientes que, entre los productos comprados, hayan adquirido algún producto
de los siguientes rubros: PILAS y PASTILLAS y tengan un limite crediticio menor
a $ 15000
*/

CREATE TRIGGER notificar_cupon ON Item_Factura FOR INSERT
AS 
BEGIN
    DECLARE cursorItems CURSOR FOR SELECT rubr_detalle, clie_limite_credito FROM Inserted 
                                      JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
                                      JOIN Cliente ON fact_cliente = clie_codigo
                                      JOIN Producto ON item_producto = prod_codigo
                                      JOIN Rubro ON prod_codigo = rubr_id
                                      GROUP BY rubr_detalle, fact_cliente, clie_limite_credito
    DECLARE @detalle char(50), @credito numeric(12,2)
    OPEN cursorItems
    FETCH cursorItems INTO @detalle, @credito
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (@detalle = 'PILAS' OR @detalle = 'PASTILLA') AND @credito < 15000
            PRINT 'Tenes cupon papu'
        
        FETCH cursorItems INTO @detalle, @credito

    END

END 

