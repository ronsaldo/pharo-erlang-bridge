-module(pharo_erlang_bridge_eval_server).
-behavior(gen_server).
-record(state, {}).
-export([
    start_link/0,
    stop/1,
    async_eval_erlang_code/4,
    eval_erlang_code/3
]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3]).

%% Public interface
start_link() ->
    {ok, Pid} = gen_server:start_link(?MODULE, [], []),
    Pid.

stop(Pid) ->
    gen_server:cast(Pid, stop).

async_eval_erlang_code(Pid, ErlangCode, Bindings, Callback) ->
    gen_server:cast(Pid, {asyncEval, ErlangCode, Bindings, Callback}).

eval_erlang_code(Pid, ErlangCode, Bindings) ->
    gen_server:call(Pid, {eval, ErlangCode, Bindings}).

%% gen_server callbacks
init([]) ->
    State = #state{},
    {ok, State}.

handle_call(_Request = {eval, ErlangCode, Bindings}, _From, State) ->
    Result = evalErlangCode(ErlangCode, Bindings),
    {reply, Result, State};

handle_call(_Request, _From, State) ->
    {reply, {ok}, State}.


handle_cast(_Request = {asyncEval, ErlangCode, Bindings, Callback}, State) ->
    Result = evalErlangCode(ErlangCode, Bindings),
    Callback(Result),
    {noreply, State};

handle_cast(_Request = stop, State) ->
    {stop, normal, State};

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Message, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% evalErlangCode
evalErlangCode(ErlangCode, Bindings) ->
    evalErlangCode_scan(ErlangCode, Bindings).

evalErlangCode_scan(ErlangCode, Bindings) ->
    case erl_scan:string(ErlangCode) of
        {ok, Tokens, _} -> evalErlangCode_parse(Tokens, Bindings);
        {error, ErrorInfo, ErrorLocation} -> {error, scan, ErrorInfo, ErrorLocation}
    end.

evalErlangCode_parse(Tokens, Bindings) ->
    case erl_parse:parse_exprs(Tokens) of
        {ok, AST} -> evalErlangCode_eval(AST, Bindings);
        {error, ErrorInfo} -> {error, parse, ErrorInfo}
    end.

evalErlangCode_eval(AST, Bindings) ->
    try erl_eval:exprs(AST, Bindings) of
        Result -> Result
    catch
        error:Error -> {error, exception, Error}
    end.
