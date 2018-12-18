-module(pharo_erlang_bridge_sup).
-export([start_link/0, init/1, start_socket/0]).
-behaviour(supervisor).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    ListeningPort = application:get_env(pharo_erlang_bridge, listeningPort, 6761),
    {ok, ListenSocket} = gen_tcp:listen(ListeningPort, [binary, {active,false}, {reuseaddr, true}]),
    spawn_link(fun empty_listeners/0),
    MaxRestart = 5,
    MaxTime = 3600,
    {ok, {{simple_one_for_one, MaxRestart, MaxTime},
        [{pharo_erlang_bridge,
         {pharo_erlang_bridge_server,start_link,[ListenSocket]},
         temporary, 5000, worker, [pharo_erlang_bridge_server]}]}}.

start_socket() ->
    supervisor:start_child(?MODULE, []).

empty_listeners() ->
    [start_socket() || _ <- lists:seq(1,3)],
    ok.
