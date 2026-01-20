# Testing Framework Index

Quick navigation guide for the SQL query testing framework.

## 📚 Documentation Files

### 🚀 Getting Started (Read in Order)

1. **[QUICKSTART.md](QUICKSTART.md)** ⚡
   - 5-minute setup guide
   - Install dependencies
   - Run first test
   - Common patterns
   - **START HERE** if you're new

2. **[EXAMPLE.md](EXAMPLE.md)** 📖
   - Complete walkthrough
   - Real-world scenario
   - Step-by-step guide
   - Best practices
   - **READ SECOND** to learn by example

3. **[CHEATSHEET.md](CHEATSHEET.md)** 📝
   - Quick reference
   - All assertion methods
   - Copy-paste templates
   - Command reference
   - **KEEP HANDY** for daily use

4. **[README.md](README.md)** 📘
   - Comprehensive guide
   - Complete reference
   - Detailed explanations
   - Troubleshooting
   - **READ WHEN NEEDED** for deep dives

## 🔧 Code Files

### Core Framework

- **[conftest.py](conftest.py)** - Test configuration, fixtures, database connections
- **[test_helpers.py](test_helpers.py)** - `QueryTestHelper` class with all assertions
- **[test_template.py](test_template.py)** - Template for creating new tests

### Example Tests

- **[test_001_select_filters.py](test_001_select_filters.py)** - Tests for basic SELECT/filters
- **[test_002_distinct_counts.py](test_002_distinct_counts.py)** - Tests for DISTINCT/COUNT

## 🎯 Quick Links by Task

### I want to...

#### ...get started quickly
👉 Read [QUICKSTART.md](QUICKSTART.md) (5 minutes)

#### ...write my first test
👉 Follow [EXAMPLE.md](EXAMPLE.md) (15 minutes)

#### ...find a specific assertion
👉 Check [CHEATSHEET.md](CHEATSHEET.md)

#### ...copy a test template
👉 Use [test_template.py](test_template.py)

#### ...understand how it works
👉 Read [README.md](README.md)

#### ...see working examples
👉 Look at [test_001_select_filters.py](test_001_select_filters.py)

#### ...troubleshoot an issue
👉 See [README.md](README.md) → Troubleshooting section

## 📊 Documentation Overview

| File | Purpose | Length | When to Use |
|------|---------|--------|-------------|
| QUICKSTART.md | Quick start guide | 5,319 lines | Getting started |
| EXAMPLE.md | Complete example | 9,220 lines | Learning by example |
| CHEATSHEET.md | Quick reference | 10,228 lines | Daily reference |
| README.md | Complete guide | 10,852 lines | Deep understanding |
| test_template.py | Code template | 7,232 lines | Creating new tests |

## 🎓 Recommended Learning Path

```
Day 1: Read QUICKSTART.md → Try running tests
       (15 minutes)

Day 2: Follow EXAMPLE.md → Write your first test
       (30 minutes)

Day 3: Use CHEATSHEET.md → Write tests for your queries
       (Reference as needed)

Ongoing: Refer to README.md → Deep understanding
         (As questions arise)
```

## 🔍 Finding What You Need

### By Experience Level

**Complete Beginner**
1. QUICKSTART.md
2. EXAMPLE.md
3. test_001_select_filters.py (read the code)

**Some Experience**
1. CHEATSHEET.md (quick reference)
2. test_template.py (copy/paste)
3. README.md (when stuck)

**Advanced User**
1. CHEATSHEET.md (quick lookup)
2. test_helpers.py (extend with custom helpers)
3. conftest.py (customize fixtures)

### By Test Type

**Basic SELECT Tests**
- EXAMPLE.md → "Testing Basic SELECT" section
- test_001_select_filters.py

**Filter Tests**
- CHEATSHEET.md → "Testing Filters" section
- test_001_select_filters.py → `test_select_customers_with_country_filter`

**Aggregation Tests**
- CHEATSHEET.md → "Testing Aggregations" section
- test_002_distinct_counts.py → `test_count_transactions_per_country`

**Join Tests**
- CHEATSHEET.md → "Testing Joins" section
- EXAMPLE.md → "Testing Joins" section

**Window Function Tests**
- test_template.py → `TestAdvancedScenarios::test_window_function_results`

**CTE Tests**
- test_template.py → `TestAdvancedScenarios::test_cte_logic`

### By Task

**Setting up environment**
→ QUICKSTART.md → "5-Minute Setup"

**Writing assertions**
→ CHEATSHEET.md → "Common Assertions"

**Running tests**
→ CHEATSHEET.md → "Running Tests"

**Debugging failures**
→ README.md → "Troubleshooting"

**CI/CD setup**
→ README.md → "CI/CD Integration"

## 🎯 Core Concepts

### Fixtures (defined in conftest.py)
- `db_connection` - Database connection
- `db_cursor` - Cursor with rollback
- `query_executor` - Execute SQL strings
- `query_runner` - Execute SQL files

### Test Helpers (defined in test_helpers.py)
- `QueryTestHelper.assert_row_count()`
- `QueryTestHelper.assert_column_count()`
- `QueryTestHelper.assert_no_nulls()`
- `QueryTestHelper.assert_sorted()`
- And more...

### Test Structure
```python
@pytest.mark.integration
class TestMyQuery:
    def test_something(self, query_executor):
        results = query_executor("SELECT ...")
        assert results is not None
```

## 🆘 Getting Help

1. **Check CHEATSHEET.md** - Quick answers
2. **Read EXAMPLE.md** - Learn by example
3. **Consult README.md** - Comprehensive guide
4. **Review existing tests** - Real working code
5. **Open GitHub issue** - Get help from community

## 📈 Testing Framework Structure

```
tests/
├── INDEX.md                    ← YOU ARE HERE
│
├── Documentation (Read These)
│   ├── QUICKSTART.md          ← Start here (5 min)
│   ├── EXAMPLE.md             ← Read second (15 min)
│   ├── CHEATSHEET.md          ← Keep handy (reference)
│   └── README.md              ← Deep dive (comprehensive)
│
├── Framework Code (Use These)
│   ├── conftest.py            ← Fixtures & config
│   ├── test_helpers.py        ← Assertion helpers
│   └── __init__.py            ← Package marker
│
├── Templates (Copy These)
│   └── test_template.py       ← Template for new tests
│
└── Examples (Learn From These)
    ├── test_001_select_filters.py
    └── test_002_distinct_counts.py
```

## ⚡ Quick Reference Card

```bash
# Setup
pip install -r requirements.txt
export PGHOST=localhost PGDATABASE=chinook PGUSER=postgres

# Run tests
pytest tests/                    # All tests
pytest tests/test_file.py        # One file
pytest tests/ -v                 # Verbose
pytest tests/ -k "keyword"       # Match keyword

# Write test
1. Create queries/XXX_name.pgsql
2. Create tests/test_XXX_name.py
3. Copy from test_template.py
4. Run: pytest tests/test_XXX_name.py
```

## 🎉 Next Steps

1. ✅ Read QUICKSTART.md
2. ✅ Follow EXAMPLE.md
3. ✅ Write your first test
4. ✅ Use CHEATSHEET.md as reference
5. ✅ Share with your team!

---

**Navigate with confidence! Happy testing! 🧪**
