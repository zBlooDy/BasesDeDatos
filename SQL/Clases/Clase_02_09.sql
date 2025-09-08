/*
-------------
-- PUNTO 1 --
-------------
Mostrar el c�digo, raz�n social de todos los clientes 
cuyo l�mite de cr�dito sea mayor o igual a $ 1000 
ordenado por c�digo de cliente. 

Arranco desde el FROM, entendiendo que en el FROM
esta el universo
*/


SELECT clie_codigo, clie_razon_social
FROM Cliente
WHERE clie_limite_credito > 1000
ORDER BY clie_codigo


/*
-------------
-- PUNTO 2 --
-------------
Mostrar el c�digo, detalle de todos 
los art�culos vendidos en el a�o 2012 
ordenados por cantidad vendida. 

En un join siempre una tabla manda en el tema de atomicidad. Igualar siempre por primary key en los join, para que no me modifique la atomicidad.

ORDER BY (puede ordenar por columna)
*/

SELECT prod_codigo, prod_detalle, SUM(item_cantidad) 
FROM Producto JOIN Item_Factura ON prod_codigo = item_producto JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = 
item_tipo+item_sucursal+item_numero
WHERE YEAR(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle -- A igualdad de codigo, mismo detalle tambien

/*
-------------
-- PUNTO 3 --
-------------
Realizar una consulta que muestre 
c�digo de producto, nombre de producto y el stock total, 
sin importar en que deposito se encuentre, 
los datos deben ser ordenados por nombre del art�culo de menor a mayor. 
*/

-- Pongo el LEFT para que me traiga todos los productos, aunque no tengan stock
-- ISNULL para que no me muestre el valor nulo y sino una cantidad
SELECT prod_codigo, prod_detalle, ISNULL(SUM(stoc_cantidad),0)
FROM Producto LEFT JOIN Stock ON prod_codigo = stoc_producto -- Estoy intersecando con una parte de la PK, entonces me va a dar repetido
GROUP BY prod_codigo, prod_detalle
ORDER BY prod_detalle 


-------------
-- PUNTO 4 --
-------------

/*
Realizar una consulta que muestre para todos los art�culos 
c�digo, detalle y cantidad de art�culos que lo componen. 
Mostrar solo aquellos art�culos para los cuales el stock promedio por dep�sito 
sea mayor a 100. 
*/
-- 2190 productos

-- El motor no cuenta NULL, entonces solo tiene sentido hacer los COUNT cuando se que puede haber null
-- Solo cuente los valores existentes de esa columna, no los NULOS

SELECT prod_codigo, prod_detalle, COUNT(comp_componente)
FROM Producto LEFT JOIN Composicion ON prod_codigo = comp_producto
WHERE prod_codigo in (
						SELECT stoc_producto
						FROM Stock
						GROUP BY stoc_producto
						HAVING AVG(stoc_cantidad) > 100)
GROUP BY prod_codigo, prod_detalle


-- JOIN Stock ON prod_codigo = stoc_producto ==> ESTO NO VA, ESTOY MODIFICANDO MAS EL UNIVERSO Y TRAIGO DUPLICADOS
-- La consulta dentro del WHERE, se ejecuta una sola vez
-- CONSULTA ESTATICA ==> No depende del afuera


-------------
-- PUNTO 5 --
-------------

/*
5. Realizar una consulta que muestre 
c�digo de art�culo, detalle y cantidad de egresos de stock (cant vendida)
que se realizaron para ese art�culo en el a�o 2012 
Mostrar solo aquellos que hayan tenido m�s egresos (VENTAS) que en el 2011. */


-- En estos JOINS manda el item factura, porque no estoy macheando con su PK total
SELECT prod_codigo, prod_detalle, SUM(item_cantidad) '2012'
FROM Producto JOIN Item_Factura ON prod_codigo = item_producto
JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE year(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
HAVING sum(item_cantidad) > ( --mayor a lo de 2011
							SELECT sum(item_cantidad) 
							FROM Item_Factura
							JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
							WHERE year(fact_fecha) = 2011 AND item_producto = prod_codigo)

-- Para cada iteracion de la consulta de afuera, la vuelve a ejecutar porque necesita EL PRODUCTO.
-- CONSULTA DINAMICA ==> Depende del afuera
-- Estoy seguro que devuelve 1 valor porque: Use un SUM para un valor y estoy igualando el item con el codigo, que si o si me devuelve 1


/*

-------------
-- PUNTO 6 --
-------------

6. Mostrar para todos los rubros de art�culos 
c�digo, detalle, cantidad de art�culos de ese rubro y 
stock total de ese rubro de art�culos. 

Solo tener en cuenta aquellos art�culos que tengan un stock mayor al del art�culo �00000000� en el dep�sito �00�. 
*/

-- 2109 productos

SELECT rubr_id, rubr_detalle, COUNT(distinct stoc_producto) 'CANT.PROD', SUM(isnull(stoc_cantidad,0)) 'STOCK_TOTAL'
FROM Rubro
LEFT JOIN Producto ON prod_rubro = rubr_id
LEFT JOIN Stock ON stoc_producto = prod_codigo
-- Para filtrar por stock mayor, tengo que filtrar los productos, porque despues del group by estoy trabajando con los rubros

GROUP BY rubr_id, rubr_detalle 

-- YO SE QUE VOY A TENER REPETICION EN LOS STOCK DE LOS PRODUCTOS, ENTONCES SOLO QUIERO QUE ME LO CUENTE 1 VEZ 
-- LE PONGO LEFT AL DE STOCK SINO NO ME MUESTRA LOS RUBROS Q NO TIENEN STOCK




SELECT stoc_cantidad
FROM Stock
WHERE stoc_deposito = '00' AND stoc_producto = '00000000'
