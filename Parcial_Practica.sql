/* 1.  Realizar una consulta SQL que retorne para el último año, los 5 vendedores con menos clientes asignados,
que más vendieron en pesos (si hay varios con menos clientes asignados debe traer el que más vendió), solo deben
considerarse las facturas que tengan más de dos ítems facturados:

1)   Apellido y Nombre  del Vendedor.
2)   Total de unidades de Producto Vendidas.
3)   Monto promedio de venta por factura.
4)   Monto total de ventas.

El resultado deberá mostrar ordenado la cantidad de ventas descendente, en caso de igualdad de cantidades,
ordenar por código de vendedor.
NOTA: No se permite el uso de sub-selects en el FROM. */

use BD2025

SELECT FROM Clien













/* 2.   Dado el contexto inflacionario se tiene que aplicar un control en el cual nunca se permita vender un producto a un 
precio que no esté entre 0%–5% del precio de venta del producto el mes anterior, ni tampoco que esté en más de un 50% el 
precio del mismo producto que hace 12 meses atrás. Aquellos productos nuevos, o que no tuvieron ventas en meses anteriores 
no debe considerar esta regla ya que no hay precio de referencia. */
