# Query Test Report

Generated: 2026-05-19T08:43:50.434327+00:00
Total: 19  
Passed: 18  
Failed: 1

| Task | Query File | Result |
|---|---|---|
| A1 | queries/001_select_filters.pgsql | PASS |
| A2 | queries/002_distinct_counts.pgsql | PASS |
| A3 | queries/003_pagination.pgsql | PASS |
| A4 | queries/004_casts_formatting.pgsql | PASS |
| B5 | queries/005_joins_basic.pgsql | PASS |
| B6 | queries/006_many_to_many.pgsql | PASS |
| B7 | queries/007_anti_join.pgsql | PASS |
| B7-SUP | queries/007_anti_join_perf.pgsql | FAIL |
| B8 | queries/008_semi_join.pgsql | PASS |
| C9 | queries/009_group_by.pgsql | PASS |
| C10 | queries/010_grouping_sets.pgsql | PASS |
| C11 | queries/011_filter_aggregates.pgsql | PASS |
| C12 | queries/012_percentiles.pgsql | PASS |
| D13 | queries/013_rank_window.pgsql | PASS |
| D14 | queries/014_lag_lead.pgsql | PASS |
| D15 | queries/015_running_totals.pgsql | PASS |
| D16 | queries/016_window_percentiles.pgsql | PASS |
| E17 | queries/017_standalone_cte.pgsql | PASS |
| E18 | queries/018_recursive_cte.pgsql | PASS |

## A1 - Simple SELECTs and filters (PASS)

File: `queries/001_select_filters.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=6/6 |
| min_successful_statements | PASS | successful=6, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['country', 'filter'] |
| deliverable_keyword:deliverable_2 | PASS | found=['numeric', 'filter'] |
| deliverable_keyword:deliverable_3 | PASS | found=['case', 'insensitive', 'text', 'search'] |
| a1_base_tables_have_rows | PASS | first_col=True |
| a1_country_filter_has_german_customers | PASS | first_col=True |
| a1_country_projection_columns_populated | PASS | first_col=True |
| a1_numeric_filter_has_invoices_over_5 | PASS | first_col=True |
| a1_text_search_ilike_has_love_tracks | PASS | first_col=True |

## A2 - DISTINCT and COUNT(DISTINCT) (PASS)

File: `queries/002_distinct_counts.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=4/4 |
| min_successful_statements | PASS | successful=4, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['distinct', 'billing', 'countries'] |
| deliverable_keyword:deliverable_2 | PASS | found=['distinct', 'genres'] |
| deliverable_keyword:deliverable_3 | PASS | found=['email', 'uniqueness', 'check'] |
| override_me | PASS | Skipped (enabled=false) |

## A3 - Pagination and keyset patterns (PASS)

File: `queries/003_pagination.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=5/5 |
| min_successful_statements | PASS | successful=5, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['offset', 'example'] |
| deliverable_keyword:deliverable_2 | PASS | found=['keyset', 'example'] |
| deliverable_keyword:deliverable_3 | PASS | found=['date', 'based', 'page', 'example'] |
| override_me | PASS | Skipped (enabled=false) |

## A4 - Casting and formatting (PASS)

File: `queries/004_casts_formatting.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=3/3 |
| min_successful_statements | PASS | successful=3, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['integer', 'cast'] |
| deliverable_keyword:deliverable_2 | PASS | found=['currency', 'formatting'] |
| deliverable_keyword:deliverable_3 | PASS | found=['milliseconds', 'minutes', 'seconds', 'conversion'] |
| override_me | PASS | Skipped (enabled=false) |

## B5 - Basic joins (PASS)

File: `queries/005_joins_basic.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=3/3 |
| min_successful_statements | PASS | successful=3, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['track', 'album', 'artist', 'join'] |
| deliverable_keyword:deliverable_2 | PASS | found=['albums', 'without', 'tracks'] |
| deliverable_keyword:deliverable_3 | PASS | found=['grouped', 'join', 'summary'] |
| override_me | PASS | Skipped (enabled=false) |

## B6 - Many-to-many joins (PASS)

File: `queries/006_many_to_many.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=3/3 |
| min_successful_statements | PASS | successful=3, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['playlist', 'track', 'listing'] |
| deliverable_keyword:deliverable_2 | PASS | found=['multi', 'playlist', 'track', 'detection'] |
| deliverable_keyword:deliverable_3 | PASS | found=['aggregated', 'playlist', 'names'] |
| override_me | PASS | Skipped (enabled=false) |

## B7 - Anti-join patterns (PASS)

