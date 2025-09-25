--------------
-- PUNTO 17 --
--------------

/*
Escriba una consulta que retorne una estadística de VENTAS por año y mes para cada PRODUCTO.
La consulta debe retornar:
PERIODO: Año y mes de la estadística con el formato YYYYMM
PROD: Código de producto
DETALLE: Detalle del producto
CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del periodo
pero del año anterior
CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el
periodo


La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
por periodo y código de producto.
*/

-- Con LEFT JOIN tomo todos los productos

SELECT STR(year(f.fact_fecha),4)+right('00'+ltrim(str(Month(f.fact_fecha),2)),2), prod_codigo, prod_detalle, SUM(item_cantidad) CANTIDAD_VENDIDA,

(SELECT SUM(i2.item_cantidad)
    FROM Item_Factura i2
    JOIN Factura f2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = i2.item_numero+i2.item_sucursal+i2.item_tipo AND year(f2.fact_fecha) = year(f.fact_fecha)-1 and month(f2.fact_fecha) = month(f.fact_fecha) 
    where i2.item_producto = prod_codigo
    GROUP BY i2.item_producto) VENTAS_AÑO_ANT , COUNT(distinct(f.fact_numero))CANT_FACTURAS

FROM Factura f
JOIN Item_Factura ON f.fact_numero+f.fact_sucursal+f.fact_tipo = item_numero+item_sucursal+item_tipo
RIGHT JOIN Producto ON item_producto = prod_codigo
group by prod_codigo, prod_detalle, year(f.fact_fecha), month(f.fact_fecha)
order by 1,2



select str(year(f1.fact_fecha),4)+right('00'+ltrim(str(Month(f1.fact_fecha),2)),2), prod_codigo, prod_detalle, sum(item_cantidad), 
    (select sum(i2.item_cantidad) from factura f2 join item_factura i2 on f2.fact_tipo+f2.fact_sucursal+f2.fact_numero = i2.item_tipo+i2.item_sucursal+i2.item_numero
    where year(f2.fact_fecha) = year(f1.fact_fecha)-1 and month(f2.fact_fecha) = month(f1.fact_fecha) and prod_codigo = i2.item_producto),
    count(distinct item_tipo+item_sucursal+item_numero)
from factura f1 join item_factura on f1.fact_tipo+f1.fact_sucursal+f1.fact_numero = item_tipo+item_sucursal+item_numero left join Producto on prod_codigo = item_producto
group by year(f1.fact_fecha),Month(f1.fact_fecha), prod_codigo, prod_detalle
order by 1, prod_codigo 
