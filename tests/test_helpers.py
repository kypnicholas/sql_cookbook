"""
Test helper utilities for SQL query testing.

This module provides common assertion helpers and utilities for testing SQL queries.
"""
from typing import List, Tuple, Any, Optional


class QueryTestHelper:
    """Helper class with common test assertions for SQL queries."""
    
    @staticmethod
    def assert_row_count(results: List[Tuple], expected_count: int, 
                        operator: str = '==') -> None:
        """
        Assert that query results have expected number of rows.
        
        Args:
            results: Query results
            expected_count: Expected number of rows
            operator: Comparison operator ('==', '>', '<', '>=', '<=')
        """
        actual_count = len(results)
        
        if operator == '==':
            assert actual_count == expected_count, \
                f"Expected {expected_count} rows, got {actual_count}"
        elif operator == '>':
            assert actual_count > expected_count, \
                f"Expected more than {expected_count} rows, got {actual_count}"
        elif operator == '<':
            assert actual_count < expected_count, \
                f"Expected less than {expected_count} rows, got {actual_count}"
        elif operator == '>=':
            assert actual_count >= expected_count, \
                f"Expected at least {expected_count} rows, got {actual_count}"
        elif operator == '<=':
            assert actual_count <= expected_count, \
                f"Expected at most {expected_count} rows, got {actual_count}"
        else:
            raise ValueError(f"Unknown operator: {operator}")
    
    @staticmethod
    def assert_column_count(results: List[Tuple], expected_columns: int) -> None:
        """
        Assert that query results have expected number of columns.
        
        Args:
            results: Query results
            expected_columns: Expected number of columns
        """
        if results:
            actual_columns = len(results[0])
            assert actual_columns == expected_columns, \
                f"Expected {expected_columns} columns, got {actual_columns}"
    
    @staticmethod
    def assert_no_nulls(results: List[Tuple], column_index: int) -> None:
        """
        Assert that a specific column has no NULL values.
        
        Args:
            results: Query results
            column_index: Index of column to check (0-based)
        """
        for i, row in enumerate(results):
            assert row[column_index] is not None, \
                f"NULL value found in column {column_index} at row {i}"
    
    @staticmethod
    def assert_unique_values(results: List[Tuple], column_index: int) -> None:
        """
        Assert that a specific column has all unique values.
        
        Args:
            results: Query results
            column_index: Index of column to check (0-based)
        """
        values = [row[column_index] for row in results]
        unique_values = set(values)
        assert len(values) == len(unique_values), \
            f"Column {column_index} contains duplicate values"
    
    @staticmethod
    def assert_sorted(results: List[Tuple], column_index: int, 
                     descending: bool = False) -> None:
        """
        Assert that results are sorted by a specific column.
        
        Args:
            results: Query results
            column_index: Index of column to check (0-based)
            descending: If True, check for descending order
        """
        values = [row[column_index] for row in results]
        sorted_values = sorted(values, reverse=descending)
        assert values == sorted_values, \
            f"Results not sorted by column {column_index}"
    
    @staticmethod
    def assert_contains_value(results: List[Tuple], column_index: int, 
                             value: Any) -> None:
        """
        Assert that a specific value exists in a column.
        
        Args:
            results: Query results
            column_index: Index of column to check (0-based)
            value: Value to search for
        """
        values = [row[column_index] for row in results]
        assert value in values, \
            f"Value '{value}' not found in column {column_index}"
    
    @staticmethod
    def assert_all_match_condition(results: List[Tuple], column_index: int,
                                   condition: callable) -> None:
        """
        Assert that all values in a column match a condition.
        
        Args:
            results: Query results
            column_index: Index of column to check (0-based)
            condition: Callable that returns True if condition is met
        """
        for i, row in enumerate(results):
            value = row[column_index]
            assert condition(value), \
                f"Value '{value}' at row {i} does not match condition"
    
    @staticmethod
    def assert_numeric_range(results: List[Tuple], column_index: int,
                            min_value: Optional[float] = None,
                            max_value: Optional[float] = None) -> None:
        """
        Assert that numeric values in a column are within a range.
        
        Args:
            results: Query results
            column_index: Index of column to check (0-based)
            min_value: Minimum allowed value (inclusive)
            max_value: Maximum allowed value (inclusive)
        """
        for i, row in enumerate(results):
            value = row[column_index]
            if min_value is not None:
                assert value >= min_value, \
                    f"Value {value} at row {i} is below minimum {min_value}"
            if max_value is not None:
                assert value <= max_value, \
                    f"Value {value} at row {i} is above maximum {max_value}"