File: `queries/007_anti_join.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=4/4 |
| min_successful_statements | PASS | successful=4, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['left', 'join', 'null', 'not'] |
| override_me | PASS | Skipped (enabled=false) |

## B7-SUP - Anti-join performance comparison (FAIL)

File: `queries/007_anti_join_perf.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | FAIL | successful=0/1 |
| min_successful_statements | FAIL | successful=0, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['explain', 'analyze', 'runs', 'planning'] |
| override_me | PASS | Skipped (enabled=false) |

### Failed Statements

- statement #1: VACUUM cannot run inside a transaction block

## B8 - Semi-join patterns (PASS)

File: `queries/008_semi_join.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=5/5 |
| min_successful_statements | PASS | successful=5, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['sold', 'artists', 'via', 'exists'] |
| deliverable_keyword:deliverable_2 | PASS | found=['duplicate', 'prone', 'join', 'example'] |
| deliverable_keyword:deliverable_3 | PASS | found=['deduplicated', 'alternatives'] |
| override_me | PASS | Skipped (enabled=false) |

## C9 - GROUP BY and HAVING basics (PASS)

File: `queries/009_group_by.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=3/3 |
| min_successful_statements | PASS | successful=3, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['revenue', 'per', 'customer'] |
| deliverable_keyword:deliverable_2 | PASS | found=['orders', 'per', 'country'] |
| deliverable_keyword:deliverable_3 | PASS | found=['genre', 'revenue', 'having', 'threshold'] |
| override_me | PASS | Skipped (enabled=false) |

## C10 - ROLLUP, GROUPING SETS, and CUBE (PASS)

File: `queries/010_grouping_sets.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=4/4 |
| min_successful_statements | PASS | successful=4, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['one', 'rollup'] |
| deliverable_keyword:deliverable_2 | PASS | found=['one', 'cube'] |
| deliverable_keyword:deliverable_3 | PASS | found=['one', 'grouping', 'sets', 'example'] |
| override_me | PASS | Skipped (enabled=false) |

## C11 - FILTER aggregates (PASS)

File: `queries/011_filter_aggregates.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=3/3 |
| min_successful_statements | PASS | successful=3, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['where', 'filter', 'comparison', 'conditional'] |
| override_me | PASS | Skipped (enabled=false) |

## C12 - Percentiles and distribution (PASS)

File: `queries/012_percentiles.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=4/4 |
| min_successful_statements | PASS | successful=4, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['quartile', 'assignment'] |
| deliverable_keyword:deliverable_2 | PASS | found=['quartile', 'summary'] |
| deliverable_keyword:deliverable_3 | PASS | found=['percentile', 'cut', 'points'] |
| override_me | PASS | Skipped (enabled=false) |

## D13 - ROW_NUMBER, RANK, DENSE_RANK (PASS)

File: `queries/013_rank_window.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=3/3 |
| min_successful_statements | PASS | successful=3, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['top', 'selling', 'track', 'per'] |
| override_me | PASS | Skipped (enabled=false) |

## D14 - LAG and LEAD (PASS)

File: `queries/014_lag_lead.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=2/2 |
| min_successful_statements | PASS | successful=2, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['days', 'since', 'prior', 'invoice'] |
| override_me | PASS | Skipped (enabled=false) |

## D15 - Running totals and rolling windows (PASS)

File: `queries/015_running_totals.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=3/3 |
| min_successful_statements | PASS | successful=3, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['running', 'total', 'per', 'customer'] |
| override_me | PASS | Skipped (enabled=false) |

## D16 - Window percentiles and distributions (PASS)

File: `queries/016_window_percentiles.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=2/2 |
| min_successful_statements | PASS | successful=2, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['customer', 'spend', 'percentile', 'ranking'] |
| override_me | PASS | Skipped (enabled=false) |

## E17 - Standalone and dependent CTEs (PASS)

File: `queries/017_standalone_cte.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=1/1 |
| min_successful_statements | PASS | successful=1, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['trackartist', 'cte'] |
| deliverable_keyword:deliverable_2 | PASS | found=['artistsales', 'cte'] |
| deliverable_keyword:deliverable_3 | PASS | found=['final', 'ordered', 'output'] |
| override_me | PASS | Skipped (enabled=false) |

## E18 - Recursive CTE management chain (PASS)

File: `queries/018_recursive_cte.pgsql`

### Checks

| Check | Result | Details |
|---|---|---|
| must_execute | PASS | successful=1/1 |
| min_successful_statements | PASS | successful=1, required=1 |
| deliverable_keyword:deliverable_1 | PASS | found=['employee_id'] |
| deliverable_keyword:deliverable_2 | PASS | found=['reports_to'] |
| deliverable_keyword:deliverable_3 | PASS | found=['level'] |
| deliverable_keyword:deliverable_4 | PASS | found=['name', 'title', 'path', 'output'] |
| override_me | PASS | Skipped (enabled=false) |

