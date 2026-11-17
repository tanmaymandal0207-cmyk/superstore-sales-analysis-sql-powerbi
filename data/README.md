# Data

The data is **not stored in this repository** (`*.csv` is in `.gitignore`). The project uses three CSV extracts split from the public **Superstore** sample dataset, which remains the property of its original publisher.

## Expected files

Put all three files in one folder and replace `<path>` in [`../sql/01_load_data.sql`](../sql/01_load_data.sql) with that folder's path.

| File | Loads into | Columns, in order |
|---|---|---|
| `customers.csv` | `customers` | `customer_id, customer_name, segment, country, city, state, region` |
| `products.csv` | `products` | `product_id, product_name, category, sub_category` |
| `orders.csv` | `orders` | `order_id, order_date, ship_date, ship_mode, customer_id, product_id, sales, quantity, discount, profit` |

Each file has one header row (skipped on load), comma-separated, with text fields optionally quoted.

## Load checks

1. MySQL needs `local_infile` on: `SET GLOBAL local_infile = 1;` on the server and `--local-infile=1` on the client. Or use MySQL Workbench's *Table Data Import Wizard*.
2. `01_load_data.sql` ends with a row count per table. Compare it with the row counts in the source files before running anything else.
3. Run [`02_data_quality_checks.sql`](../sql/02_data_quality_checks.sql) next: duplicates, orphan keys, nulls, unparseable dates and value ranges are checked before cleaning.

Known issue: the source is Windows-1252 but is read as UTF-8, so some product names can show garbled characters (listed in the README roadmap as a v2 fix).
