# SQL Query Unit Testing Framework

This directory contains a comprehensive unit testing framework for SQL queries in the SQL Cookbook project.

## Overview

The testing framework allows you to:
- **Write unit tests** for every SQL query you create
- **Validate query results** with rich assertion helpers
- **Ensure data quality** with automated checks
- **Run tests locally** or in CI/CD pipelines
- **Maintain test isolation** with automatic transaction rollback

## Quick Start

### Prerequisites

1. **Python 3.8+** installed
2. **PostgreSQL database** with Chinook schema and data loaded
3. **Database credentials** configured via environment variables

### Installation

```bash
# Install Python dependencies
pip install -r requirements.txt
```

### Environment Setup

Set up your database connection using environment variables:

```bash
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=chinook
export PGUSER=postgres
export PGPASSWORD=your_password
```

Or create a `.env` file in the project root:

```env
PGHOST=localhost
PGPORT=5432
PGDATABASE=chinook
PGUSER=postgres
PGPASSWORD=your_password
```

### Running Tests

```bash
# Run all tests
pytest tests/

# Run a specific test file
pytest tests/test_001_select_filters.py

# Run with verbose output
pytest -v tests/

# Run tests matching a pattern
pytest -k "select" tests/

# Run with coverage report
pytest --cov=tests tests/
```

## Writing Your Own Tests

### Basic Test Structure

Here's a simple example of testing a SQL query:

```python
import pytest
from tests.test_helpers import QueryTestHelper

@pytest.mark.integration
class TestMyQuery:
    """Tests for my custom query."""
    
    def test_query_returns_results(self, query_executor):
        """Test that the query returns data."""
        query = """
            SELECT customer_id, first_name, last_name 
            FROM customer 
            WHERE country = 'USA';
        """
        results = query_executor(query)
        
        # Basic assertions
        assert results is not None
        assert len(results) > 0
        
        # Use helper methods
        QueryTestHelper.assert_row_count(results, 0, operator='>')
        QueryTestHelper.assert_column_count(results, 3)
```

### Testing Query Files

You can test SQL queries stored in `.sql` or `.pgsql` files:

```python
def test_query_from_file(self, query_runner):
    """Test a query loaded from a file."""
    # Path relative to project root
    results = query_runner('queries/001_select_filters.pgsql')
    
    assert results is not None
    assert len(results) > 0
```

### Available Fixtures

The testing framework provides several pytest fixtures:

#### `db_connection` (session scope)
Database connection that persists for the entire test session.

#### `db_cursor` (function scope)
Database cursor with automatic rollback after each test for isolation.

#### `query_executor` (function scope)
Execute SQL queries directly from strings:

```python
def test_example(self, query_executor):
    results = query_executor("SELECT * FROM customer LIMIT 10;")
    assert len(results) == 10
```

#### `query_runner` (function scope)
Execute SQL queries from files:

```python
def test_example(self, query_runner):
    results = query_runner('queries/my_query.sql')
    assert results is not None
```

### Test Helper Methods

The `QueryTestHelper` class provides rich assertions for SQL testing:

#### Row Count Assertions
```python
# Exact count
QueryTestHelper.assert_row_count(results, 10)

# Comparison operators
QueryTestHelper.assert_row_count(results, 5, operator='>')
QueryTestHelper.assert_row_count(results, 100, operator='<=')
```

#### Column Assertions
```python
# Check number of columns
QueryTestHelper.assert_column_count(results, 5)

# Check for NULL values
QueryTestHelper.assert_no_nulls(results, column_index=0)

# Check for unique values
QueryTestHelper.assert_unique_values(results, column_index=0)
```

#### Sorting Assertions
```python
# Check ascending sort
QueryTestHelper.assert_sorted(results, column_index=1)

# Check descending sort
QueryTestHelper.assert_sorted(results, column_index=1, descending=True)
```

#### Value Assertions
```python
# Check if value exists
QueryTestHelper.assert_contains_value(results, column_index=0, value='USA')

# Check custom condition
QueryTestHelper.assert_all_match_condition(
    results, 
    column_index=2, 
    condition=lambda x: x > 0
)

# Check numeric range
QueryTestHelper.assert_numeric_range(
    results, 
    column_index=3, 
    min_value=0, 
    max_value=1000
)
```

## Test Organization

### Naming Conventions

- **Test files**: `test_XXX_description.py` (matches query file numbers)
- **Test classes**: `TestDescriptiveName`
- **Test methods**: `test_what_it_validates`

### Example Structure

```
tests/
├── __init__.py                      # Package marker
├── conftest.py                      # Pytest configuration and fixtures
├── test_helpers.py                  # Assertion helper utilities
├── test_001_select_filters.py       # Tests for query 001
├── test_002_distinct_counts.py      # Tests for query 002
└── README.md                        # This file
```

## Best Practices

