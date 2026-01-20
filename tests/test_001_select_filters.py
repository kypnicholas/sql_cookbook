"""
Unit tests for 001_select_filters.pgsql

These tests validate basic SELECT queries and filtering operations.
"""
import pytest
import os
from tests.test_helpers import QueryTestHelper


@pytest.mark.integration
class TestSelectFilters:
    """Tests for basic SELECT and filter queries."""
    
    def test_select_albums_returns_results(self, query_executor):
        """Test that selecting albums returns data."""
        results = query_executor("SELECT * FROM public.album LIMIT 100;")
        
        assert results is not None
        assert len(results) > 0, "Should return at least one album"
        QueryTestHelper.assert_row_count(results, 100, operator='<=')
    
    def test_select_artists_returns_results(self, query_executor):
        """Test that selecting artists returns data."""
        results = query_executor("SELECT * FROM public.artist LIMIT 100;")
        
        assert results is not None
        assert len(results) > 0, "Should return at least one artist"
    
    def test_select_customers_returns_results(self, query_executor):
        """Test that selecting customers returns data."""
        results = query_executor("SELECT * FROM public.customer LIMIT 100;")
        
        assert results is not None
        assert len(results) > 0, "Should return at least one customer"
        
        # Verify we get the expected structure (customer should have multiple columns)
        if results:
            QueryTestHelper.assert_column_count(results, 13)
    
    def test_select_customers_with_country_filter(self, query_executor):
        """Test filtering customers by country."""
        results = query_executor(
            "SELECT * FROM public.customer WHERE Country = 'Germany' LIMIT 100;"
        )
        
        assert results is not None
        
        # If there are results, verify all are from Germany
        if len(results) > 0:
            # Country is the 8th column (0-indexed: position 7)
            for row in results:
                assert row[7] == 'Germany', f"Expected Germany, got {row[7]}"
    
    def test_select_with_limit_respects_limit(self, query_executor):
        """Test that LIMIT clause is respected."""
        limit = 10
        results = query_executor(f"SELECT * FROM public.album LIMIT {limit};")
        
        QueryTestHelper.assert_row_count(results, limit, operator='<=')
    
    def test_customer_email_not_null(self, query_executor):
        """Test that customer emails are not null."""
        results = query_executor("SELECT email FROM public.customer LIMIT 100;")
        
        # Email column is at index 0 (only selected column)
        QueryTestHelper.assert_no_nulls(results, 0)
    
    def test_filter_by_multiple_countries(self, query_executor):
        """Test filtering by multiple countries using IN clause."""
        query = """
            SELECT customer_id, first_name, last_name, country 
            FROM public.customer 
            WHERE country IN ('USA', 'Canada', 'Brazil')
            ORDER BY country, customer_id;
        """
        results = query_executor(query)
        
        assert results is not None
        if len(results) > 0:
            # Country is at index 3 in the result
            valid_countries = {'USA', 'Canada', 'Brazil'}
            for row in results:
                assert row[3] in valid_countries, \
                    f"Expected country in {valid_countries}, got {row[3]}"
