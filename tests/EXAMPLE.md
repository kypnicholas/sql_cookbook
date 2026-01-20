# Example: Testing a New SQL Query

This document walks through a complete example of writing a SQL query and its tests.

## Scenario

You want to find the top 10 customers by total purchase amount.

## Step 1: Write the SQL Query

Create `queries/005_top_customers.pgsql`:

```sql
-- Find top 10 customers by total purchase amount
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.country,
    SUM(i.total) as total_spent
FROM 
    customer c
    INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.country
ORDER BY 
    total_spent DESC
LIMIT 10;
```

## Step 2: Create the Test File

Create `tests/test_005_top_customers.py`:

```python
"""
Unit tests for 005_top_customers.pgsql

Tests for finding top customers by purchase amount.
"""
import pytest
from tests.test_helpers import QueryTestHelper


@pytest.mark.integration
class TestTopCustomers:
    """Tests for top customers query."""
    
    def test_query_returns_exactly_10_customers(self, query_executor):
        """Test that query returns exactly 10 customers."""
        query = """
            SELECT 
                c.customer_id,
                c.first_name,
                c.last_name,
                c.country,
                SUM(i.total) as total_spent
            FROM 
                customer c
                INNER JOIN invoice i ON c.customer_id = i.customer_id
            GROUP BY 
                c.customer_id, c.first_name, c.last_name, c.country
            ORDER BY 
                total_spent DESC
            LIMIT 10;
        """
        results = query_executor(query)
        
        # Should return exactly 10 rows
        QueryTestHelper.assert_row_count(results, 10)
    
    def test_results_have_correct_structure(self, query_executor):
        """Test that results have 5 columns."""
        query = """
            SELECT 
                c.customer_id,
                c.first_name,
                c.last_name,
                c.country,
                SUM(i.total) as total_spent
            FROM 
                customer c
                INNER JOIN invoice i ON c.customer_id = i.customer_id
            GROUP BY 
                c.customer_id, c.first_name, c.last_name, c.country
            ORDER BY 
                total_spent DESC
            LIMIT 10;
        """
        results = query_executor(query)
        
        # Should have 5 columns: id, first_name, last_name, country, total
        QueryTestHelper.assert_column_count(results, 5)
    
    def test_no_null_values_in_key_columns(self, query_executor):
        """Test that key columns don't have NULL values."""
        query = """
            SELECT 
                c.customer_id,
                c.first_name,
                c.last_name,
                c.country,
                SUM(i.total) as total_spent
            FROM 
                customer c
                INNER JOIN invoice i ON c.customer_id = i.customer_id
            GROUP BY 
                c.customer_id, c.first_name, c.last_name, c.country
            ORDER BY 
                total_spent DESC
            LIMIT 10;
        """
        results = query_executor(query)
        
        # Check no nulls in customer_id (column 0)
        QueryTestHelper.assert_no_nulls(results, 0)
        
        # Check no nulls in total_spent (column 4)
        QueryTestHelper.assert_no_nulls(results, 4)
    
    def test_results_sorted_by_total_descending(self, query_executor):
        """Test that results are sorted by total_spent descending."""
        query = """
            SELECT 
                c.customer_id,
                c.first_name,
                c.last_name,
                c.country,
                SUM(i.total) as total_spent
            FROM 
                customer c
                INNER JOIN invoice i ON c.customer_id = i.customer_id
            GROUP BY 
                c.customer_id, c.first_name, c.last_name, c.country
            ORDER BY 
                total_spent DESC
            LIMIT 10;
        """
        results = query_executor(query)
        
        # Verify sorted by total_spent (column 4) in descending order
        QueryTestHelper.assert_sorted(results, 4, descending=True)
    
    def test_all_totals_are_positive(self, query_executor):
        """Test that all total amounts are positive."""
        query = """
            SELECT 
                c.customer_id,
                c.first_name,
                c.last_name,
                c.country,
                SUM(i.total) as total_spent
            FROM 
                customer c
                INNER JOIN invoice i ON c.customer_id = i.customer_id
            GROUP BY 
                c.customer_id, c.first_name, c.last_name, c.country
            ORDER BY 
                total_spent DESC
            LIMIT 10;
        """
        results = query_executor(query)
        
        # All totals (column 4) should be positive
        QueryTestHelper.assert_all_match_condition(
            results,
            column_index=4,
            condition=lambda x: x > 0
        )
    
    def test_customer_ids_are_unique(self, query_executor):
        """Test that each customer appears only once."""
        query = """
            SELECT 
                c.customer_id,
                c.first_name,
                c.last_name,
                c.country,
                SUM(i.total) as total_spent
            FROM 
                customer c
                INNER JOIN invoice i ON c.customer_id = i.customer_id
            GROUP BY 
                c.customer_id, c.first_name, c.last_name, c.country
            ORDER BY 
                total_spent DESC
            LIMIT 10;
        """
        results = query_executor(query)
        
        # Customer IDs (column 0) should be unique
        QueryTestHelper.assert_unique_values(results, 0)
```

