%% Token Bucket Rate Limiter
%%
%% Transpiled from INTENT.md - Human language is the source code.
%%
%% Prolog: The language that thinks in logic.
%% Here, even rate limiting becomes a logical proposition.

:- module(rate_limiter, [
    create_bucket/3,
    consume/2,
    available/2,
    demo/0
]).

%% Dynamic state for the bucket
:- dynamic bucket_state/4.  % bucket_state(Id, Tokens, LastRefill, Config)

%% Get current time in seconds
current_time(T) :-
    get_time(T).

%% Create a new token bucket
%% create_bucket(+Id, +Capacity, +RefillRate)
create_bucket(Id, Capacity, RefillRate) :-
    Capacity > 0,
    RefillRate > 0,
    current_time(Now),
    retractall(bucket_state(Id, _, _, _)),
    assertz(bucket_state(Id, Capacity, Now, config(Capacity, RefillRate))).

%% Refill tokens based on elapsed time
refill(Id) :-
    bucket_state(Id, OldTokens, LastRefill, config(Capacity, RefillRate)),
    current_time(Now),
    Elapsed is Now - LastRefill,
    (Elapsed > 0 ->
        TokensToAdd is Elapsed * RefillRate,
        NewTokens is min(Capacity, OldTokens + TokensToAdd),
        retract(bucket_state(Id, _, _, Config)),
        assertz(bucket_state(Id, NewTokens, Now, Config))
    ; true).

%% Attempt to consume tokens
%% consume(+Id, -Success)
consume(Id, Success) :-
    refill(Id),
    bucket_state(Id, Tokens, LastRefill, Config),
    (Tokens >= 1 ->
        NewTokens is Tokens - 1,
        retract(bucket_state(Id, _, _, _)),
        assertz(bucket_state(Id, NewTokens, LastRefill, Config)),
        Success = true
    ;
        Success = false
    ).

%% Get available tokens
%% available(+Id, -Tokens)
available(Id, Tokens) :-
    refill(Id),
    bucket_state(Id, Tokens, _, _).

%% --- Demonstration ---

demo :-
    format("Token Bucket Rate Limiter - Prolog Implementation~n"),
    format("==================================================~n~n"),
    
    % Create a bucket: 5 tokens capacity, 2 tokens/second refill
    create_bucket(limiter, 5, 2),
    
    format("Created limiter: capacity=5, refill_rate=2/s~n"),
    available(limiter, StartTokens),
    format("Starting tokens: ~1f~n~n", [StartTokens]),
    
    % Consume all tokens rapidly
    format("--- Rapid consumption ---~n"),
    rapid_consume(1, 7),
    nl,
    
    % Wait for refill
    format("--- Waiting 1 second for refill ---~n"),
    sleep(1),
    available(limiter, RefillTokens),
    format("Tokens after 1s: ~2f~n~n", [RefillTokens]),
    
    % Try again
    format("--- Post-refill consumption ---~n"),
    rapid_consume(1, 3),
    nl,
    
    format("==================================================~n"),
    format("Human intent -> Prolog implementation ✓~n").

rapid_consume(I, Max) :-
    I > Max, !.
rapid_consume(I, Max) :-
    consume(limiter, Success),
    available(limiter, Tokens),
    (Success == true ->
        format("  Attempt ~d: ✓ allowed (tokens left: ~2f)~n", [I, Tokens])
    ;
        format("  Attempt ~d: ✗ denied (tokens left: ~2f)~n", [I, Tokens])
    ),
    I1 is I + 1,
    rapid_consume(I1, Max).

%% Run with: swipl -g demo -t halt rate_limiter.pl
