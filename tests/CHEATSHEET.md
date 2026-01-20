# SQL Testing Cheat Sheet

Quick reference for common SQL testing patterns.

## Import Statements

```python
import pytest
from tests.test_helpers import QueryTestHelper
```

## Basic Test Structure

```python
@pytest.mark.integration
class TestMyQuery:
    def test_something(self, query_executor):
        query = "SELECT * FROM table;"
        results = query_executor(query)
        assert results is not None
```

## Running Tests

```bash
pytest tests/                           # Run all tests
pytest tests/test_file.py              # Run one file
pytest tests/test_file.py::TestClass   # Run one class
pytest tests/ -v                       # Verbose output
pytest tests/ -k "keyword"             # Match keyword
pytest tests/ -x                       # Stop on first failure
pytest tests/ --pdb                    # Debug on failure
```

## Query Executor vs Query Runner

```python
# Execute query string directly
def test_with_executor(self, query_executor):
    results = query_executor("SELECT * FROM customer;")

# Load and execute query from file
def test_with_runner(self, query_runner):
    results = query_runner('queries/001_my_query.sql')
```

## Common Assertions

### Row Count
```python
# Exact count
QueryTestHelper.assert_row_count(results, 10)

# Greater than
QueryTestHelper.assert_row_count(results, 5, operator='>')

# Less than
QueryTestHelper.assert_row_count(results, 100, operator='<')

# Greater than or equal
QueryTestHelper.assert_row_count(results, 10, operator='>=')

# Less than or equal
QueryTestHelper.assert_row_count(results, 50, operator='<=')
```

### Column Count
```python
# Check number of columns
QueryTestHelper.assert_column_count(results, 5)
```

### NULL Checks
```python
# Column 0 should have no NULLs
QueryTestHelper.assert_no_nulls(results, 0)

# Check multiple columns
QueryTestHelper.assert_no_nulls(results, 0)
QueryTestHelper.assert_no_nulls(results, 1)
QueryTestHelper.assert_no_nulls(results, 2)
```

### Unique Values
```python
# Column 0 should have all unique values (e.g., ID column)
QueryTestHelper.assert_unique_values(results, 0)
```

### Sorting
```python
# Ascending order (default)
QueryTestHelper.assert_sorted(results, column_index=1)

# Descending order
QueryTestHelper.assert_sorted(results, column_index=1, descending=True)
```

### Value Contains
```python
# Check if value exists in column
QueryTestHelper.assert_contains_value(results, column_index=0, value='USA')
```

### Custom Conditions
```python
# All values in column 2 should be positive
QueryTestHelper.assert_all_match_condition(
    results,
    column_index=2,
    condition=lambda x: x > 0
)

# All values in column 3 should start with 'A'
QueryTestHelper.assert_all_match_condition(
    results,
    column_index=3,
    condition=lambda x: x.startswith('A')
)

# All values should be in a set
QueryTestHelper.assert_all_match_condition(
    results,
    column_index=4,
    condition=lambda x: x in {'active', 'pending', 'completed'}
)
```

### Numeric Range
```python
# Column 3 should be between 0 and 1000
QueryTestHelper.assert_numeric_range(
    results,
    column_index=3,
    min_value=0,
    max_value=1000
)

# Only minimum
QueryTestHelper.assert_numeric_range(
    results,
    column_index=3,
    min_value=0
)

# Only maximum
QueryTestHelper.assert_numeric_range(
    results,
    column_index=3,
    max_value=1000
)
```

## Manual Assertions

### Basic Checks
```python
# Not None
assert results is not None

# Has data
assert len(results) > 0

# Exact length
assert len(results) == 10

# Empty
assert len(results) == 0
assert results == []
```

### Column Access
```python
# Access by index (0-based)
first_row = results[0]
customer_id = first_row[0]
first_name = first_row[1]
last_name = first_row[2]

# Iterate rows
for row in results:
    assert row[0] is not None  # Check ID not null
    assert row[1] != ''        # Check name not empty
```

### Check All Rows
```python
# All countries should be 'USA'
for row in results:
    assert row[7] == 'USA'

# All amounts should be positive
for row in results:
    assert row[3] > 0

# All emails should contain '@'
for row in results:
    assert '@' in row[4]
```

### List Comprehensions
```python
# Extract column values
customer_ids = [row[0] for row in results]
countries = [row[7] for row in results]

# Check uniqueness
assert len(customer_ids) == len(set(customer_ids))

# Check all positive
assert all(amount > 0 for amount in amounts)

# Check sorting
amounts = [row[3] for row in results]
assert amounts == sorted(amounts, reverse=True)
```

## Testing Specific SQL Patterns

### SELECT with WHERE
```python
def test_filter(self, query_executor):
    results = query_executor(
        "SELECT * FROM customer WHERE country = 'Germany';"
    )
    for row in results:
        assert row[7] == 'Germany'
```

### JOIN
```python
def test_join(self, query_executor):
    results = query_executor("""
        SELECT c.customer_id, i.invoice_id
        FROM customer c
        INNER JOIN invoice i ON c.customer_id = i.customer_id;
    """)
    QueryTestHelper.assert_no_nulls(results, 0)
    QueryTestHelper.assert_no_nulls(results, 1)
```

