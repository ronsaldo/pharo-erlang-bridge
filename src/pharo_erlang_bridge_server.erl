-module(pharo_erlang_bridge_server).
-behavior(gen_server).
-record(state, {
    socket,
    smalltalkMessageDispatchProcess
}).
-export([
    start_link/1,
    transcript/2
]).
-define(ListeningPort, 6761).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3]).

%% Public interface
start_link(ListenSocket) ->
    gen_server:start_link(?MODULE, [ListenSocket], []).

send_to_smalltalk(Client, Message) ->
    gen_server:cast(Client, {sendToSmalltalk, Message}).

transcript(Bridge, TranscriptMessage) ->
    send_to_smalltalk(Bridge, {transcript, TranscriptMessage}).

%% gen_server callbacks
init([ListenSocket]) ->
    gen_server:cast(self(), accept),
    State = #state{socket = ListenSocket},
    {ok, State}.

handle_call(_Request, _From, State) ->
    {reply, {ok}, State}.

handle_cast(_Request = socketClosed, State) ->
    {stop, normal, State};

handle_cast(_Request = {sendToSmalltalk, Message}, State) ->
    sendMessageToClient(State, Message),
    {noreply, State};

handle_cast(_Request = accept, _S=#state{socket = ListenSocket}) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    pharo_erlang_bridge_sup:start_socket(),

    % Check the header
    case gen_tcp:recv(Socket, 4) of
        {ok, <<"PHRO">>} ->
            % io:format("Got Pharo header~n"),
            BridgeServer = self(),
            MessageDispatchProcess = spawn_link(fun () -> smalltalkMessageDispatchProcess(BridgeServer) end),
            State = #state{socket = Socket, smalltalkMessageDispatchProcess = MessageDispatchProcess},
            spawn_link(fun () -> message_receiver_process (BridgeServer, Socket) end),
            {noreply, State};
        _ ->
            io:format("Got invalid Pharo bridge connection~n"),
            {stop, normal, #state{}}
    end;

handle_cast(_Request = {message, Message}, State) ->
    processMessageFromNetwork(State, Message);

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Message, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% handle_network_cast
handle_network_cast(Request, State) ->
    io:format("Got unknown cast network: ~p~n", [Request]),
    {noreply, State}.

handle_network_call(_Request = {eval, ErlangCode, Bindings}, State = #state{smalltalkMessageDispatchProcess = MessageDispatchProcess}) ->
    AllBindings = [
        {'SmalltalkClient', self()},
        {'PharoClient', self()},
        {'Smalltalk', MessageDispatchProcess},
        {'Pharo', MessageDispatchProcess}
        | Bindings
    ],
    Result = evalErlangCode(ErlangCode, orddict:from_list(AllBindings)),
    {reply, Result, State};

handle_network_call(Request, State) ->
    io:format("Got unknown call network: ~p~n", [Request]),
    {reply, ignored, State}.

%%
processMessageFromNetwork(State, _Message = {cast, Request}) ->
    handle_network_cast(Request, State);

processMessageFromNetwork(State, _Message = {call, Serial, Request}) ->
    case handle_network_call(Request, State) of
        {reply, Response, NewState} ->
            sendMessageToClient(NewState, {callResponse, Serial, Response}),
            {noreply, NewState};
        ServerNextAction -> ServerNextAction
    end;

processMessageFromNetwork(State, Message) ->
    io:format("Got unknown message from network: ~p~n", [Message]),
    {noreply, State}.

%% sendMessageToClient
sendMessageToClient(State, Message) ->
    EncodedMessage = erlang:term_to_binary(Message),
    MessageSize = byte_size(EncodedMessage),

    EncodedMessageSize = <<MessageSize:32/big-unsigned-integer>>,
    gen_tcp:send(State#state.socket, [EncodedMessageSize, EncodedMessage]).

%% message_receiver_process
message_receiver_process(BridgeServer, Socket) ->
    % Get the next message length.
    {ok, <<MessageLength:32/big-unsigned-integer>>} = gen_tcp:recv(Socket, 4),

    % Get the data from the next message.
    % io:format("Got MessageLength ~p~n", [MessageLength]),
    {ok, EncodedMessage} = gen_tcp:recv(Socket, MessageLength),

    % Decode the encoded message.
    Message = erlang:binary_to_term(EncodedMessage),

    % Send the message into the bridge server
    gen_server:cast(BridgeServer, {message, Message}),

    message_receiver_process(BridgeServer, Socket).

%% smalltalkMessageDispatchProcess
smalltalkMessageDispatchProcess(BridgeServer) ->
    receive
        Message -> send_to_smalltalk(BridgeServer, Message)
    end,
    smalltalkMessageDispatchProcess(BridgeServer).

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
