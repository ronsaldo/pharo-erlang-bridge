-module(samples).
-export([
	fib/1,
	fibList/1
]).

% Fibonacci sequence
fib(_X = 1) ->
	1;

fib(_X = 2) ->
	1;

fib(X) ->
	fib(X-1) + fib(X-2).

% Fibonacci list
fibList(X) ->
	lists:reverse(fibList(X, [])).
	
fibList(_X = 1, PreviousResult) ->
	[1 | PreviousResult];

fibList(_X = 2, PreviousResult) ->
	[1, 1 | PreviousResult];

fibList(X, PreviousResult) ->
	NextResult = fibList(X-1, PreviousResult),
	[X1, X2 | _] = NextResult,
	[X1 + X2 | NextResult].