### GROUP BY
```python
def test_group_by(self, query_executor):
    results = query_executor("""
        SELECT country, COUNT(*) as cnt
        FROM customer
        GROUP BY country;
    """)
    QueryTestHelper.assert_all_match_condition(
        results, 1, lambda x: x > 0
    )
```

### ORDER BY
```python
def test_order_by(self, query_executor):
    results = query_executor("""
        SELECT * FROM customer ORDER BY last_name;
    """)
    QueryTestHelper.assert_sorted(results, 2)  # last_name column
```

### LIMIT
```python
def test_limit(self, query_executor):
    results = query_executor("SELECT * FROM customer LIMIT 5;")
    QueryTestHelper.assert_row_count(results, 5, operator='<=')
```

### DISTINCT
```python
def test_distinct(self, query_executor):
    results = query_executor("""
        SELECT DISTINCT country FROM customer;
    """)
    countries = [row[0] for row in results]
    assert len(countries) == len(set(countries))
```

### Aggregate Functions
```python
def test_sum(self, query_executor):
    results = query_executor("""
        SELECT SUM(total) FROM invoice;
    """)
    assert results[0][0] > 0

def test_avg(self, query_executor):
    results = query_executor("""
        SELECT AVG(total) FROM invoice;
    """)
    assert results[0][0] > 0

def test_count(self, query_executor):
    results = query_executor("""
        SELECT COUNT(*) FROM customer;
    """)
    assert results[0][0] > 0
```

### Subqueries
```python
def test_subquery(self, query_executor):
    results = query_executor("""
        SELECT * FROM customer
        WHERE customer_id IN (
            SELECT customer_id FROM invoice WHERE total > 10
        );
    """)
    QueryTestHelper.assert_row_count(results, 0, operator='>')
```

## Test Organization

### File Naming
```
test_001_select_filters.py      # Matches query file number
test_002_distinct_counts.py
test_my_feature.py              # Descriptive name
```

### Class Naming
```python
class TestSelectFilters:        # Descriptive class name
class TestDistinctCounts:
class TestTopCustomers:
```

### Method Naming
```python
def test_query_returns_results(self):
def test_filter_by_country_works(self):
def test_no_null_in_required_fields(self):
def test_results_sorted_correctly(self):
```

## Markers

```python
# Mark as integration test
@pytest.mark.integration
class TestMyQuery:
    pass

# Mark as slow test
@pytest.mark.slow
def test_complex_query(self):
    pass

# Mark as smoke test
@pytest.mark.smoke
def test_basic_functionality(self):
    pass
```

## Common Patterns

### Test Query Runs Successfully
```python
def test_query_runs(self, query_executor):
    results = query_executor("SELECT * FROM customer;")
    assert results is not None
```

### Test Returns Data
```python
def test_has_data(self, query_executor):
    results = query_executor("SELECT * FROM customer;")
    QueryTestHelper.assert_row_count(results, 0, operator='>')
```

### Test Empty Result
```python
def test_empty_result(self, query_executor):
    results = query_executor(
        "SELECT * FROM customer WHERE customer_id = -999;"
    )
    assert results == []
```

### Test Specific Value
```python
def test_contains_value(self, query_executor):
    results = query_executor("SELECT country FROM customer;")
    countries = [row[0] for row in results]
    assert 'USA' in countries
```

## Environment Variables

```bash
# Set for single command
PGHOST=localhost PGPORT=5432 pytest tests/

# Or export
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=chinook
export PGUSER=postgres
export PGPASSWORD=mypassword
```

## Useful Options

```bash
pytest tests/ -v              # Verbose
pytest tests/ -s              # Show print statements
pytest tests/ -x              # Stop on first failure
pytest tests/ --tb=short      # Short traceback
pytest tests/ --tb=long       # Long traceback
pytest tests/ --pdb           # Debug on failure
pytest tests/ -l              # Show local variables
pytest tests/ --durations=10  # Show 10 slowest tests
pytest tests/ -k "select"     # Run tests matching keyword
pytest tests/ -m integration  # Run tests with marker
```

## Quick Copy-Paste Templates

### Minimal Test
```python
@pytest.mark.integration
class TestMyQuery:
    def test_it_works(self, query_executor):
        results = query_executor("SELECT * FROM customer;")
        assert results is not None
        QueryTestHelper.assert_row_count(results, 0, operator='>')
```

### Complete Test
```python
@pytest.mark.integration
class TestMyQuery:
    def test_returns_correct_structure(self, query_executor):
        results = query_executor("SELECT id, name, price FROM products;")
        QueryTestHelper.assert_column_count(results, 3)
        QueryTestHelper.assert_no_nulls(results, 0)
        QueryTestHelper.assert_row_count(results, 0, operator='>')
```

### Filter Test
```python
def test_filter_works(self, query_executor):
    results = query_executor(
        "SELECT * FROM customer WHERE country = 'USA';"
    )
    for row in results:
        assert row[7] == 'USA'
```
