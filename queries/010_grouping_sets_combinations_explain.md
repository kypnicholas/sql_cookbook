# Grouping combinations: ROLLUP, CUBE, GROUPING SETS

Columns (left → right): `month`, `country`, `state`

`GROUPING(expr)` returns 1 when `expr` was rolled-up (suppressed) in that grouping row, 0 otherwise.
We show each grouping set and the corresponding `GROUPING(...)` vector as (month, country, state).

## ROLLUP(month, country, state)
- (month, country, state) — detail rows
  - GROUPING: (0,0,0)
- (month, country) — `state` rolled up (subtotal per month+country)
  - GROUPING: (0,0,1)
- (month) — `country`+`state` rolled up (subtotal per month across all countries/states)
  - GROUPING: (0,1,1)
- () — grand total (everything rolled up)
  - GROUPING: (1,1,1)

## CUBE(month, country, state) — all combinations (2^3 = 8)
- (month, country, state)
  - GROUPING: (0,0,0)
- (month, country)
  - GROUPING: (0,0,1)
- (month, state)
  - GROUPING: (0,1,0)
- (country, state)
  - GROUPING: (1,0,0)
- (month)
  - GROUPING: (0,1,1)
- (country)
  - GROUPING: (1,0,1)
- (state)
  - GROUPING: (1,1,0)
- () — grand total
  - GROUPING: (1,1,1)

## GROUPING SETS (example used in the queries file)
The file's GROUPING SETS list:

```
(date_trunc('month', inv.invoice_date), c.country, c.state),  -- detail
(date_trunc('month', inv.invoice_date), c.country),          -- month+country subtotal
(date_trunc('month', inv.invoice_date)),                     -- month subtotal
(c.country, c.state),                                         -- country+state subtotal
(c.country),                                                  -- country subtotal
()                                                             -- grand total
```

These produce exactly the listed grouping rows (order from the list; SQL may return rows in a different order):
- (month, country, state) — GROUPING: (0,0,0)
- (month, country)       — GROUPING: (0,0,1)
- (month)               — GROUPING: (0,1,1)
- (country, state)      — GROUPING: (1,0,0)
- (country)             — GROUPING: (1,0,1)
- ()                    — GROUPING: (1,1,1)

## Notes & detection examples
- Use `GROUPING(expr)` per column to label subtotal rows (as in the queries file):

```sql
CASE WHEN GROUPING(date_trunc('month', inv.invoice_date)) = 1 THEN 'All months'
     ELSE to_char(date_trunc('month', inv.invoice_date), 'YYYY-MM') END AS month_label
```

- `GROUPING_ID(a,b,c)` returns a bitmask integer encoding which columns were rolled up — useful for filtering specific subtotal rows.

Example: filter only month subtotals (month present, country+state rolled up) in a GROUPING SETS/ROLLUP result:

```sql
WHERE GROUPING(date_trunc('month', inv.invoice_date)) = 0
  AND GROUPING(c.country) = 1
  AND GROUPING(c.state) = 1
```
