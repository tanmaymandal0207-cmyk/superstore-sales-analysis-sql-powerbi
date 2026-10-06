/* =====================================================================
   01 · LOAD DATA
   Loads the three CSV extracts into the raw tables.
   Alternative: MySQL Workbench → right-click table → Table Data Import Wizard.

   Requires:  SET GLOBAL local_infile = 1;   (server)
              --local-infile=1                (client)
   Replace <path> with the folder that holds the CSV files.
   ===================================================================== */

USE superstore;

LOAD DATA LOCAL INFILE '<path>/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(customer_id, customer_name, segment, country, city, state, region);

LOAD DATA LOCAL INFILE '<path>/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_name, category, sub_category);

LOAD DATA LOCAL INFILE '<path>/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, order_date, ship_date, ship_mode, customer_id, product_id,
 sales, quantity, discount, profit);

-- Validation: row counts after load
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders',   COUNT(*) FROM orders;
