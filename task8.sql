CREATE SCHEMA IF NOT EXISTS `StoredProceduresFunctionsDB` DEFAULT CHARACTER SET utf8 ;
USE `StoredProceduresFunctionsDB` ;

-- -----------------------------------------------------
-- Table `StoredProceduresFunctionsDB`.`Products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `StoredProceduresFunctionsDB`.`Products` (
  `product_id` INT NOT NULL AUTO_INCREMENT,
  `product_name` VARCHAR(255) NOT NULL,
  `price` DECIMAL(10, 2) NOT NULL,
  `stock_quantity` INT NOT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE = InnoDB;

-- Insert some sample data
INSERT INTO `Products` (`product_name`, `price`, `stock_quantity`) VALUES
('Laptop', 1200.00, 50),
('Mouse', 25.00, 200),
('Keyboard', 75.00, 100),
('Monitor', 300.00, 30),
('Webcam', 50.00, 80);

-- -----------------------------------------------------
-- Stored Procedure: UpdateProductStock
-- Objective: To update the stock quantity of a product based on product ID and quantity change.
--            It includes conditional logic to prevent negative stock.
-- -----------------------------------------------------
DELIMITER $$

CREATE PROCEDURE `UpdateProductStock` (
    IN p_product_id INT,
    IN p_quantity_change INT
)
BEGIN
    DECLARE current_stock INT;

    -- Get the current stock quantity
    SELECT stock_quantity INTO current_stock
    FROM Products
    WHERE product_id = p_product_id;

    -- Check if the product exists and if the update would result in negative stock
    IF current_stock IS NULL THEN
        SELECT 'Error: Product not found.' AS Message;
    ELSEIF (current_stock + p_quantity_change) < 0 THEN
        SELECT 'Error: Stock update would result in negative quantity.' AS Message;
    ELSE
        -- Update the stock quantity
        UPDATE Products
        SET stock_quantity = current_stock + p_quantity_change
        WHERE product_id = p_product_id;

        SELECT CONCAT('Stock for product ID ', p_product_id, ' updated successfully. New stock: ', (current_stock + p_quantity_change)) AS Message;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- Function: CalculateTotalPrice
-- Objective: To calculate the total price for a given product ID and desired quantity.
--            It includes error handling for non-existent products.
-- -----------------------------------------------------
DELIMITER $$

CREATE FUNCTION `CalculateTotalPrice` (
    p_product_id INT,
    p_quantity INT
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE product_price DECIMAL(10, 2);
    DECLARE total_price DECIMAL(10, 2);

    -- Get the price of the product
    SELECT price INTO product_price
    FROM Products
    WHERE product_id = p_product_id;

    -- Check if the product exists
    IF product_price IS NULL THEN
        RETURN -1.00; -- Indicate product not found with a negative value
    ELSE
        SET total_price = product_price * p_quantity;
        RETURN total_price;
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- Example Usage
-- -----------------------------------------------------

-- Before calling the procedure
SELECT * FROM Products;

-- Example 1: Successfully update stock (increase)
CALL UpdateProductStock(1, 10);
SELECT * FROM Products WHERE product_id = 1;

-- Example 2: Successfully update stock (decrease)
CALL UpdateProductStock(2, -5);
SELECT * FROM Products WHERE product_id = 2;

-- Example 3: Attempt to update stock for a non-existent product
CALL UpdateProductStock(999, 10);

-- Example 4: Attempt to update stock resulting in negative quantity
CALL UpdateProductStock(3, -150); -- Keyboard has 100 stock

-- After calling the procedure (check overall changes)
SELECT * FROM Products;

-- Example 1: Calculate total price for an existing product
SELECT CalculateTotalPrice(1, 3) AS TotalForLaptop; -- Laptop price 1200.00 * 3 = 3600.00

-- Example 2: Calculate total price for another existing product
SELECT CalculateTotalPrice(4, 2) AS TotalForMonitor; -- Monitor price 300.00 * 2 = 600.00

-- Example 3: Attempt to calculate total price for a non-existent product
SELECT CalculateTotalPrice(999, 5) AS TotalForNonExistentProduct; -- Should return -1.00

-- Clean up (optional: uncomment to drop the schema and data)
-- DROP SCHEMA `StoredProceduresFunctionsDB`;