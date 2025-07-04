mysql> CREATE SCHEMA IF NOT EXISTS `StoredProceduresFunctionsDB` DEFAULT CHARACTER SET utf8 ;
Query OK, 1 row affected, 1 warning (0.01 sec)

mysql> USE `StoredProceduresFunctionsDB` ;
Database changed
mysql> CREATE TABLE IF NOT EXISTS `StoredProceduresFunctionsDB`.`Products` (
    ->   `product_id` INT NOT NULL AUTO_INCREMENT,
    ->   `product_name` VARCHAR(255) NOT NULL,
    ->   `price` DECIMAL(10, 2) NOT NULL,
    ->   `stock_quantity` INT NOT NULL,
    ->   PRIMARY KEY (`product_id`)
    -> ) ENGINE = InnoDB;
Query OK, 0 rows affected (0.06 sec)

mysql> INSERT INTO `Products` (`product_name`, `price`, `stock_quantity`) VALUES
    -> ('Laptop', 1200.00, 50),
    -> ('Mouse', 25.00, 200),
    -> ('Keyboard', 75.00, 100),
    -> ('Monitor', 300.00, 30),
    -> ('Webcam', 50.00, 80);
Query OK, 5 rows affected (0.02 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> DELIMITER $$
mysql> CREATE PROCEDURE `UpdateProductStock` (
    ->     IN p_product_id INT,
    ->     IN p_quantity_change INT
    -> )
    -> BEGIN
    ->     DECLARE current_stock INT;
    ->
    ->     -- Get the current stock quantity
    ->     SELECT stock_quantity INTO current_stock
    ->     FROM Products
    ->     WHERE product_id = p_product_id;
    ->
    ->     -- Check if the product exists and if the update would result in negative stock
    ->     IF current_stock IS NULL THEN
    ->         SELECT 'Error: Product not found.' AS Message;
    ->     ELSEIF (current_stock + p_quantity_change) < 0 THEN
    ->         SELECT 'Error: Stock update would result in negative quantity.' AS Message;
    ->     ELSE
    ->         -- Update the stock quantity
    ->         UPDATE Products
    ->         SET stock_quantity = current_stock + p_quantity_change
    ->         WHERE product_id = p_product_id;
    ->
    ->         SELECT CONCAT('Stock for product ID ', p_product_id, ' updated successfully. New stock: ', (current_stock + p_quantity_change)) AS Message;
    ->     END IF;
    -> END$$
Query OK, 0 rows affected (0.01 sec)

mysql>
mysql> DELIMITER ;
mysql> DELIMITER $$
mysql> CREATE FUNCTION `CalculateTotalPrice` (
    ->     p_product_id INT,
    ->     p_quantity INT
    -> )
    -> RETURNS DECIMAL(10, 2)
    -> DETERMINISTIC
    -> BEGIN
    ->     DECLARE product_price DECIMAL(10, 2);
    ->     DECLARE total_price DECIMAL(10, 2);
    ->
    ->     -- Get the price of the product
    ->     SELECT price INTO product_price
    ->     FROM Products
    ->     WHERE product_id = p_product_id;
    ->
    ->     -- Check if the product exists
    ->     IF product_price IS NULL THEN
    ->         RETURN -1.00; -- Indicate product not found with a negative value
    ->     ELSE
    ->         SET total_price = product_price * p_quantity;
    ->         RETURN total_price;
    ->     END IF;
    -> END$$
Query OK, 0 rows affected (0.01 sec)

mysql>
mysql> DELIMITER ;
mysql> SELECT * FROM Products;
+------------+--------------+---------+----------------+
| product_id | product_name | price   | stock_quantity |
+------------+--------------+---------+----------------+
|          1 | Laptop       | 1200.00 |             50 |
|          2 | Mouse        |   25.00 |            200 |
|          3 | Keyboard     |   75.00 |            100 |
|          4 | Monitor      |  300.00 |             30 |
|          5 | Webcam       |   50.00 |             80 |
+------------+--------------+---------+----------------+
5 rows in set (0.00 sec)

mysql> CALL UpdateProductStock(1, 10);
+------------------------------------------------------------+
| Message                                                    |
+------------------------------------------------------------+
| Stock for product ID 1 updated successfully. New stock: 60 |
+------------------------------------------------------------+
1 row in set (0.01 sec)

Query OK, 0 rows affected (0.02 sec)

mysql> SELECT * FROM Products WHERE product_id = 1;
+------------+--------------+---------+----------------+
| product_id | product_name | price   | stock_quantity |
+------------+--------------+---------+----------------+
|          1 | Laptop       | 1200.00 |             60 |
+------------+--------------+---------+----------------+
1 row in set (0.00 sec)

mysql> CALL UpdateProductStock(2, -5);
+-------------------------------------------------------------+
| Message                                                     |
+-------------------------------------------------------------+
| Stock for product ID 2 updated successfully. New stock: 195 |
+-------------------------------------------------------------+
1 row in set (0.01 sec)

Query OK, 0 rows affected (0.01 sec)

mysql> SELECT * FROM Products WHERE product_id = 2;
+------------+--------------+-------+----------------+
| product_id | product_name | price | stock_quantity |
+------------+--------------+-------+----------------+
|          2 | Mouse        | 25.00 |            195 |
+------------+--------------+-------+----------------+
1 row in set (0.00 sec)

mysql> CALL UpdateProductStock(999, 10);
+---------------------------+
| Message                   |
+---------------------------+
| Error: Product not found. |
+---------------------------+
1 row in set (0.00 sec)

Query OK, 0 rows affected (0.01 sec)

mysql> CALL UpdateProductStock(3, -150);
+--------------------------------------------------------+
| Message                                                |
+--------------------------------------------------------+
| Error: Stock update would result in negative quantity. |
+--------------------------------------------------------+
1 row in set (0.00 sec)

Query OK, 0 rows affected (0.01 sec)

mysql> SELECT * FROM Products;
+------------+--------------+---------+----------------+
| product_id | product_name | price   | stock_quantity |
+------------+--------------+---------+----------------+
|          1 | Laptop       | 1200.00 |             60 |
|          2 | Mouse        |   25.00 |            195 |
|          3 | Keyboard     |   75.00 |            100 |
|          4 | Monitor      |  300.00 |             30 |
|          5 | Webcam       |   50.00 |             80 |
+------------+--------------+---------+----------------+
5 rows in set (0.00 sec)

mysql> SELECT CalculateTotalPrice(1, 3) AS TotalForLaptop;
+----------------+
| TotalForLaptop |
+----------------+
|        3600.00 |
+----------------+
1 row in set (0.00 sec)

mysql> SELECT CalculateTotalPrice(4, 2) AS TotalForMonitor;
+-----------------+
| TotalForMonitor |
+-----------------+
|          600.00 |
+-----------------+
1 row in set (0.00 sec)

mysql> SELECT CalculateTotalPrice(999, 5) AS TotalForNonExistentProduct;
+----------------------------+
| TotalForNonExistentProduct |
+----------------------------+
|                      -1.00 |
+----------------------------+
1 row in set (0.00 sec)