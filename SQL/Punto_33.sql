--------------
-- PUNTO 33 --
--------------
/*
Se requiere obtener una estadistica de venta de productos que sean componentes. Para
ello se solicita que realiza la siguiente consulta que retorne la venta de los
componentes del producto mas vendido del año 2012. Se debera mostrar:
a.Código de producto

b.Nombre del producto

c.Cantidad de unidades vendidas

d.Cantidad de facturas en la cual se facturo

e.Precio promedio facturado de ese producto.

f.Total facturado para ese producto

El resultado deberá ser ordenado por el total vendido por producto para el año 2012.
*/


SELECT prod_codigo, prod_detalle, SUM(item_cantidad), COUNT(distinct fact_numero), AVG(item_precio), SUM(item_cantidad * item_precio)
FROM Factura
JOIN Item_Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
JOIN Producto ON item_producto = prod_codigo
WHERE prod_codigo IN (SELECT comp_componente
                     FROM Composicion
                     WHERE comp_producto = (SELECT TOP 1 item_producto
                                            FROM Factura
                                            JOIN Item_Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
                                            WHERE year(fact_fecha) = 2012
                                            GROUP BY item_producto
                                            ORDER BY SUM(item_cantidad) desc))
GROUP BY prod_codigo, prod_detalle