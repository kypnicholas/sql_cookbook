"""
Unit tests for 019_pivot.pgsql

These tests validate pivoting and crosstab operations using FILTER clause.
"""
import pytest
from tests.test_helpers import QueryTestHelper


@pytest.mark.integration
class TestPivotQueries:
    """Tests for pivot/crosstab queries."""
    
    def test_monthly_revenue_pivot_returns_results(self, query_executor):
        """Test that monthly revenue pivot query returns data."""
        query = """
            SELECT 
                billing_country,
                SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-01-01') AS jan_2009_revenue,
                SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-02-01') AS feb_2009_revenue,
                SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-03-01') AS mar_2009_revenue,
                SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-04-01') AS apr_2009_revenue,
                SUM(total) AS total_revenue
            FROM 
                invoice
            WHERE 
                invoice_date >= '2009-01-01' 
                AND invoice_date < '2009-05-01'
            GROUP BY 
                billing_country
            ORDER BY 
                total_revenue DESC;
        """
        results = query_executor(query)
        
        assert results is not None
        QueryTestHelper.assert_row_count(results, 0, operator='>')
        
        # Should have 6 columns: country + 4 months + total
        QueryTestHelper.assert_column_count(results, 6)
    
    def test_monthly_revenue_pivot_structure(self, query_executor):
        """Test that pivot query has correct structure."""
        query = """
            SELECT 
                billing_country,
                SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-01-01') AS jan_2009_revenue,
                SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-02-01') AS feb_2009_revenue,
                SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-03-01') AS mar_2009_revenue,
                SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-04-01') AS apr_2009_revenue,
                SUM(total) AS total_revenue
            FROM 
                invoice
            WHERE 
                invoice_date >= '2009-01-01' 
                AND invoice_date < '2009-05-01'
            GROUP BY 
                billing_country
            ORDER BY 
                total_revenue DESC;
        """
        results = query_executor(query)
        
        # Country column should not be null
        QueryTestHelper.assert_no_nulls(results, 0)
        
        # Total revenue should not be null
        QueryTestHelper.assert_no_nulls(results, 5)
        
        # Results should be sorted by total_revenue descending
        QueryTestHelper.assert_sorted(results, 5, descending=True)
    
    def test_customer_count_pivot_by_year(self, query_executor):
        """Test customer count pivot by year."""
        query = """
            SELECT 
                billing_country,
                COUNT(DISTINCT customer_id) FILTER (WHERE EXTRACT(YEAR FROM invoice_date) = 2009) AS customers_2009,
                COUNT(DISTINCT customer_id) FILTER (WHERE EXTRACT(YEAR FROM invoice_date) = 2010) AS customers_2010,
                COUNT(DISTINCT customer_id) FILTER (WHERE EXTRACT(YEAR FROM invoice_date) = 2011) AS customers_2011,
                COUNT(DISTINCT customer_id) FILTER (WHERE EXTRACT(YEAR FROM invoice_date) = 2012) AS customers_2012,
                COUNT(DISTINCT customer_id) AS total_customers
            FROM 
                invoice
            GROUP BY 
                billing_country
            ORDER BY 
                total_customers DESC;
        """
        results = query_executor(query)
        
        assert results is not None
        QueryTestHelper.assert_row_count(results, 0, operator='>')
        
        # Should have 6 columns: country + 4 years + total
        QueryTestHelper.assert_column_count(results, 6)
        
        # All customer counts should be non-negative
        for row in results:
            for i in range(1, 6):  # Check all count columns
                assert row[i] >= 0, f"Customer count should be non-negative, got {row[i]}"
    
    def test_quarterly_invoice_pivot(self, query_executor):
        """Test quarterly invoice count pivot."""
        query = """
            SELECT 
                billing_country,
                COUNT(*) FILTER (WHERE EXTRACT(QUARTER FROM invoice_date) = 1) AS q1_invoices,
                COUNT(*) FILTER (WHERE EXTRACT(QUARTER FROM invoice_date) = 2) AS q2_invoices,
                COUNT(*) FILTER (WHERE EXTRACT(QUARTER FROM invoice_date) = 3) AS q3_invoices,
                COUNT(*) FILTER (WHERE EXTRACT(QUARTER FROM invoice_date) = 4) AS q4_invoices,
                COUNT(*) AS total_invoices
            FROM 
                invoice
            WHERE 
                EXTRACT(YEAR FROM invoice_date) = 2009
            GROUP BY 
                billing_country
            ORDER BY 
                total_invoices DESC;
        """
        results = query_executor(query)
        
        assert results is not None
        
        # Should have 6 columns: country + 4 quarters + total
        QueryTestHelper.assert_column_count(results, 6)
        
        # Verify that sum of quarters equals total for each row
        for row in results:
            q1, q2, q3, q4, total = row[1], row[2], row[3], row[4], row[5]
            assert q1 + q2 + q3 + q4 == total, \
                f"Sum of quarters ({q1 + q2 + q3 + q4}) should equal total ({total})"
    
    def test_average_invoice_pivot(self, query_executor):
        """Test average invoice amount pivot by month."""
        query = """
            SELECT 
                billing_country,
                ROUND(AVG(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-01-01'), 2) AS jan_avg,
                ROUND(AVG(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-02-01'), 2) AS feb_avg,
                ROUND(AVG(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-03-01'), 2) AS mar_avg,
                ROUND(AVG(total), 2) AS overall_avg
            FROM 
                invoice
            WHERE 
                invoice_date >= '2009-01-01' 
                AND invoice_date < '2009-04-01'
            GROUP BY 
                billing_country
            HAVING 
                COUNT(*) >= 1
            ORDER BY 
                overall_avg DESC;
        """
        results = query_executor(query)
        
        assert results is not None
        
        # Should have 5 columns: country + 3 months + overall avg
        QueryTestHelper.assert_column_count(results, 5)
        
        # All averages should be positive where not null
        for row in results:
            for i in range(1, 5):  # Check all average columns
                if row[i] is not None:
                    assert row[i] > 0, f"Average should be positive, got {row[i]}"
    
    def test_case_when_pivot_alternative(self, query_executor):
        """Test CASE WHEN approach to pivoting (alternative to FILTER)."""
        query = """
            SELECT 
                billing_country,
                SUM(CASE WHEN DATE_TRUNC('month', invoice_date) = '2009-01-01' THEN total ELSE 0 END) AS jan_2009_revenue,
                SUM(CASE WHEN DATE_TRUNC('month', invoice_date) = '2009-02-01' THEN total ELSE 0 END) AS feb_2009_revenue,
                SUM(CASE WHEN DATE_TRUNC('month', invoice_date) = '2009-03-01' THEN total ELSE 0 END) AS mar_2009_revenue,
                SUM(total) AS total_revenue
            FROM 
                invoice
            WHERE 
                invoice_date >= '2009-01-01' 
                AND invoice_date < '2009-04-01'
            GROUP BY 
                billing_country
            ORDER BY 
                total_revenue DESC;
        """
        results = query_executor(query)
        
        assert results is not None
        QueryTestHelper.assert_row_count(results, 0, operator='>')
        
        # Should have 5 columns: country + 3 months + total
        QueryTestHelper.assert_column_count(results, 5)
        
        # Total revenue should be sum of monthly revenues
        for row in results:
            jan, feb, mar, total = row[1], row[2], row[3], row[4]
            # Allow small floating point differences
            assert abs((jan + feb + mar) - total) < 0.01, \
                f"Sum of months ({jan + feb + mar}) should equal total ({total})"
    
    def test_pivot_results_sorted_correctly(self, query_executor):
        """Test that pivot results are sorted by total descending."""
        query = """
            SELECT 
                billing_country,
                SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-01-01') AS jan_2009_revenue,
                SUM(total) AS total_revenue
            FROM 
                invoice
            WHERE 
                invoice_date >= '2009-01-01' 
                AND invoice_date < '2009-02-01'
            GROUP BY 
                billing_country
            ORDER BY 
                total_revenue DESC;
        """
        results = query_executor(query)
        
        # Verify sorted by total_revenue (column index 2) descending
        QueryTestHelper.assert_sorted(results, 2, descending=True)
