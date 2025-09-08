-------------
-- PUNTO 3 --
-------------

/* Realizar una consulta que muestre código de producto, nombre de producto y el stock total, 
sin importar en que deposito se encuentre, 
los datos deben ser ordenados por nombre del artículo de menor a mayor. */

SELECT prod_codigo, prod_detalle, ISNULL(SUM(stoc_cantidad), 0)
FROM Producto
LEFT JOIN Stock ON prod_codigo = stoc_producto  -- Hago left porque sino, los productos q no tienen stock no los trae
GROUP BY prod_codigo, prod_detalle
ORDER BY prod_detalle

