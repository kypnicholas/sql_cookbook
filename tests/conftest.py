"""
Pytest configuration and fixtures for SQL tests.

This module provides database connection management and common test fixtures.
"""
import os
import psycopg2
from psycopg2 import sql
import pytest
from typing import Generator, Optional


def get_db_connection_params() -> dict:
    """
    Get database connection parameters from environment variables.
    
    Returns:
        dict: Database connection parameters
    """
    return {
        'host': os.getenv('PGHOST', 'localhost'),
        'port': os.getenv('PGPORT', '5432'),
        'database': os.getenv('PGDATABASE', 'chinook'),
        'user': os.getenv('PGUSER', 'postgres'),
        'password': os.getenv('PGPASSWORD', ''),
    }


@pytest.fixture(scope='session')
def db_connection() -> Generator:
    """
    Provide a database connection for the entire test session.
    
    Yields:
        psycopg2.connection: Database connection
    """
    conn_params = get_db_connection_params()
    conn = psycopg2.connect(**conn_params)
    conn.autocommit = False
    
    yield conn
    
    conn.close()


@pytest.fixture(scope='function')
def db_cursor(db_connection):
    """
    Provide a database cursor for each test function.
    Automatically rolls back after each test to maintain isolation.
    
    Yields:
        psycopg2.cursor: Database cursor
    """
    cursor = db_connection.cursor()
    
    yield cursor
    
    db_connection.rollback()
    cursor.close()


@pytest.fixture
def query_runner(db_cursor):
    """
    Provide a helper function to run SQL queries from files.
    
    Returns:
        function: Query runner function
    """
    def run_query(query_file_path: str, params: Optional[dict] = None) -> list:
        """
        Run a SQL query from a file and return results.
        
        Args:
            query_file_path: Path to SQL file relative to project root
            params: Optional query parameters
            
        Returns:
            list: Query results as list of tuples
        """
        # Read the SQL file
        with open(query_file_path, 'r') as f:
            query = f.read()
        
        # Execute the query
        if params:
            db_cursor.execute(query, params)
        else:
            db_cursor.execute(query)
        
        # Fetch and return results
        try:
            return db_cursor.fetchall()
        except psycopg2.ProgrammingError:
            # No results to fetch (e.g., INSERT, UPDATE, DELETE)
            return []
    
    return run_query


@pytest.fixture
def query_executor(db_cursor):
    """
    Provide a helper function to execute SQL queries directly.
    
    Returns:
        function: Query executor function
    """
    def execute_query(query: str, params: Optional[dict] = None, fetch: bool = True):
        """
        Execute a SQL query and optionally return results.
        
        Args:
            query: SQL query string
            params: Optional query parameters
            fetch: Whether to fetch results
            
        Returns:
            list or None: Query results if fetch=True, None otherwise
        """
        if params:
            db_cursor.execute(query, params)
        else:
            db_cursor.execute(query)
        
        if fetch:
            try:
                return db_cursor.fetchall()
            except psycopg2.ProgrammingError:
                return []
        return None
    
    return execute_query


def pytest_configure(config):
    """Configure custom markers for pytest."""
    config.addinivalue_line(
        "markers", "integration: mark test as integration test requiring database"
    )
    config.addinivalue_line(
        "markers", "slow: mark test as slow running"
    )
