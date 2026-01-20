"""
Unit tests for 002_distinct_counts.pgsql

These tests validate DISTINCT and COUNT operations.
"""
import pytest
from tests.test_helpers import QueryTestHelper


@pytest.mark.integration
class TestDistinctCounts:
    """Tests for DISTINCT and COUNT queries."""
    
    def test_count_transactions_per_country(self, query_executor):
        """Test counting transactions per billing country."""
        query = """
            SELECT DISTINCT billing_country, COUNT(*) AS "No. of transactions" 
            FROM public.invoice
            GROUP BY billing_country
            ORDER BY "No. of transactions" DESC;
        """
        results = query_executor(query)
        
        assert results is not None
        assert len(results) > 0, "Should return at least one country"
        
        # Verify structure: should have 2 columns (country, count)
        QueryTestHelper.assert_column_count(results, 2)
        
        # Verify no null countries
        QueryTestHelper.assert_no_nulls(results, 0)
        
        # Verify counts are positive integers
        for row in results:
            count = row[1]
            assert count > 0, f"Transaction count should be positive, got {count}"
            assert isinstance(count, int), f"Count should be integer, got {type(count)}"
        
        # Verify results are sorted by count descending
        counts = [row[1] for row in results]
        assert counts == sorted(counts, reverse=True), \
            "Results should be sorted by transaction count in descending order"
    
    def test_count_distinct_billing_countries(self, query_executor):
        """Test counting distinct billing countries."""
        query = "SELECT COUNT(DISTINCT billing_country) FROM public.invoice;"
        results = query_executor(query)
        
        assert results is not None
        assert len(results) == 1, "Should return exactly one row"
        
        distinct_count = results[0][0]
        assert distinct_count > 0, "Should have at least one distinct country"
        assert isinstance(distinct_count, int), "Count should be an integer"
    
    def test_distinct_countries_match_count(self, query_executor):
        """Test that distinct countries count matches grouped query."""
        # Get count of distinct countries
        count_query = "SELECT COUNT(DISTINCT billing_country) FROM public.invoice;"
        count_result = query_executor(count_query)
        distinct_count = count_result[0][0]
        
        # Get grouped countries
        group_query = """
            SELECT DISTINCT billing_country 
            FROM public.invoice
            GROUP BY billing_country;
        """
        group_results = query_executor(group_query)
        
        # Both should match
        assert len(group_results) == distinct_count, \
            f"GROUP BY returned {len(group_results)} countries, " \
            f"COUNT(DISTINCT) returned {distinct_count}"
    
    def test_billing_country_not_null(self, query_executor):
        """Test that billing_country values are not null in aggregated results."""
        query = """
            SELECT billing_country, COUNT(*) 
            FROM public.invoice
            GROUP BY billing_country;
        """
        results = query_executor(query)
        
        # Verify no null countries in the grouped results
        QueryTestHelper.assert_no_nulls(results, 0)
    
    def test_transaction_counts_are_positive(self, query_executor):
        """Test that all transaction counts are positive."""
        query = """
            SELECT billing_country, COUNT(*) AS transaction_count
            FROM public.invoice
            GROUP BY billing_country;
        """
        results = query_executor(query)
        
        # All counts should be at least 1
        QueryTestHelper.assert_all_match_condition(
            results, 1, lambda x: x >= 1
        )
