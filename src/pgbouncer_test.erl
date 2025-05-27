-module(pgbouncer_test).
-export([
    test_connection/0,
    test_basic_query/0,
    test_transaction/0,
    test_multiple_queries/0,
    run_all_tests/0
]).

%% Test basic connection
test_connection() ->
    io:format("Testing connection...~n"),
    case pgo:query("SELECT 1 as test") of
        #{command := select, num_rows := 1, rows := [{1}]} ->
            io:format("✓ Connection test passed~n"),
            ok;
        Error ->
            io:format("✗ Connection test failed: ~p~n", [Error]),
            error
    end.

%% Test basic query
test_basic_query() ->
    io:format("Testing basic query...~n"),
    case pgo:query("SELECT version()") of
        #{command := select, num_rows := 1, rows := [_]} ->
            io:format("✓ Basic query test passed~n"),
            ok;
        Error ->
            io:format("✗ Basic query test failed: ~p~n", [Error]),
            error
    end.

%% Test transaction
test_transaction() ->
    io:format("Testing transaction...~n"),

    %% First, create a test table if it doesn't exist
    pgo:query("CREATE TABLE IF NOT EXISTS test_table (id SERIAL PRIMARY KEY, name TEXT)"),

    %% Clear any existing data
    pgo:query("DELETE FROM test_table"),

    %% Test transaction
    Result = pgo:transaction(fun() ->
        pgo:query("INSERT INTO test_table(name) VALUES('Test 1')"),
        pgo:query("INSERT INTO test_table(name) VALUES('Test 2')"),
        pgo:query("SELECT COUNT(*) FROM test_table")
    end),

    case Result of
        #{command := select, num_rows := 1, rows := [{2}]} ->
            io:format("✓ Transaction test passed~n"),
            ok;
        Error ->
            io:format("✗ Transaction test failed: ~p~n", [Error]),
            error
    end.

%% Test multiple concurrent queries
test_multiple_queries() ->
    io:format("Testing multiple concurrent queries...~n"),

    %% Spawn multiple processes to test connection pooling
    Pids = [spawn_link(fun() ->
        timer:sleep(rand:uniform(100)),  % Random delay
        Result = pgo:query("SELECT $1::integer as num", [N]),
        io:format("Query ~p result: ~p~n", [N, Result])
    end) || N <- lists:seq(1, 10)],

    %% Wait for all processes to complete
    [receive {'EXIT', Pid, normal} -> ok after 5000 -> timeout end || Pid <- Pids],

    io:format("✓ Multiple queries test completed~n"),
    ok.

%% Run all tests
run_all_tests() ->
    io:format("=== PgBouncer Test Suite ===~n"),

    %% Ensure pgo is started
    application:ensure_all_started(pgo),

    Tests = [
        fun test_connection/0,
        fun test_basic_query/0,
        fun test_transaction/0,
        fun test_multiple_queries/0
    ],

    Results = [Test() || Test <- Tests],

    case lists:all(fun(R) -> R =:= ok end, Results) of
        true ->
            io:format("~n=== All tests passed! ===~n");
        false ->
            io:format("~n=== Some tests failed! ===~n")
    end.
