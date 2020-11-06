USE tienda;
# suma del salario de los últimos 5 puestos agregados
SELECT max(id_puesto) - 5 FROM puesto;
SELECT sum(salario) FROM puesto WHERE id_puesto > 995;

SELECT sum(salario) FROM puesto WHERE id_puesto > 
(SELECT max(id_puesto) - 5 FROM puesto);

# Ejemplo 1: Subconsultas
-- Queremos los empleados cuyo puesto es Junior Executive
SELECT id_puesto FROM puesto WHERE nombre = 'Junior Executive';
-- con los identificadores que obtuvimos, podemos hacer una búsqueda de los empleado que tienen dichos identificadores.
SELECT *
FROM empleado
WHERE id_puesto IN 
   (SELECT id_puesto
   FROM puesto
   WHERE nombre = 'Junior Executive');
   -- Ahora queremos saber cuál es la menor y mayor cantidad de ventas de un artículo. 
   -- Primero, obtengamos la cantidad de piezas por venta de un artículo.
SELECT clave, id_articulo, count(*) AS cantidad
FROM venta
GROUP BY clave, id_articulo
ORDER BY clave;
-- hacemos un nuevo agrupamiento para obtener la cantidad mínima y máxima de cada artículo, sin importar la venta.
SELECT id_articulo, min(cantidad), max(cantidad)
FROM 
   (SELECT clave, id_articulo, count(*) AS cantidad
   FROM venta
   GROUP BY clave, id_articulo
   ORDER BY clave) AS subconsulta
GROUP BY id_articulo;
-- sueldo de cada empleado usando una subconsulta. 
-- obtenemos primero el sueldo de cada tipo de empleado y luego lo usamos como subconsulta.
SELECT nombre, apellido_paterno, (SELECT salario FROM puesto WHERE id_puesto = e.id_puesto) AS sueldo FROM empleado AS e;

# Reto 1: subconsultas
-- ¿Cuál es el nombre de los empleados cuyo sueldo es menor a $10,000?
SELECT nombre, apellido_paterno, apellido_materno FROM empleado WHERE id_puesto IN (SELECT id_puesto FROM puesto WHERE salario < 10000);
-- ¿Cuál es la cantidad mínima y máxima de ventas de cada empleado?
SELECT id_empleado, min(cantidad), max(cantidad)
FROM 
   (SELECT clave, id_empleado, count(*) AS cantidad
   FROM venta
   GROUP BY clave, id_empleado
   ORDER BY clave) AS subconsulta
GROUP BY id_empleado;
-- ¿Cuáles claves de venta incluyen artículos cuyos precios son mayores a $5,000?
SELECT clave FROM venta WHERE id_articulo IN (SELECT id_articulo FROM articulo WHERE precio > 5000);
-- ¿Cuál es el nombre del puesto de cada empleado?
SELECT nombre, apellido_paterno, (SELECT nombre FROM puesto WHERE id_puesto = e.id_puesto) AS cargo FROM empleado AS e;

# Ejemplo 2: Clasificación de JOINS
SHOW KEYS FROM venta;
-- INNER JOIN
SELECT *
FROM empleado AS e
JOIN puesto AS p
  ON e.id_puesto = p.id_puesto;
-- LEFT JOIN
SELECT *
FROM puesto AS p
LEFT JOIN empleado AS e
ON p.id_puesto = e.id_puesto;
-- RIGHT JOIN
SELECT *
FROM empleado AS e
RIGHT JOIN puesto AS p
ON e.id_puesto = p.id_puesto;

# Reto 2: Joins
-- ¿Cuál es el nombre de los empleados que realizaron cada venta?
SELECT nombre, apellido_paterno, id_venta, clave
FROM empleado AS e
JOIN venta AS v
ON e.id_empleado = v.id_empleado
ORDER BY clave;

-- ¿Cuál es el nombre de los artículos que se han vendido?
SELECT nombre, id_venta, clave
FROM articulo AS a
JOIN venta AS v
ON a.id_articulo = v.id_articulo
ORDER BY clave;

-- ¿Cuál es el total de cada venta?
SELECT clave, round(sum(precio),2) AS total
FROM articulo AS a
JOIN venta AS v
  ON a.id_articulo = v.id_articulo
  GROUP BY clave
  ORDER BY clave;
  
# Ejemplo 3: Definición de vistas
-- la tabla que almacena las ventas, puede relacionarse con los empleados y los artículo. 
-- Podemos crear una vista que almacene esta relación como si fuera un ticket.
SELECT v.clave, v.fecha, a.nombre producto, a.precio, concat(e.nombre, ' ', e.apellido_paterno) empleado 
FROM venta v
JOIN empleado e
  ON v.id_empleado = e.id_empleado
JOIN articulo a
  ON v.id_articulo = a.id_articulo;

