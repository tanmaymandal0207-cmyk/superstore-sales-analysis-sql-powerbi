# Model Review & v2 Roadmap

[← Back to README](../README.md)

A self-audit of the data, the SQL and the Power BI model. Every number was reproduced from the model's data with the scripts in [`sql/`](../sql/).

---

## 1. Data-quality findings

| # | Finding | Evidence | Impact | Fix |
|---|---|---|---|---|
| D1 | **Broken customer header** | The extract's header contains a line break: `segment<CR><LF>country`. Power Query typed it as a whole number. | Segment and country are lost, so no Consumer / Corporate / Home Office analysis is possible | Re-export `customers.csv` with clean headers, then split into `segment` and `country` |
| D2 | **Encoding mismatch** | 56 product names contain `�` (e.g. *Hon 2090 �Pillow Soft� …*). Products are read as UTF-8 (65001) while the source is Windows-1252. | Unreadable labels in tables | Set `Encoding = 1252` on the products query, or re-save the CSV as UTF-8 |
| D3 | Exact duplicate order lines | 2 lines (`CA-2023-153623`, `US-2023-150119`), see SQL `02` check 3 | +$380 sales, +$23 profit | Keep for reconciliation; flag or remove in v2 |
| D4 | **Names are not unique keys** | 1 customer name → 5 IDs; 17 product names → several product IDs | Grouping by name merges different customers and products | All v2 SQL groups by ID ✅ |

---

## 2. Dashboard & model findings

| # | Area | Observation | Fix |
|---|---|---|---|
| R1 | **Total Orders / AOV** | `COUNT(order_id)` counts order **lines**: the card shows "10K" against 5,111 real orders, and AOV shows $228 against a true **$455**. | `DISTINCTCOUNT` (below) |
| R2 | **YoY cards with Year = All** | `SAMEPERIODLASTYEAR` over the full 2023–2026 range compares all four years with 2023–2025 only. That produces the +47.2% sales badge; the real latest-year growth is **+21.4%** (2026 vs 2025). | Pin the comparison to the latest selected year |
| R3 | Mislabelled visual | Donut titled **"Sales — contribution by category"** plots **Total Profit**. | Rename to "Profit by category", or switch the value to Total Sales |
| R4 | Aggregation of rates | The Report table uses **Sum of discount** (values like 2.20 = 220%). Profit Margin and Loss % show as decimals (0.43, −0.05). | Use `Avg Discount`; set percentage format strings |
| R5 | Unsupported claim | Report text: "Top 5 products drive majority of total loss". The top 5 loss products are **28.6%** of total product losses (22% within Furniture). | Reword to "Losses are spread across 299 products; Furniture alone accounts for 48%" |
| R6 | Measure hygiene | `Proft Margin`, `Profit Margin` and `Profit Per Sale` are identical; the "Proft" typo shows on a card; measures are spread across 3 home tables. | Keep one `Profit Margin`; move all measures to a `_Measures` table |
| R7 | Date handling | Auto date/time is on (4 hidden local date tables), and visuals use the `order_date` hierarchy while YoY measures use `Date` via `order_date_clean`. | Turn off auto date/time, mark `Date` as a date table, and use `Date` columns on every axis |

### Corrected DAX (v2)

```DAX
-- R1: count orders, not lines
Total Orders = DISTINCTCOUNT ( orders[order_id] )

Average Order Value = DIVIDE ( [Total Sales], [Total Orders] )
```

```DAX
-- R2: latest selected year vs the year before, regardless of how many years are selected
Sales YoY % =
VAR LatestYear = CALCULATE ( MAX ( 'Date'[Year] ), ALLSELECTED ( 'Date' ) )
VAR CY = CALCULATE ( [Total Sales], 'Date'[Year] = LatestYear )
VAR PY = CALCULATE ( [Total Sales], 'Date'[Year] = LatestYear - 1 )
RETURN
    DIVIDE ( CY - PY, PY )
```

```DAX
-- R4: average, not sum, of a rate
Avg Discount = AVERAGE ( orders[discount] )      -- format string: 0.0%
```

---

## 3. Validation checklist (run after each refresh)

| Check | Expected |
|---|---|
| Power BI `Total Sales` = SQL `04` total | $2,326,534.45 |
| `Total Orders` = SQL distinct orders | 5,111 |
| Orders rows = source CSV rows | 10,194 |
| Unmatched customer / product keys | 0 |
| Product names containing `�` | 0 |
