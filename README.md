# PgBouncer Test with pgo

This is a simple Erlang application to test PgBouncer connectivity using the pgo PostgreSQL client.

## Setup

1. Make sure you have Erlang/OTP and rebar3 installed
2. Make sure PgBouncer is running and configured to connect to your PostgreSQL database
3. Update the connection parameters in `config/sys.config` if needed

## Usage

```bash
# Get dependencies
rebar3 deps

# Start the shell
rebar3 shell

# In the Erlang shell, run tests:
pgbouncer_test:run_all_tests().

# Or run individual tests:
pgbouncer_test:test_connection().
pgbouncer_test:test_basic_query().
pgbouncer_test:test_transaction().
pgbouncer_test:test_multiple_queries().
```

## Configuration

The database connection is configured in `config/sys.config`. Current settings:
- Host: localhost
- Port: 5432
- Database: pgbouncer
- User: daniel
- Password: glue
- SSL: disabled
- Pool size: 5 connections

## Tests

- `test_connection()`: Basic connectivity test
- `test_basic_query()`: Simple SELECT query
- `test_transaction()`: Transaction with multiple statements
- `test_multiple_queries()`: Concurrent queries to test connection pooling
