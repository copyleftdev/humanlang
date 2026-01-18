%% Token Bucket Rate Limiter
%%
%% Transpiled from INTENT.md - Human language is the source code.

-module(rate_limiter).
-behaviour(gen_server).

%% API
-export([start_link/2, consume/1, consume/2, available/1, stop/1]).
-export([demo/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-record(state, {
    capacity :: float(),
    refill_rate :: float(),
    tokens :: float(),
    last_refill :: integer()  % erlang:monotonic_time(millisecond)
}).

%%====================================================================
%% API
%%====================================================================

%% Create a new token bucket rate limiter.
%% Capacity: Maximum number of tokens the bucket can hold
%% RefillRate: Number of tokens added per second
start_link(Capacity, RefillRate) when Capacity > 0, RefillRate > 0 ->
    gen_server:start_link(?MODULE, {Capacity, RefillRate}, []).

%% Consume one token
consume(Pid) ->
    consume(Pid, 1.0).

%% Consume N tokens
consume(Pid, Tokens) ->
    gen_server:call(Pid, {consume, Tokens}).

%% Get available tokens
available(Pid) ->
    gen_server:call(Pid, available).

%% Stop the rate limiter
stop(Pid) ->
    gen_server:stop(Pid).

%%====================================================================
%% gen_server callbacks
%%====================================================================

init({Capacity, RefillRate}) ->
    {ok, #state{
        capacity = to_float(Capacity),
        refill_rate = to_float(RefillRate),
        tokens = to_float(Capacity),  % Start full
        last_refill = erlang:monotonic_time(millisecond)
    }}.

handle_call({consume, Tokens}, _From, State) ->
    NewState = refill(State),
    case NewState#state.tokens >= Tokens of
        true ->
            {reply, true, NewState#state{tokens = NewState#state.tokens - Tokens}};
        false ->
            {reply, false, NewState}
    end;

handle_call(available, _From, State) ->
    NewState = refill(State),
    {reply, NewState#state.tokens, NewState}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

refill(State = #state{capacity = Cap, refill_rate = Rate, tokens = Tokens, last_refill = Last}) ->
    Now = erlang:monotonic_time(millisecond),
    ElapsedMs = Now - Last,
    case ElapsedMs > 0 of
        true ->
            ElapsedSec = ElapsedMs / 1000.0,
            TokensToAdd = ElapsedSec * Rate,
            NewTokens = min(Cap, Tokens + TokensToAdd),
            State#state{tokens = NewTokens, last_refill = Now};
        false ->
            State
    end.

to_float(X) when is_integer(X) -> X * 1.0;
to_float(X) when is_float(X) -> X.

%%====================================================================
%% Demo
%%====================================================================

demo() ->
    io:format("Token Bucket Rate Limiter - Erlang Implementation~n"),
    io:format("~s~n", [lists:duplicate(50, $=)]),
    
    {ok, Limiter} = start_link(5, 2),
    
    io:format("~nCreated limiter: capacity=5, refill_rate=2/s~n"),
    io:format("Starting tokens: ~p~n", [trunc(available(Limiter))]),
    
    io:format("~n--- Rapid consumption ---~n"),
    lists:foreach(fun(I) ->
        Result = consume(Limiter),
        Tok = available(Limiter),
        Status = case Result of true -> "allowed"; false -> "denied" end,
        io:format("  Attempt ~p: ~s (tokens left: ~.2f)~n", [I, Status, Tok])
    end, lists:seq(1, 7)),
    
    io:format("~n--- Waiting 1 second for refill ---~n"),
    timer:sleep(1000),
    Tokens1 = available(Limiter),
    io:format("Tokens after 1s: ~.2f~n", [Tokens1]),
    
    io:format("~n--- Post-refill consumption ---~n"),
    lists:foreach(fun(I) ->
        Result = consume(Limiter),
        Status2 = case Result of true -> "allowed"; false -> "denied" end,
        Tok = available(Limiter),
        io:format("  Attempt ~p: ~s (tokens left: ~.2f)~n", [I, Status2, Tok])
    end, lists:seq(1, 3)),
    
    io:format("~n~s~n", [lists:duplicate(50, $=)]),
    io:format("Human intent → Erlang implementation ✓~n"),
    
    stop(Limiter),
    ok.
