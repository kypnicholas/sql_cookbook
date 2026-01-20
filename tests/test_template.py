"""
Template for creating new SQL query tests.

This template provides a starting point for testing your SQL queries.
Copy this file and customize it for your specific query.

Usage:
1. Copy this file to test_XXX_your_query_name.py
2. Update the docstring and class name
3. Implement test methods for your query
4. Run: pytest tests/test_XXX_your_query_name.py
"""
import pytest
from tests.test_helpers import QueryTestHelper


@pytest.mark.integration
class TestYourQueryName:
    """Tests for XXX_your_query_name.pgsql"""
    
    def test_query_executes_successfully(self, query_executor):
        """Test that the query executes without errors."""
        query = """
            -- Your SQL query here
            SELECT * FROM your_table LIMIT 10;
        """
        results = query_executor(query)
        
        # Basic sanity check
        assert results is not None
    
    def test_query_returns_expected_structure(self, query_executor):
        """Test that query returns expected number of columns."""
        query = """
            -- Your SQL query here
            SELECT column1, column2, column3 FROM your_table LIMIT 10;
        """
        results = query_executor(query)
        
        # Check column count
        QueryTestHelper.assert_column_count(results, 3)
    
    def test_query_returns_data(self, query_executor):
        """Test that query returns at least some data."""
        query = """
            -- Your SQL query here
            SELECT * FROM your_table;
        """
        results = query_executor(query)
        
        # Should return at least one row
        QueryTestHelper.assert_row_count(results, 0, operator='>')
    
    def test_no_null_values_in_key_columns(self, query_executor):
        """Test that key columns don't contain NULLs."""
        query = """
            -- Your SQL query here
            SELECT id, name FROM your_table;
        """
        results = query_executor(query)
        
        # Check that ID column (index 0) has no nulls
        QueryTestHelper.assert_no_nulls(results, 0)
    
    def test_results_are_sorted_correctly(self, query_executor):
        """Test that results are sorted as expected."""
        query = """
            -- Your SQL query here
            SELECT id, name FROM your_table ORDER BY name ASC;
        """
        results = query_executor(query)
        
        # Check that results are sorted by name (column index 1)
        QueryTestHelper.assert_sorted(results, 1, descending=False)
    
    def test_filter_works_correctly(self, query_executor):
        """Test that filtering returns only matching records."""
        query = """
            -- Your SQL query with filter
            SELECT * FROM your_table WHERE status = 'active';
        """
        results = query_executor(query)
        
        # Verify all results match the filter
        # Adjust column_index based on your query structure
        QueryTestHelper.assert_all_match_condition(
            results,
            column_index=2,  # Assuming status is at index 2
            condition=lambda x: x == 'active'
        )
    
    def test_aggregation_produces_correct_results(self, query_executor):
        """Test that aggregation logic is correct."""
        query = """
            -- Your aggregation query
            SELECT category, COUNT(*) as count
            FROM your_table
            GROUP BY category;
        """
        results = query_executor(query)
        
        # Verify aggregation results
        QueryTestHelper.assert_row_count(results, 0, operator='>')
        
        # Verify all counts are positive
        QueryTestHelper.assert_all_match_condition(
            results,
            column_index=1,  # count column
            condition=lambda x: x > 0
        )
    
    def test_join_returns_expected_data(self, query_executor):
        """Test that joins work correctly."""
        query = """
            -- Your join query
            SELECT t1.id, t1.name, t2.description
            FROM table1 t1
            INNER JOIN table2 t2 ON t1.id = t2.table1_id;
        """
        results = query_executor(query)
        
        # Verify structure
        QueryTestHelper.assert_column_count(results, 3)
        
        # Verify no nulls in join keys
        QueryTestHelper.assert_no_nulls(results, 0)
    
    def test_numeric_values_in_valid_range(self, query_executor):
        """Test that numeric values are within expected ranges."""
        query = """
            -- Query with numeric column
            SELECT id, price FROM your_table;
        """
        results = query_executor(query)
        
        # Verify price is within valid range (column index 1)
        QueryTestHelper.assert_numeric_range(
            results,
            column_index=1,
            min_value=0,
            max_value=10000
        )


# Additional test examples for specific scenarios

@pytest.mark.integration
class TestAdvancedScenarios:
    """Advanced test scenarios."""
    
    def test_window_function_results(self, query_executor):
        """Test window function calculations."""
        query = """
            SELECT 
                id,
                value,
                ROW_NUMBER() OVER (ORDER BY value DESC) as rank
            FROM your_table;
        """
        results = query_executor(query)
        
        # Verify rank is sequential
        ranks = [row[2] for row in results]
        expected_ranks = list(range(1, len(results) + 1))
        assert ranks == expected_ranks, "Ranks should be sequential"
    
    def test_cte_logic(self, query_executor):
        """Test Common Table Expression logic."""
        query = """
            WITH summary AS (
                SELECT category, SUM(amount) as total
                FROM your_table
                GROUP BY category
            )
            SELECT * FROM summary WHERE total > 100;
        """
        results = query_executor(query)
        
        # Verify CTE filter works
        QueryTestHelper.assert_all_match_condition(
            results,
            column_index=1,
            condition=lambda x: x > 100
        )
    
    @pytest.mark.slow
    def test_complex_query_performance(self, query_executor):
        """Test that complex query completes in reasonable time."""
        import time
        
        query = """
            -- Your complex query
            SELECT * FROM your_large_table
            WHERE complex_condition = true;
        """
        
        start_time = time.time()
        results = query_executor(query)
        elapsed_time = time.time() - start_time
        
        # Query should complete within 5 seconds
        assert elapsed_time < 5.0, \
            f"Query took {elapsed_time:.2f}s, expected < 5.0s"


# Example of testing query from a file

@pytest.mark.integration
class TestQueryFromFile:
    """Test queries loaded from SQL files."""
    
    def test_query_file_execution(self, query_runner):
        """Test executing a query from a .sql file."""
        # Path relative to project root
        results = query_runner('queries/your_query.sql')
        
        assert results is not None
        QueryTestHelper.assert_row_count(results, 0, operator='>')
