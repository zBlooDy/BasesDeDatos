---------
-- SQL --
---------

/*
Realizar una consulta SQL que devuelva para los 5 productos más vendidos y los 10 productos menos vendidos lo siguiente:

Código y detalle del producto en una sola columna separado por el carácter ‘ - ’ (ej: 0001 - DETALLE PRODUCTO)

Nombre del vendedor que más veces vendió el producto.

Cantidad de depósitos donde hay stock de ese producto.

Cliente que más veces compró ese producto.

Monto total facturado al cliente que más compró ese producto.

El resultado deberá mostrarse ordenado de mayor a menor cantidad de ventas de los productos.

NOTA: No se permite el uso de sub-selects en el FROM ni funciones definidas por el usuario para este punto.
*/

SELECT prod_codigo+' - '+prod_detalle 'Producto',

(SELECT TOP 1 empl_nombre
FROM Factura
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
JOIN Empleado ON fact_vendedor = empl_codigo
WHERE item_producto = prod_codigo
GROUP BY empl_nombre
ORDER BY SUM(item_cantidad) desc) 'Vendedor TOP1',

COUNT(distinct stoc_deposito),

(SELECT TOP 1 fact_cliente
FROM Factura
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE item_producto = prod_codigo
GROUP BY fact_cliente
ORDER BY SUM(item_cantidad) desc),

(SELECT SUM(item_cantidad * item_precio)
FROM Factura
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
-- Entiendo que es el monto que se le facturo a ese cliente x ese producto 
WHERE item_producto = prod_codigo AND fact_cliente = (SELECT TOP 1 fact_cliente
														FROM Factura
														JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
														WHERE item_producto = prod_codigo
														GROUP BY fact_cliente
														ORDER BY SUM(item_cantidad) desc))


FROM Producto
JOIN Stock ON prod_codigo = stoc_producto AND stoc_cantidad > 0
JOIN Item_Factura ON item_producto = prod_codigo
WHERE prod_codigo IN (SELECT TOP 5 item_producto
					  FROM Item_Factura 
					  GROUP BY item_producto
					  ORDER BY SUM(item_cantidad) desc
					  )
OR prod_codigo IN (SELECT TOP 10 item_producto
					  FROM Item_Factura 
					  GROUP BY item_producto
					  ORDER BY SUM(item_cantidad) asc
					  )
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad) desc


----------
-- TSQL --
----------
/*
Realizar el/los objetos de base de datos necesarios para que ante cada operación que se realice sobre la tabla STOCK, se grabe un registro en la tabla de auditoría AUD_STOCK con todas las columnas según se define a continuación.
La tabla debe crearse y tendrá la siguiente estructura:
CREATE TABLE AUD_STOCK (
    auds_renglon bigint,
    auds_operacion char(3),
    auds_fecha_hora smalldatetime,
    auds_cantidad decimal(12,2),
    auds_punto_reposicion decimal(12,2),
    auds_stock_maximo decimal(12,2),
    auds_detalle char(100),
    auds_proxima_reposicion smalldatetime,
    auds_producto char(8),
    auds_deposito char(2)
)
Además de las columnas de la tabla STOCK, deberá grabarse lo siguiente:

auds_renglon: Número consecutivo para cada registro que se grabe en AUD_STOCK.

auds_operacion:
Si se insertó un registro en STOCK, debe grabar “INS”.
Si se borró, “DEL”.
Y si se actualizó algún campo, deberá grabar “UP1” con los valores anteriores, y en otro registro “UP2” con los valores nuevos en el resto de los campos.

auds_fecha_hora: Fecha y hora de la operación.
*/

create table AUD_STOCK (
	auds_renglon bigint identity(1, 1), -- Defino que se aumente de a 1 asi me ahorro usar cursores
	auds_operacion char(3),
	auds_fecha_hora smalldatetime,
	auds_cantidad decimal(12, 2),
	auds_punto_reposicion decimal(12, 2),
	auds_stock_maximo decimal(12, 2),
	auds_detalle char(100),
	auds_proxima_reposicion smalldatetime,
	auds_producto char(8),
	auds_deposito char(2)
)
GO

CREATE TRIGGER auditar_stock ON Stock FOR INSERT,UPDATE,DELETE
AS
BEGIN
	IF EXISTS (SELECT * FROM Inserted)
	BEGIN
		IF EXISTS (SELECT * FROM Deleted)
		BEGIN
			-- Es un UPDATE
			INSERT INTO AUD_STOCK(auds_operacion, auds_fecha_hora, auds_cantidad, auds_punto_reposicion, auds_stock_maximo, auds_detalle, auds_proxima_reposicion, auds_producto, auds_deposito)
			SELECT 'UP1', GETDATE(), stoc_cantidad, stoc_punto_reposicion, stoc_stock_maximo, stoc_detalle, stoc_proxima_reposicion, stoc_producto, stoc_deposito 
			FROM Deleted

			INSERT INTO AUD_STOCK(auds_operacion, auds_fecha_hora, auds_cantidad, auds_punto_reposicion, auds_stock_maximo, auds_detalle, auds_proxima_reposicion, auds_producto, auds_deposito)
			SELECT 'UP2', GETDATE(), stoc_cantidad, stoc_punto_reposicion, stoc_stock_maximo, stoc_detalle, stoc_proxima_reposicion, stoc_producto, stoc_deposito 
			FROM Inserted
		END
		
		INSERT INTO AUD_STOCK(auds_operacion, auds_fecha_hora, auds_cantidad, auds_punto_reposicion, auds_stock_maximo, auds_detalle, auds_proxima_reposicion, auds_producto, auds_deposito)
		SELECT 'INS', GETDATE(), stoc_cantidad, stoc_punto_reposicion, stoc_stock_maximo, stoc_detalle, stoc_proxima_reposicion, stoc_producto, stoc_deposito 
		FROM Inserted

	END
	ELSE
	BEGIN
		INSERT INTO AUD_STOCK(auds_operacion, auds_fecha_hora, auds_cantidad, auds_punto_reposicion, auds_stock_maximo, auds_detalle, auds_proxima_reposicion, auds_producto, auds_deposito)
		SELECT 'DEL', GETDATE(), stoc_cantidad, stoc_punto_reposicion, stoc_stock_maximo, stoc_detalle, stoc_proxima_reposicion, stoc_producto, stoc_deposito 
		FROM deleted
	END
END