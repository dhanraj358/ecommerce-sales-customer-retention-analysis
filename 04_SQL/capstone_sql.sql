-- Create Database in MySQL Workbench
use retailtech;
CREATE DATABASE RetailTech;

USE RetailTech;
-- total rows
select count(*) from master_df;

-- view the data set
select * from master_df limit 10;

-- Table Structure
describe master_df; 

-- creating views
-- View 1: category-wise sales performance
CREATE VIEW sales_summary AS
SELECT Category_name,
    COUNT(DISTINCT order_id) AS Total_Orders,
    SUM(Final_Price) AS Total_Revenue,
    AVG(Final_Price) AS Average_Order_Value
FROM master_df
GROUP BY Category_name;
-- view the Result
select* from sales_summary;

-- View 2: View 2: Customer Retention ->monitor repeat customer behavior regularly
CREATE VIEW customer_retention AS
SELECT
    customer_segment,
    Repeat_Buyer,
    COUNT(DISTINCT customer_id) AS Total_Customers,
    AVG(Purchase_Frequency) AS Average_Purchase_Frequency
FROM master_df
GROUP BY customer_segment, Repeat_Buyer;
-- Result 
select * from customer_retention;

-- View 3: Customer Satisfaction->customer satisfaction by product category.
CREATE VIEW customer_satisfaction AS
SELECT
    Category_name,
    AVG(review_score) AS Average_Review_Score,
    COUNT(review_id) AS Total_Reviews,
    Delivery_Status
FROM master_df
GROUP BY Category_name, Delivery_Status;
-- Result 
SELECT * FROM customer_satisfaction;

-- Procedure 1: Display Customer Purchase History
DELIMITER $$

CREATE PROCEDURE sp_customer_purchase_history()
BEGIN
    SELECT
        customer_id,
        order_id,
        Final_Price,
        review_score,
        Delivery_Status
    FROM master_df;
END $$

DELIMITER ;
-- calling procedure
call sp_customer_purchase_history();

-- Procedure 2: Display category-wise sales performance.
DELIMITER $$

DELIMITER $$

CREATE PROCEDURE sp_category_performance()
BEGIN
    SELECT
        Category_name,
        Final_Price,
        review_score,
        order_status
    FROM master_df;
END $$

DELIMITER ;

-- calling 
CALL sp_category_performance();

-- Procedure 3: Purpose: Display month-wise sales summary.
DELIMITER $$

CREATE PROCEDURE sp_monthly_sales_report()
BEGIN
    SELECT
        MONTH(order_purchase_timestamp) AS Sales_Month,
        COUNT(DISTINCT order_id) AS Total_Orders,
        SUM(Final_Price) AS Total_Revenue,
        AVG(Final_Price) AS Average_Order_Value
    FROM master_df
    GROUP BY MONTH(order_purchase_timestamp)
    ORDER BY Sales_Month;
END $$

DELIMITER ;
-- calling 
CALL sp_monthly_sales_report();

-- Trigger 1 – Delivery Performance (BO1) ->Automatically classify delivery as On Time or Delayed.
DELIMITER $$

CREATE TRIGGER trg_delivery_status
BEFORE INSERT ON master_df
FOR EACH ROW
BEGIN
    IF NEW.Delivery_Days <= 7 THEN
        SET NEW.Delivery_Status = 'On Time';
    ELSE
        SET NEW.Delivery_Status = 'Delayed';
    END IF;
END$$

DELIMITER ;
-- Test 
INSERT INTO master_df
(order_id, customer_id, Delivery_Days)
VALUES
('T002', 'C002', 5);
-- Verify 
SELECT
order_id,
Delivery_Days,
Delivery_Status
FROM master_df
WHERE order_id='T002';

Trigger 2 – Customer Retention (BO2) -> Automatically identify repeat buyers.
DELIMITER $$

CREATE TRIGGER trg_repeat_buyer
BEFORE INSERT ON master_df
FOR EACH ROW
BEGIN
    IF NEW.Purchase_Frequency > 1 THEN
        SET NEW.Repeat_Buyer = 'Yes';
    ELSE
        SET NEW.Repeat_Buyer = 'No';
    END IF;
END$$

DELIMITER ;
-- test
INSERT INTO master_df
(order_id, customer_id, Purchase_Frequency)
VALUES
('T003', 'C003', 3);
-- verify

SELECT
order_id,
Purchase_Frequency,
Repeat_Buyer
FROM master_df
WHERE order_id='T003';


-- Trigger 3: Customer Satisfaction (BO4) -> Automatically set customer satisfaction based on the review score
DELIMITER $$

CREATE TRIGGER trg_customer_satisfaction
BEFORE INSERT ON master_df
FOR EACH ROW
BEGIN
    IF NEW.review_score >= 4 THEN
        SET NEW.Satisfaction = 'Satisfied';
    ELSE
        SET NEW.Satisfaction = 'Not Satisfied';
    END IF;
END$$

DELIMITER ;
-- Test
INSERT INTO master_df
(order_id, customer_id, review_score)
VALUES
('T001', 'C001', 5);
-- verify
SELECT
order_id,
review_score,
Satisfaction
FROM master_df
WHERE order_id='T001';

SHOW TRIGGERS;
-- connecting to excel
select * from sales_summary;
select * from customer_retention;
select * from customer_satisfaction;

-- show procedure
CALL sp_customer_purchase_history();
CALL sp_category_performance();
CALL sp_monthly_sales_report();

-- view 2 
CREATE VIEW vw_customer_retention AS
SELECT
    Category_name,
    customer_segment,
    Repeat_Buyer,
    COUNT(DISTINCT customer_id) AS Total_Customers,
    AVG(Purchase_Frequency) AS Average_Purchase_Frequency
FROM master_df
GROUP BY
    Category_name,
    customer_segment,
    Repeat_Buyer;
select * from vw_customer_retention;
select count(*) from vw_customer_retention;
