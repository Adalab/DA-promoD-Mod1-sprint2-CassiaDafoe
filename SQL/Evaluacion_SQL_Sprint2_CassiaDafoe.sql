/* EVALUACION 2 SQL CASSIA DAFOE */

USE northwind;

/* Selecciona todos los campos de los productos, que pertenezcan a los proveedores con códigos: 
1, 3, 7, 8 y 9, que tengan stock en el almacén, y al mismo tiempo que sus precios unitarios estén 
entre 50 y 100. Por último, ordena los resultados por código de proveedor de forma ascendente. */

SELECT * 
FROM products
WHERE supplier_id IN (1, 3, 7, 8, 9) 
		AND units_in_stock > 0
		AND unit_price BETWEEN 50 AND 100
ORDER BY supplier_id;

/* Devuelve el nombre y apellidos y el id de los empleados con códigos entre el 3 y el 6, además que 
hayan vendido a clientes que tengan códigos que comiencen con las letras de la A hasta la G. Por último, 
en esta búsqueda queremos filtrar solo por aquellos envíos que la fecha de pedido este comprendida entre 
el 22 y el 31 de Diciembre de cualquier año. */

SELECT first_name, last_name
FROM employees
WHERE employee_id BETWEEN 3 AND 6
	AND employee_id IN (SELECT employee_id
			FROM orders
            WHERE customer_id REGEXP "^[A-G].*"
				AND YEAR(order_date) LIKE "____"
                AND MONTH(order_date) = "12"
                AND DAY(order_date) BETWEEN ("22") AND ("31"));


/* Calcula el precio de venta de cada pedido una vez aplicado el descuento. Muestra el id del la orden, 
el id del producto, el nombre del producto, el precio unitario, la cantidad, el descuento y el precio 
de venta después de haber aplicado el descuento. */

-- Precio de venta por producto:
SELECT A.order_id AS ID_Pedido, A.product_id AS ID_Producto, B.product_name AS NombreProducto, A.unit_price AS PrecioUnitario, A.quantity AS Cantidad, A.discount AS Descuento, ROUND(SUM(A.unit_price * A.quantity - (1 - A.discount)), 2) AS PrecioDeVenta
FROM order_details AS A
NATURAL JOIN products AS B;

-- Precio de venta por pedido (no se puede incluir todas las columnas especificadas):
SELECT A.order_id AS ID_Pedido, ROUND(SUM(A.unit_price * A.quantity - (1 - A.discount)), 2) AS PrecioDeVenta
FROM order_details AS A
NATURAL JOIN products AS B
GROUP BY A.order_id;

/* Usando una subconsulta, muestra los productos cuyos precios estén por encima del precio medio total de 
los productos de la BBDD. */

SELECT product_id AS ID_Producto, product_name AS ProductName
FROM products
WHERE unit_price > (SELECT AVG(unit_price)
					FROM products);

/* ¿Qué productos ha vendido cada empleado y cuál es la cantidad vendida de cada uno de ellos? */

SELECT E.first_name AS Nombre, E.last_name AS Apellido, P.product_id, P.product_name AS NombreProducto, SUM(D.quantity) AS CantidadVendido
FROM employees AS E 
INNER JOIN orders AS O 
ON E.employee_id = O.employee_id
INNER JOIN order_details AS D
ON O.order_id = D.order_id  
INNER JOIN products as P
ON D.product_id = P.product_id
GROUP BY E.first_name, E.last_name, P.product_name, P.product_id
ORDER BY Apellido;

/* Basándonos en la query anterior, ¿qué empleado es el que vende más productos? Soluciona este ejercicio con una subquery */

SELECT E.first_name AS Nombre, E.last_name AS Apellido, SUM(D.quantity) AS CantidadVendido
FROM employees AS E 
INNER JOIN orders AS O 
ON E.employee_id = O.employee_id
INNER JOIN order_details AS D
ON O.order_id = D.order_id  
GROUP BY E.first_name, E.last_name
HAVING SUM(D.quantity) >= ALL 
						(SELECT SUM(D.quantity)
						FROM orders AS O 
						INNER JOIN order_details AS D
						ON O.order_id = D.order_id  
						GROUP BY O.employee_id);

/* BONUS ¿Podríais solucionar este mismo ejercicio con una CTE? */

WITH ventas_por_empleado 
AS (SELECT O.employee_id AS ID_Empleado, SUM(D.quantity) AS Cantidad
	FROM order_details AS D 
	INNER JOIN orders AS O
	ON O.order_id = D.order_id  
	GROUP BY O.employee_id)
SELECT E.first_name, E.last_name, ventas_por_empleado.Cantidad
FROM ventas_por_empleado
INNER JOIN Employees AS E
ON ventas_por_empleado.ID_Empleado = E.employee_ID
GROUP BY E.first_name, E.last_name, ventas_por_empleado.Cantidad
ORDER BY ventas_por_empleado.Cantidad DESC
LIMIT 1;
