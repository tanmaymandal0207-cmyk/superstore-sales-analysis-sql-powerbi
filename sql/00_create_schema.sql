/* =====================================================================
   00 · CREATE SCHEMA
   Project : Superstore Sales Analysis (SQL + Power BI)
   Author  : Tanmay Mandal
   Engine  : MySQL 8.0  (also tested on MariaDB 10.11)
   Purpose : Raw landing tables. Dates are kept as text exactly as they
             arrive in the CSV (dd-mm-yyyy); typed dates are derived in
             03_data_cleaning.sql so the raw load is never modified.
   ===================================================================== */

CREATE DATABASE IF NOT EXISTS superstore;
USE superstore;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

-- One row per customer (source may contain repeats; see 02_data_quality_checks.sql)
CREATE TABLE customers (
    customer_id    VARCHAR(20)  NOT NULL,
    customer_name  VARCHAR(100),
    segment        VARCHAR(30),
    country        VARCHAR(50),
    city           VARCHAR(60),
    state          VARCHAR(60),
    region         VARCHAR(20),
    INDEX idx_customers_id (customer_id)
) DEFAULT CHARSET = utf8mb4;

-- One row per product (source may contain repeats; see 02_data_quality_checks.sql)
CREATE TABLE products (
    product_id     VARCHAR(20)  NOT NULL,
    product_name   VARCHAR(255),
    category       VARCHAR(40),
    sub_category   VARCHAR(40),
    INDEX idx_products_id (product_id)
) DEFAULT CHARSET = utf8mb4;

-- One row per order line (an order_id can span several products)
CREATE TABLE orders (
    order_id       VARCHAR(20)  NOT NULL,
    order_date     VARCHAR(10),          -- raw text, dd-mm-yyyy
    ship_date      VARCHAR(10),          -- raw text, dd-mm-yyyy
    ship_mode      VARCHAR(20),
    customer_id    VARCHAR(20)  NOT NULL,
    product_id     VARCHAR(20)  NOT NULL,
    sales          DECIMAL(12,4),
    quantity       INT,
    discount       DECIMAL(4,2),
    profit         DECIMAL(12,4),
    INDEX idx_orders_order    (order_id),
    INDEX idx_orders_customer (customer_id),
    INDEX idx_orders_product  (product_id)
) DEFAULT CHARSET = utf8mb4;