## Step 3: Run the Tests

```bash
# Run just this test file
pytest tests/test_005_top_customers.py -v

# Output will show each test:
# tests/test_005_top_customers.py::TestTopCustomers::test_query_returns_exactly_10_customers PASSED
# tests/test_005_top_customers.py::TestTopCustomers::test_results_have_correct_structure PASSED
# tests/test_005_top_customers.py::TestTopCustomers::test_no_null_values_in_key_columns PASSED
# tests/test_005_top_customers.py::TestTopCustomers::test_results_sorted_by_total_descending PASSED
# tests/test_005_top_customers.py::TestTopCustomers::test_all_totals_are_positive PASSED
# tests/test_005_top_customers.py::TestTopCustomers::test_customer_ids_are_unique PASSED
```

## What We Tested

✅ **Structure**: Query returns expected number of rows and columns  
✅ **Data Quality**: No NULL values in important columns  
✅ **Business Logic**: Results are sorted correctly  
✅ **Constraints**: All amounts are positive, customer IDs are unique  

## Best Practices Demonstrated

1. **One test, one concern**: Each test validates one specific aspect
2. **Descriptive names**: Test names clearly state what they validate
3. **Helper methods**: Used `QueryTestHelper` for cleaner assertions
4. **Column indices**: Used column index (0-based) to reference columns
5. **Complete coverage**: Tested structure, quality, logic, and constraints

## Tips for Your Tests

- Start with basic tests (executes, returns data)
- Add structure tests (column count, types)
- Add logic tests (filters, sorting, grouping)
- Add edge case tests (empty results, boundary values)
- Use meaningful test names that explain the validation
- Group related tests in a class
- Use the `@pytest.mark.integration` marker for database tests

## Common Patterns

### Testing Joins
```python
def test_join_returns_matched_records(self, query_executor):
    query = """
        SELECT c.customer_id, i.invoice_id
        FROM customer c
        INNER JOIN invoice i ON c.customer_id = i.customer_id;
    """
    results = query_executor(query)
    
    # Both columns should have no nulls
    QueryTestHelper.assert_no_nulls(results, 0)
    QueryTestHelper.assert_no_nulls(results, 1)
```

### Testing Aggregations
```python
def test_aggregation_has_positive_counts(self, query_executor):
    query = """
        SELECT country, COUNT(*) as cnt
        FROM customer
        GROUP BY country;
    """
    results = query_executor(query)
    
    # All counts should be > 0
    QueryTestHelper.assert_all_match_condition(
        results, 1, lambda x: x > 0
    )
```

### Testing Filters
```python
def test_filter_returns_only_matching_records(self, query_executor):
    query = """
        SELECT * FROM customer WHERE country = 'Brazil';
    """
    results = query_executor(query)
    
    # All should be from Brazil (assuming country is column 7)
    for row in results:
        assert row[7] == 'Brazil'
```

## Next Steps

- Add more complex tests for edge cases
- Test with different input parameters
- Add performance tests for slow queries
- Document any special data requirements
- Run tests in CI/CD pipeline

For more information, see:
- [tests/README.md](README.md) - Complete testing guide
- [tests/QUICKSTART.md](QUICKSTART.md) - Quick reference
- [tests/test_template.py](test_template.py) - Template file
