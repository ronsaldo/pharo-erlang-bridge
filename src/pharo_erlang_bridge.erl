-module(pharo_erlang_bridge).
-behaviour(application).
-export([start/2, stop/1]).

start(normal, _Args) ->
    pharo_erlang_bridge_sup:start_link().

stop(_State) ->
    ok.
