# Quick Start Guide: SQL Query Testing

This guide helps you quickly start writing tests for your SQL queries.

## 5-Minute Setup

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Set Environment Variables
```bash
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=chinook
export PGUSER=postgres
export PGPASSWORD=your_password
```

### 3. Run Tests
```bash
pytest tests/ -v
```

## Writing Your First Test

### Step 1: Create Your SQL Query
Create a file `queries/004_my_query.pgsql`:
```sql
-- Get all customers from a specific country
SELECT customer_id, first_name, last_name, email, country
FROM customer
WHERE country = 'USA'
ORDER BY last_name;
```

### Step 2: Create Test File
Create `tests/test_004_my_query.py`:
```python
import pytest
from tests.test_helpers import QueryTestHelper

@pytest.mark.integration
class TestMyQuery:
    def test_usa_customers(self, query_executor):
        """Test getting USA customers."""
        query = """
            SELECT customer_id, first_name, last_name, email, country
            FROM customer
            WHERE country = 'USA'
            ORDER BY last_name;
        """
        results = query_executor(query)
        
        # Basic checks
        assert results is not None
        QueryTestHelper.assert_row_count(results, 0, operator='>')
        QueryTestHelper.assert_column_count(results, 5)
        
        # Verify all are from USA (country is column index 4)
        for row in results:
            assert row[4] == 'USA'
        
        # Verify sorted by last name (column index 2)
        QueryTestHelper.assert_sorted(results, 2)
```

### Step 3: Run Your Test
```bash
pytest tests/test_004_my_query.py -v
```

## Common Test Patterns

### Pattern 1: Test Query Execution
```python
def test_query_runs(self, query_executor):
    results = query_executor("SELECT * FROM customer;")
    assert results is not None
```

### Pattern 2: Test Row Count
```python
def test_has_data(self, query_executor):
    results = query_executor("SELECT * FROM customer;")
    QueryTestHelper.assert_row_count(results, 0, operator='>')
```

### Pattern 3: Test Filtering
```python
def test_filter_works(self, query_executor):
    results = query_executor(
        "SELECT * FROM customer WHERE country = 'Germany';"
    )
    for row in results:
        assert row[7] == 'Germany'  # country column
```

### Pattern 4: Test Aggregation
```python
def test_count_by_country(self, query_executor):
    results = query_executor("""
        SELECT country, COUNT(*) as cnt
        FROM customer
        GROUP BY country;
    """)
    
    # All counts should be positive
    QueryTestHelper.assert_all_match_condition(
        results, 1, lambda x: x > 0
    )
```

### Pattern 5: Test Sorting
```python
def test_sorted_results(self, query_executor):
    results = query_executor("""
        SELECT * FROM customer ORDER BY last_name DESC;
    """)
    
    QueryTestHelper.assert_sorted(results, 2, descending=True)
```

## Helpful Test Helpers

All available in `QueryTestHelper`:

```python
# Row count
QueryTestHelper.assert_row_count(results, 10)
QueryTestHelper.assert_row_count(results, 5, operator='>')

# Columns
QueryTestHelper.assert_column_count(results, 3)

# NULL checks
QueryTestHelper.assert_no_nulls(results, column_index=0)

# Uniqueness
QueryTestHelper.assert_unique_values(results, column_index=0)

# Sorting
QueryTestHelper.assert_sorted(results, column_index=1)
QueryTestHelper.assert_sorted(results, column_index=1, descending=True)

# Value checks
QueryTestHelper.assert_contains_value(results, column_index=0, value='USA')

# Custom conditions
QueryTestHelper.assert_all_match_condition(
    results, column_index=2, condition=lambda x: x > 0
)

# Numeric ranges
QueryTestHelper.assert_numeric_range(
    results, column_index=3, min_value=0, max_value=100
)
```

## Running Specific Tests

```bash
# Run one test file
pytest tests/test_001_select_filters.py

# Run one test class
pytest tests/test_001_select_filters.py::TestSelectFilters

# Run one test method
pytest tests/test_001_select_filters.py::TestSelectFilters::test_select_albums_returns_results

# Run tests matching pattern
pytest -k "select" tests/

# Run with more details
pytest tests/ -v -s
```

## Debugging Failed Tests

### Show full output
```bash
pytest tests/test_my_query.py -v -s
```

### Drop into debugger on failure
```bash
pytest tests/test_my_query.py --pdb
```

### Show local variables on failure
```bash
pytest tests/test_my_query.py -l
```

## Tips

1. **Start simple**: Test that query executes and returns data
2. **Add specifics**: Test column count, no nulls, sorting
3. **Test logic**: Verify filters, aggregations, joins work correctly
4. **Test edge cases**: Empty results, boundary values
5. **Use descriptive names**: Make test purpose clear from name
6. **One assertion per concept**: Makes failures easier to understand

## Next Steps

- Read the full [tests/README.md](README.md) for comprehensive guide
- Check [test_template.py](test_template.py) for more examples
- Look at existing tests for patterns
- Run tests in CI with GitHub Actions

## Need Help?

- Check the [tests/README.md](README.md) documentation
- Look at example tests in `test_001_*.py` files
- Open an issue on GitHub

Happy testing! 🧪
