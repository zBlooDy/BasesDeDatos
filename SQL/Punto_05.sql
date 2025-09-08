-------------
-- PUNTO 5 --
-------------

/*Realizar una consulta que muestre código de artículo, detalle y cantidad de ventas de stock que se realizaron 
para ese artículo en el año 2012. 
Mostrar solo aquellos que hayan tenido más egresos que en el 2011. */

SELECT prod_codigo, prod_detalle, SUM(item_cantidad)
FROM Producto
LEFT JOIN Item_Factura ON prod_codigo = item_producto -- Ojo, estoy expandiendo el universo (hago left para considerar prod q no se vendieron)
JOIN Factura ON item_numero+item_sucursal+item_tipo = fact_numero+fact_sucursal+fact_tipo -- Matcheo con toda la PK, no hay problema
WHERE year(fact_fecha) = '2012'
GROUP BY prod_codigo, prod_detalle
HAVING SUM(item_cantidad) > (SELECT SUM(item_cantidad)
							from Item_Factura
							JOIN Factura ON item_numero+item_sucursal+item_tipo = fact_numero+fact_sucursal+fact_tipo
							where year(fact_fecha) = '2011' AND item_producto = prod_codigo -- Matcheo para que una el de 2012 con el de 2011
							group by item_producto  
							)
order by 2





