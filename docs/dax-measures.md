# DAX Measures

[← Back to README](../README.md)

27 measures in 4 groups. Measures currently live in several home tables (`customers`, `orders`, `Date`); v2 moves them into one `_Measures` table.

## Contents

- [Core KPIs](#core-kpis)
- [Year-over-Year](#year-over-year)
- [Loss analysis](#loss-analysis)
- [Ranking & formatting](#ranking--formatting)

---

## Core KPIs

| Measure | Home table | Purpose |
|---|---|---|
| `Total Sales` | customers | Sum of line sales. |
| `Total Profit` | customers | Sum of line profit. |
| `Total Orders` | customers | Count of order **lines** (see [model-review](model-review.md#2-dashboard--model-findings)). |
| `Average Order Value` | customers | Sales ÷ Total Orders. |
| `Profit Margin` | customers | Profit ÷ sales. |
| `Proft Margin` | customers | Duplicate of Profit Margin (used on cards). |
| `Profit Per Sale` | customers | Duplicate of Profit Margin. |
| `Avg Discount` | customers | Simple average of line discount. |

### Total Sales

```DAX
Total Sales =
SUM(orders[sales])
```

### Total Profit

```DAX
Total Profit =
SUM(orders[profit])
```

### Total Orders

```DAX
Total Orders =
COUNT(orders[order_id])
```

### Average Order Value

```DAX
Average Order Value =
DIVIDE([Total Sales],[Total Orders])
```

### Profit Margin

```DAX
Profit Margin =
DIVIDE(SUM(orders[profit]),SUM(orders[sales]))
```

### Proft Margin

```DAX
Proft Margin =
DIVIDE([Total Profit], [Total Sales])
```

### Profit Per Sale

```DAX
Profit Per Sale =
DIVIDE(SUM(orders[profit]),SUM(orders[sales]))
```

### Avg Discount

```DAX
Avg Discount =
AVERAGE(orders[discount])
```

---

## Year-over-Year

Pattern per KPI: *PY* value → *YoY %* → formatted display text with ▲/▼ for the KPI cards.

| Measure | Home table | Purpose |
|---|---|---|
| `Sales PY` | customers | Sales for the same period last year. |
| `YoY%` | customers | Sales growth vs PY; blank when PY is 0. |
| `YoY Indicator` | customers | ▲ / ▼ / — arrow. |
| `YoY Growth` | Date | Arrow + formatted %. |
| `Profit margin py` | Date | — |
| `Margin change` | Date | Margin points vs PY. |
| `Margin Display` | Date | — |
| `Profit PY` | orders | — |
| `Profit YoY %` | orders | — |
| `Profit YoY Display` | orders | — |
| `Orders PY` | orders | — |
| `Orders YoY %` | orders | — |
| `Orders YoY Display` | orders | — |

### Sales PY

```DAX
Sales PY =
CALCULATE([Total Sales],SAMEPERIODLASTYEAR('Date'[Date]))
```

### YoY%

```DAX
YoY% =
IF(
        [Sales PY] = 0,
        blank(),
        DIVIDE([Total Sales]-[Sales PY],[Sales PY])
)
```

### YoY Indicator

```DAX
YoY Indicator =
IF(
    [YoY%] > 0, "▲",
    IF([YoY%] < 0, "▼", "—")
)
```

### YoY Growth

```DAX
YoY Growth =
VAR yoy = [YoY%]
VAR arrow = [YoY Indicator]
RETURN
IF(
    ISBLANK(yoy),
    BLANK(),
    arrow & " " & FORMAT(yoy, "0.0%")
)
```

### Profit margin py

```DAX
Profit margin py =
CALCULATE([Profit Margin],SAMEPERIODLASTYEAR('Date'[Date]))
```

### Margin change

```DAX
Margin change =
[Profit Margin] - [Profit margin py]
```

### Margin Display

```DAX
Margin Display =
VAR change = [Margin change]
RETURN
IF(
    ISBLANK(change),
    BLANK(),
    IF(change > 0, "▲ ", "▼ ") & FORMAT(change, "0.0%")
)
```

### Profit PY

```DAX
Profit PY =
CALCULATE(
    [Total Profit],
    SAMEPERIODLASTYEAR('Date'[Date].[Date])
)
```

### Profit YoY %

```DAX
Profit YoY % =
DIVIDE([Total Profit] - [Profit PY], [Profit PY])
```

### Profit YoY Display

```DAX
Profit YoY Display =
VAR yoy = [Profit YoY %]
RETURN
IF(
    ISBLANK(yoy),
    BLANK(),
    IF(yoy > 0, "▲ ", "▼ ") & FORMAT(yoy, "0.0%")
)
```

### Orders PY

```DAX
Orders PY =
CALCULATE(
    [Total Orders],
    SAMEPERIODLASTYEAR('Date'[Date])
)
```

### Orders YoY %

```DAX
Orders YoY % =
DIVIDE([Total Orders] - [Orders PY], [Orders PY])
```

### Orders YoY Display

```DAX
Orders YoY Display =
VAR yoy = [Orders YoY %]
RETURN
IF(
    ISBLANK(yoy),
    BLANK(),
    IF(yoy > 0, "▲ ", "▼ ") & FORMAT(yoy, "0.0%")
)
```

---

## Loss analysis

Drive the Analytics page.

| Measure | Home table | Purpose |
|---|---|---|
| `Total Loss` | Date | Sum of profit over products whose net profit is negative. |
| `Loss %` | Date | Total Loss ÷ Total Sales. |
| `Loss Products` | Date | Number of products with negative net profit. |
| `Loss Rank` | Date | Dense rank of loss-making products, worst first. |

### Total Loss

```DAX
Total Loss =
SUMX(
    FILTER(
        VALUES(orders[product_id]),
        [Total Profit] < 0
    ),
    [Total Profit]
)
```

### Loss %

```DAX
Loss % =
DIVIDE([Total Loss], [Total Sales])
```

### Loss Products

```DAX
Loss Products =
COUNTROWS(
    FILTER(
        VALUES(orders[product_id]),
        [Total Profit] < 0
    )
)
```

### Loss Rank

```DAX
Loss Rank =
VAR CurProfit = [Total Profit]
RETURN
IF(
    CurProfit < 0,
    RANKX(
        FILTER(
            ALLSELECTED(orders[product_id]),
            CALCULATE([Total Profit]) < 0
        ),
        CALCULATE([Total Profit]),
        ,
        ASC,
        DENSE
    )
)
```

---

## Ranking & formatting

| Measure | Home table | Purpose |
|---|---|---|
| `Product Rank` | customers | Product rank by sales. |
| `Quadrant Color` | Date | Hex colour for the discount-vs-profit scatter: green / yellow / orange / red by profit sign and a 15% discount threshold. |

### Product Rank

```DAX
Product Rank =
RANKX(
    ALL(products[Product_name]),
    [Total Sales],
    ,
    DESC
)
```

### Quadrant Color

```DAX
Quadrant Color =
VAR Profit = [Total Profit]
VAR Discount = AVERAGE(orders[discount])

RETURN
SWITCH(
    TRUE(),
    Profit >= 0 && Discount < 0.15, "#00B050",   -- Green
    Profit >= 0 && Discount >= 0.15, "#FFC000", -- Yellow
    Profit < 0 && Discount < 0.15, "#ED7D31",   -- Orange
    Profit < 0 && Discount >= 0.15, "#C00000"   -- Red
)
```

---

> Table names are shortened here (`orders`, `customers`, `products`); in the model they carry an import timestamp suffix, e.g. `orders_202604191948`.