CREATE VIEW tickets_170 AS
(SELECT v.clave, v.fecha, a.nombre producto, a.precio, concat(e.nombre, ' ', e.apellido_paterno) empleado 
FROM venta v
JOIN empleado e
  ON v.id_empleado = e.id_empleado
JOIN articulo a
  ON v.id_articulo = a.id_articulo);
  
SELECT * FROM tickets_170;
SELECT clave, round(sum(precio),2) total
FROM tickets
GROUP BY clave;	

# Reto 3: agrupamientos y subconsultas
-- ¿Cuál es el nombre de los empleados que realizaron cada venta?
SELECT clave, concat(e.nombre, ' ', e.apellido_paterno) AS trabajador
FROM empleado AS e
JOIN venta AS v
  ON e.id_empleado = v.id_empleado
  ORDER BY clave;
-- ¿Cuál es el nombre de los artículos que se han vendido?
SELECT clave, nombre
FROM articulo AS a
JOIN venta AS v
  ON a.id_articulo = v.id_articulo
  ORDER BY clave;
-- ¿Cuál es el total de cada venta?
SELECT clave, nombre, round(sum(precio),2) AS total
FROM articulo AS a
JOIN venta AS v
  ON a.id_articulo = v.id_articulo
  GROUP BY clave
  ORDER BY clave;
  
  # Reto 3: vistas
-- Obtener el puesto de un empleado.
CREATE VIEW puestos_170 AS
SELECT concat(e.nombre, ' ', e.apellido_paterno) AS trabajador, p.nombre
FROM empleado AS e
JOIN puesto AS p
  ON e.id_puesto = p.id_puesto;
  
-- Saber qué artículos ha vendido cada empleado.
CREATE VIEW empleado_articulo_170 AS
SELECT v.clave, concat(e.nombre, ' ', e.apellido_paterno) nombre, a.nombre articulo
FROM venta v
JOIN empleado e
  ON v.id_empleado = e.id_empleado
JOIN articulo a
  ON v.id_articulo = a.id_articulo
ORDER BY v.clave;

-- Saber qué puesto ha tenido más ventas.
CREATE VIEW puesto_ventas_170 AS
SELECT p.nombre, count(v.clave) total
FROM venta v
JOIN empleado e
  ON v.id_empleado = e.id_empleado
JOIN puesto p
  ON e.id_puesto = p.id_puesto
GROUP BY p.nombre;

  -- Ejercicios Sesión 3
USE classicmodels;
-- Obten el código de producto, nombre de producto y descripción de todos los productos.
SELECT productCode, productName, productDescription FROM products;

-- Obten el número de orden, estado y costo total de cada orden.
SELECT o.orderNumber, o.status, d.priceEach 
FROM orders AS o
JOIN orderdetails AS d
ON o.orderNumber = d.orderNumber;

-- Obten el número de orden, fecha de orden, línea de orden, nombre del producto, cantidad ordenada y precio de cada pieza que muestre los detalles de cada orden.
SELECT d.orderNumber, o.orderDate, d.orderLineNumber, p.productName, d.quantityOrdered, d.priceEach, o.status  
FROM orderdetails AS d
JOIN orders AS o
ON d.orderNumber = o.orderNumber
JOIN products AS p
ON d.productCode = p.productCode; 

-- Obtén el número de orden, nombre del producto, el precio sugerido de fábrica (msrp) y precio de cada pieza.
SELECT d.orderNumber, p.productName, p.MSRP, d.priceEach
FROM orderdetails AS d
JOIN products AS p
ON d.productCode = p.productCode; 

-- Obtén el número de cliente, nombre de cliente, número de orden y estado de cada cliente.
SELECT c.customerNumber, c.customerName, o.orderNumber, o.status
FROM customers AS c
LEFT JOIN orders AS o
USING (customerNumber)
ORDER BY customerNumber; 

-- Obtén los clientes que no tienen una orden asociada.
SELECT customerNumber FROM orders WHERE orderNumber IS NULL;

-- Obtén el apellido de empleado, nombre de empleado, nombre de cliente, número de cheque y total, 
-- es decir, los clientes asociados a cada empleado.
SELECT e.lastName, e.firstName, c.customerName, p.checkNumber, p.amount 
FROM employees AS e
LEFT JOIN customers AS c
ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN payments AS p
ON c.customerNumber = p.customerNumber
ORDER BY customerName;

-- Repite los ejercicios usando RIGHT JOIN
SELECT c.customerNumber, c.customerName, o.orderNumber, o.status
FROM customers AS c
RIGHT JOIN orders AS o
USING (customerNumber)
ORDER BY customerNumber; 

SELECT e.lastName, e.firstName, c.customerName, p.checkNumber, p.amount 
FROM employees AS e
RIGHT JOIN customers AS c
ON e.employeeNumber = c.salesRepEmployeeNumber
RIGHT JOIN payments AS p
ON c.customerNumber = p.customerNumber
ORDER BY customerName;
