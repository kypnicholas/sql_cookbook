# SQL Cookbook

A comprehensive collection of SQL queries and patterns using the Chinook database (PostgreSQL). This project demonstrates various SQL techniques from basic queries to advanced analytics, complete with a robust testing framework.

## 🎯 Overview

This SQL Cookbook provides:
- **Real-world SQL examples** using the Chinook music database
- **Progressive learning path** from basic to advanced concepts
- **Unit tests for every query** to ensure correctness
- **Best practices** for SQL development and testing
- **CI/CD integration** for automated testing

## 📁 Project Structure

```
sql_cookbook/
├── migrations/          # Database schema definitions
├── seeds/              # Sample data for Chinook database
├── queries/            # SQL query examples organized by topic
├── tests/              # Unit tests for all queries
├── .github/workflows/  # CI/CD configurations
├── requirements.txt    # Python dependencies for testing
└── README.md          # This file
```

## 🚀 Quick Start

### Prerequisites

- PostgreSQL 12+ installed and running
- Python 3.8+ (for running tests)
- Git

### Database Setup

1. **Clone the repository**:
```bash
git clone https://github.com/kypnicholas/sql_cookbook.git
cd sql_cookbook
```

2. **Create the database**:
```bash
createdb chinook
```

3. **Run migrations** (create schema):
```bash
psql -d chinook -f migrations/001_create_schema.sql
```

4. **Load seed data**:
```bash
psql -d chinook -f seeds/001_seed_data.sql
```

5. **Verify setup**:
```bash
psql -d chinook -c "SELECT COUNT(*) FROM customer;"
```

### Running Queries

You can run queries directly using `psql`:

```bash
# Run a specific query file
psql -d chinook -f queries/001_select_filters.pgsql

# Or open an interactive session
psql -d chinook
```

## 🧪 Testing Framework

This project includes a comprehensive testing framework to validate all SQL queries.

### Setup Testing Environment

1. **Install Python dependencies**:
```bash
pip install -r requirements.txt
```

2. **Configure database connection** (set environment variables):
```bash
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=chinook
export PGUSER=postgres
export PGPASSWORD=your_password
```

### Running Tests

```bash
# Run all tests
pytest tests/

# Run specific test file
pytest tests/test_001_select_filters.py

# Run with verbose output
pytest tests/ -v

# Run tests matching a pattern
pytest -k "select" tests/
```

### Writing Tests for Your Queries

When you write a new SQL query, create a corresponding test file:

1. **Create your query**: `queries/XXX_my_query.pgsql`
2. **Create test file**: `tests/test_XXX_my_query.py`
3. **Use the template**: Copy from `tests/test_template.py`
4. **Write tests** to validate:
   - Query executes without errors
   - Returns expected structure (columns, types)
   - Results meet business logic requirements
   - Filters and aggregations work correctly

**Example test**:
```python
import pytest
from tests.test_helpers import QueryTestHelper

@pytest.mark.integration
class TestMyQuery:
    def test_query_returns_results(self, query_executor):
        query = "SELECT * FROM customer WHERE country = 'USA';"
        results = query_executor(query)
        
        assert results is not None
        QueryTestHelper.assert_row_count(results, 0, operator='>')
        
        # Verify all results are from USA
        for row in results:
            assert row[7] == 'USA'  # country column
```

For detailed testing documentation, see [tests/README.md](tests/README.md).

## 📚 Query Topics

The `queries/` directory contains SQL examples organized by topic:

- **001_select_filters.pgsql** - Basic SELECT statements and WHERE filters
- **002_distinct_counts.pgsql** - DISTINCT values and COUNT operations
- **003_pagination.pgsql** - OFFSET/LIMIT and keyset pagination patterns
- More queries coming soon...

See [SQL_COOKBOOK_ROADMAP.md](SQL_COOKBOOK_ROADMAP.md) for the complete plan.

## 🗄️ Database Schema

This project uses the **Chinook Database**, which represents a digital music store with:

- **Artists** and **Albums**
- **Tracks** with genres and media types
- **Customers** and their **Invoices**
- **Employees** (store representatives)
- **Playlists** and their tracks

![Chinook DB Schema](Chinook%20DB%20schema.png)

## 🔧 Development

### Adding New Queries

1. **Write your SQL query** in `queries/XXX_descriptive_name.pgsql`
2. **Create corresponding tests** in `tests/test_XXX_descriptive_name.py`
3. **Run tests locally** to ensure they pass
4. **Update documentation** if needed
5. **Commit and push** - CI will run tests automatically

### Testing Best Practices

- **Test what matters**: Focus on business logic, not implementation details
- **Keep tests isolated**: Each test should be independent
- **Use descriptive names**: `test_customer_filter_returns_only_usa_customers`
- **Test edge cases**: Empty results, null values, boundary conditions
- **Add comments**: Explain complex test logic

### CI/CD

GitHub Actions automatically runs tests on every push and pull request:

- Sets up PostgreSQL test database
- Runs migrations and loads seed data
- Executes all tests with pytest
- Reports test results

See [.github/workflows/test.yml](.github/workflows/test.yml) for details.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-query`)
3. Write your query and tests
4. Ensure all tests pass (`pytest tests/`)
5. Commit your changes (`git commit -m 'Add amazing query'`)
6. Push to the branch (`git push origin feature/amazing-query`)
7. Open a Pull Request

## 📖 Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Chinook Database](https://github.com/lerocha/chinook-database)
- [pytest Documentation](https://docs.pytest.org/)
- [SQL Testing Best Practices](tests/README.md)

## 📝 License

This project is open source and available for educational purposes.

## �� Acknowledgments

- Chinook Database by Luis Rocha
- SQL Cookbook community contributors
- PostgreSQL community

---

**Happy Querying! 🎵📊**

For questions or issues, please open a GitHub issue.
