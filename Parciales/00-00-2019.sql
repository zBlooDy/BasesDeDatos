
---------
-- SQL --
---------

/*Armar una consulta que muestre para todos los productos:

- Producto

- Detalle del producto

- Detalle composiciOn (si no es compuesto un string SIN COMPOSICION, si es compuesto un string CON COMPOSICION

- Cantidad de Componentes (si no es compuesto, tiene que mostrar 0)

- Cantidad de veces que fue comprado por distintos clientes

Nota: No se permiten sub select en el FROM.*/



SELECT prod_codigo, prod_detalle, 'SIN COMPOSICION', 0, COUNT(distinct fact_cliente)
FROM Producto
LEFT JOIN Item_Factura ON item_producto = prod_codigo
LEFT JOIN Factura ON item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
WHERE prod_codigo NOT IN (SELECT comp_producto FROM Composicion)
GROUP BY prod_codigo, prod_detalle
UNION ALL
SELECT prod_codigo, prod_detalle, 'CON COMPOSICION', COUNT(distinct comp_componente), COUNT(distinct fact_cliente)
FROM Producto
LEFT JOIN Item_Factura ON item_producto = prod_codigo
LEFT JOIN Factura ON item_tipo+item_numero+item_sucursal = fact_tipo+fact_numero+fact_sucursal
JOIN Composicion ON comp_producto = prod_codigo
GROUP BY prod_codigo, prod_detalle
GO

-- Otra resolucion es usar un CASE para el string y un ISNULL para la cantidad de componentes

----------
-- TSQL --
----------

/*Implementar el/los objetos necesarios para implementar la siguiente restriccion en linea:
Cuando se inserta en una venta un COMBO, nunca se debera guardar el producto COMBO, sino, la descomposicion de sus componentes.

Nota: Se sabe que actualmente todos los articulos guardados de ventas estan descompuestos en sus componentes.*/


CREATE TRIGGER insertar_descomposicion ON Item_Factura FOR INSERT
AS
BEGIN
	DECLARE cursorItems CURSOR FOR SELECT item_producto, item_cantidad, item_numero, item_sucursal, item_tipo FROM Inserted 
	WHERE item_producto IN (SELECT comp_producto FROM Composicion)

	DECLARE @producto char(8), @cant numeric(12,2), @numero char(8), @tipo char(1), @sucursal char(4)
	OPEN cursorItems
	FETCH cursorItems INTO @producto, @cantidad, @numero, @sucursal, @tipo
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE cursorComponentes CURSOR FOR SELECT comp_componente, comp_cantidad, prod_precio FROM Composicion JOIN Producto ON comp_componente = prod_codigo WHERE comp_producto = @producto
		DECLARE @componente char(8), @cantidad_comp numeric(12,2), @precio numeric(12,2)
		FETCH cursorComponentes INTO @componente, @cantidad_comp, @precio
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT Item_Factura VALUES (@tipo, @sucursal, @numero, @componente, @cantidad_comp * @cantidad_comp, @cantidad_comp * @precio)
			FETCH cursorComponentes INTO @componente, @cantidad_comp, @precio
		END
		CLOSE cursorComponentes
		DEALLOCATE cursorComponentes

		-- Borro el compuesto
		DELETE FROM Item_Factura WHERE item_tipo+item_numero+item_sucursal = @tipo+@numero+@sucursal AND item_producto = @producto
	    
		FETCH cursorItems INTO @producto, @cantidad, @numero, @sucursal, @tipo

	END
	CLOSE cursorItems
	DEALLOCATE cursorItems
END