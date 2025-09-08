/*
1. Productos con precio mayor a 50
Mostrar el c�digo, detalle y precio de todos los productos cuyo precio 
sea mayor a 50, ordenados de mayor a menor precio

SELECT prod_codigo, prod_detalle, prod_precio
FROM Producto
WHERE prod_precio > 50
ORDER BY prod_precio DESC
*/

/*
2. Empleados por salario
Listar el c�digo, nombre y salario de los empleados cuyo 
salario sea mayor o igual a 2000, ordenados por apellido de manera ascendente.

SELECT empl_codigo, empl_nombre, empl_apellido
FROM Empleado
WHERE empl_salario >= 2000
ORDER BY empl_apellido ASC
*/

/*
3. Clientes agrupados por vendedor
Mostrar el c�digo del vendedor y la cantidad de clientes 
asociados a cada uno, solo en los casos donde la cantidad de clientes 
sea mayor o igual a 7.

SELECT clie_vendedor, COUNT(*)
FROM Cliente
GROUP BY clie_vendedor
HAVING COUNT(*) >= 7
*/

/*
4. Facturas por cliente
Mostrar el c�digo de cliente y la cantidad de facturas de cada uno, pero
solo aquellos que tengan m�s de 3 facturas, ordenados de mayor a menor cantidad.


SELECT fact_cliente, COUNT(*) AS cantidad_facturas
FROM Factura
GROUP BY fact_cliente
HAVING COUNT(*) > 3
ORDER BY cantidad_facturas DESC
*/

/*
5. Stock agrupado
Mostrar el c�digo de producto y la suma total de stock en todos los 
dep�sitos, pero solo para los productos cuya suma sea mayor a 500. 
Ordenar por suma de stock de forma descendente.


SELECT stoc_producto, SUM(stoc_cantidad) AS suma_total_stock
FROM Stock
GROUP BY stoc_producto
HAVING SUM(stoc_cantidad) > 500
ORDER BY suma_total_stock DESC
*/

/*
6. Empleados con comisiones
Listar el c�digo de departamento y el promedio de comisi�n (empl_comision) 
de los empleados de cada departamento, 
mostrando solo los departamentos cuyo promedio supere el valor de 0.1.


SELECT empl_departamento, AVG(empl_comision) AS comision_promedio
FROM Empleado
GROUP BY empl_departamento
HAVING AVG(empl_comision) > 0.1
*/

/*
7. Clientes por vendedor
Mostrar el c�digo del vendedor y la cantidad de clientes que atiende, 
pero solo para los vendedores con al menos 10 clientes. 
Ordenar de mayor a menor cantidad de clientes.


SELECT clie_vendedor, COUNT(*) AS cantidad_clientes
FROM Cliente
GROUP BY clie_vendedor
HAVING COUNT(*) >= 10
ORDER BY cantidad_clientes DESC
*/

/*
8. Facturas altas por sucursal
Mostrar la sucursal y la factura con mayor total de cada una, agrupando por sucursal. 

SELECT fact_sucursal, MAX(fact_total) AS factura_max_total
FROM Factura
GROUP BY fact_sucursal
*/

/*
9. Stock m�nimo por producto
Mostrar el c�digo de producto y el m�nimo stock registrado en cualquier dep�sito, 
pero solo para los productos cuyo stock m�nimo sea menor a 10.

SELECT stoc_producto, MIN(stoc_cantidad) as minimo_stoc
FROM Stock
GROUP BY stoc_producto
HAVING MIN(stoc_cantidad) < 10
*/

/*
10. Dep�sitos con m�s productos distintos
Mostrar el c�digo de dep�sito y la cantidad de productos diferentes que tiene en stock, 
pero solo para dep�sitos con m�s de 100 productos distintos.


SELECT stoc_deposito, COUNT(stoc_producto) as cantidad_productos
FROM Stock
GROUP BY stoc_deposito
HAVING COUNT(stoc_producto) > 100
*/

/*
11. Clientes con cr�dito promedio alto
Calcular el promedio de l�mite de cr�dito de los clientes agrupados por vendedor, 
y mostrar solo los vendedores cuyo promedio de cr�dito sea mayor a 2000.


SELECT clie_vendedor, AVG(clie_limite_credito) as promedio_limite_credito
FROM Cliente
GROUP BY clie_vendedor
HAVING AVG(clie_limite_credito) > 2000
*/

/*
12. Productos caros por familia
Mostrar la familia y el precio m�ximo de producto de cada una, 
pero solo para las familias donde el precio m�ximo supere los $500.


SELECT prod_familia, MAX(prod_precio) as prod_precio_max
FROM Producto
GROUP BY prod_familia
*/