### 1. Test What Matters
Focus on testing:
- Query returns expected structure (columns, types)
- Results meet business logic requirements
- Filters work correctly
- Aggregations are accurate
- Performance-critical queries complete in acceptable time

### 2. Keep Tests Isolated
- Each test should be independent
- Use fixtures for setup
- Rely on automatic rollback for cleanup
- Don't modify data unless testing data modification

### 3. Use Descriptive Names
```python
# Good
def test_customer_filter_returns_only_usa_customers(self, query_executor):
    pass

# Less clear
def test_filter(self, query_executor):
    pass
```

### 4. Add Comments for Complex Logic
```python
def test_complex_aggregation(self, query_executor):
    """Test revenue calculation with multiple joins."""
    # This query joins invoices, customers, and invoice_items
    # to calculate total revenue per customer segment
    query = """..."""
    results = query_executor(query)
    # ... assertions
```

### 5. Test Edge Cases
```python
def test_query_handles_empty_results(self, query_executor):
    """Test query behavior with no matching records."""
    query = "SELECT * FROM customer WHERE country = 'NonExistent';"
    results = query_executor(query)
    assert results == []
```

## Example Test Cases

### Testing Basic SELECT
```python
def test_select_all_customers(self, query_executor):
    """Test selecting all customers."""
    results = query_executor("SELECT * FROM customer;")
    
    QueryTestHelper.assert_row_count(results, 0, operator='>')
    QueryTestHelper.assert_no_nulls(results, column_index=0)  # customer_id
```

### Testing Filters
```python
def test_filter_by_country(self, query_executor):
    """Test filtering customers by country."""
    query = "SELECT * FROM customer WHERE country = 'Germany';"
    results = query_executor(query)
    
    # All results should be from Germany (column 7)
    for row in results:
        assert row[7] == 'Germany'
```

### Testing Aggregations
```python
def test_count_by_country(self, query_executor):
    """Test counting customers by country."""
    query = """
        SELECT country, COUNT(*) as customer_count
        FROM customer
        GROUP BY country
        ORDER BY customer_count DESC;
    """
    results = query_executor(query)
    
    QueryTestHelper.assert_row_count(results, 0, operator='>')
    QueryTestHelper.assert_sorted(results, column_index=1, descending=True)
```

### Testing Joins
```python
def test_customer_invoice_join(self, query_executor):
    """Test joining customers with their invoices."""
    query = """
        SELECT c.customer_id, c.first_name, i.invoice_id, i.total
        FROM customer c
        INNER JOIN invoice i ON c.customer_id = i.customer_id
        LIMIT 100;
    """
    results = query_executor(query)
    
    QueryTestHelper.assert_column_count(results, 4)
    QueryTestHelper.assert_no_nulls(results, 0)  # customer_id
    QueryTestHelper.assert_no_nulls(results, 2)  # invoice_id
```

## CI/CD Integration

Tests can be run automatically in GitHub Actions or other CI/CD systems. See `.github/workflows/test.yml` for configuration.

### GitHub Actions Example

```yaml
name: Test SQL Queries

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: chinook
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: pip install -r requirements.txt
      
      - name: Set up database
        run: |
          psql -h localhost -U postgres -d chinook < migrations/001_create_schema.sql
          psql -h localhost -U postgres -d chinook < seeds/001_seed_data.sql
        env:
          PGPASSWORD: postgres
      
      - name: Run tests
        run: pytest tests/ -v
        env:
          PGHOST: localhost
          PGPORT: 5432
          PGDATABASE: chinook
          PGUSER: postgres
          PGPASSWORD: postgres
```

## Troubleshooting

### Connection Issues

If you get connection errors:
1. Verify PostgreSQL is running: `psql -l`
2. Check environment variables are set correctly
3. Verify database exists: `psql -d chinook -c "SELECT 1;"`

### Import Errors

If you get module import errors:
1. Ensure you're in the project root directory
2. Install dependencies: `pip install -r requirements.txt`
3. Run tests from project root: `pytest tests/`

### Test Failures

If tests fail unexpectedly:
1. Verify database has correct schema and data
2. Check test isolation (tests should not depend on each other)
3. Review test output for specific assertion failures

## Contributing

When adding new queries to the cookbook:

1. **Write the SQL query** in `queries/XXX_name.pgsql`
2. **Create corresponding test file** in `tests/test_XXX_name.py`
3. **Test at minimum**:
   - Query executes without errors
   - Returns expected structure
   - Results meet basic business logic
4. **Run tests** locally before committing
5. **Document** any special setup or data requirements

## Resources

- [pytest Documentation](https://docs.pytest.org/)
- [psycopg2 Documentation](https://www.psycopg.org/docs/)
- [SQL Testing Best Practices](https://www.postgresql.org/docs/current/regress.html)

## Support

For issues or questions about the testing framework, please:
1. Check this README
2. Review example tests in `test_001_*.py` files
3. Open an issue in the repository
