--------------
-- PUNTO 10 --
--------------

/*Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que
mayor compra realizo.*/

SELECT prod_detalle, (SELECT TOP 1 fact_cliente
                        FROM Factura
                        JOIN Item_Factura ON item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
                        WHERE prod_codigo = item_producto
                        GROUP BY fact_cliente
                        ORDER BY SUM(item_cantidad) desc)
FROM Producto
WHERE prod_codigo IN 
                        (SELECT TOP 10 item_producto
                        FROM Item_Factura
                        GROUP BY item_producto
                        order by SUM(item_cantidad) desc) 
                    or prod_codigo in 
                                    (SELECT TOP 10 item_producto
                                    FROM Item_Factura
                                    GROUP BY item_producto
                                    order by SUM(item_cantidad) asc)







-- Nunca puedo tener en una query condiciones disyuntivas (uno o otro). 
-- 
