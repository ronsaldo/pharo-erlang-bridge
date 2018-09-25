-module(pharo_erlang_bridge_server).
-behavior(gen_server).
-record(state, {
    socket,
    evaluationServer,
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

reply_network_call(Client, CallSerial, Response) ->
    gen_server:cast(Client, {replyNetworkCall, CallSerial, Response}).

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
            EvaluationServer = pharo_erlang_bridge_eval_server:start_link(),
            State = #state{socket = Socket,
                evaluationServer = EvaluationServer,
                smalltalkMessageDispatchProcess = MessageDispatchProcess},
            spawn_link(fun () -> message_receiver_process (BridgeServer, Socket) end),

            % Become the group leader of the evaluation process.
            group_leader(self(), EvaluationServer),
            {noreply, State};
        _ ->
            io:format("Got invalid Pharo bridge connection~n"),
            {stop, normal, #state{}}
    end;


handle_cast(_Request = {socketError, Error}, State) ->
    case Error of
        closed -> void;
        _ -> io:format("Got socket error ~p~n", Error)
    end,
    {stop, normal, State};

handle_cast(_Request = {replyNetworkCall, CallSerial, Response}, State) ->
    sendMessageToClient(State, {callResponse, CallSerial, Response}),
    {noreply, State};

handle_cast(_Request = {message, Message}, State) ->
    processMessageFromNetwork(State, Message);

handle_cast(_Request, State) ->
    {noreply, State}.

%% io_request
handle_info(_Message = {io_request, From, ReplyAs, Request}, State) ->
    Reply = processIORequest(Request, State),
    From ! {io_reply, ReplyAs, Reply},
    {noreply, State};

handle_info(_Message, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% handle_network_cast
handle_network_cast(Request, State) ->
    io:format("Got unknown cast network: ~p~n", [Request]),
    {noreply, State}.

handle_network_call(_Request = {eval, ErlangCode, Bindings}, From, State) ->
    #state{evaluationServer = EvaluationServer, smalltalkMessageDispatchProcess = MessageDispatchProcess} = State,
    AllBindings = [
        {'SmalltalkClient', self()},
        {'PharoClient', self()},
        {'Smalltalk', MessageDispatchProcess},
        {'Pharo', MessageDispatchProcess}
        | Bindings
    ],

    Self = self(),
    Callback = fun(Result) ->
        reply_network_call(Self, From, Result)
    end,

    pharo_erlang_bridge_eval_server:async_eval_erlang_code(EvaluationServer, ErlangCode, orddict:from_list(AllBindings), Callback),
    {noreply, State};

handle_network_call(Request, _From, State) ->
    io:format("Got unknown call network: ~p~n", [Request]),
    {reply, ignored, State}.

%%
processMessageFromNetwork(State, _Message = {cast, Request}) ->
    handle_network_cast(Request, State);

processMessageFromNetwork(State, _Message = {call, Serial, Request}) ->
    case handle_network_call(Request, Serial, State) of
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
    case recv_message_from_network(Socket) of
        {ok, EncodedMessage} ->
            % Decode the encoded message.
            Message = erlang:binary_to_term(EncodedMessage),

            % Send the message into the bridge server
            gen_server:cast(BridgeServer, {message, Message}),

            message_receiver_process(BridgeServer, Socket);
        {error, Error} ->
            % Tell the bridge server about the closed socket.
            gen_server:cast(BridgeServer, {socketError, Error})
    end.

recv_message_from_network(Socket) ->
    case gen_tcp:recv(Socket, 4) of
        {ok, <<MessageLength:32/big-unsigned-integer>>} ->
            gen_tcp:recv(Socket, MessageLength);
        Error -> Error
    end.

%% smalltalkMessageDispatchProcess
smalltalkMessageDispatchProcess(BridgeServer) ->
    receive
        Message -> send_to_smalltalk(BridgeServer, Message)
    end,
    smalltalkMessageDispatchProcess(BridgeServer).

%% io_request

% Output
processIORequest(_Request = {put_chars, Encoding, Characters}, State) ->
    BinaryCharacters = unicode:characters_to_binary(Characters, Encoding, utf8),
    sendMessageToClient(State, {transcript, BinaryCharacters}),
    ok;

processIORequest(_Request = {put_chars, Characters}, State) ->
    processIORequest({put_chars, latin1, Characters}, State);

processIORequest(_Request = {put_chars, Encoding, Module, Function, Args}, State) ->
    Characters = apply(Module, Function, Args),
    processIORequest({put_chars, Encoding, Characters}, State);

processIORequest(_Request = {put_chars, Module, Function, Args}, State) ->
    Characters = apply(Module, Function, Args),
    processIORequest({put_chars, latin1, Characters}, State);

% Multiple requests
processIORequest(_Request = {requests, Requests}, State) ->
    processIORequests(Requests, State),
    ok;

% Input
processIORequest(_Request = {get_until, _Encoding, _Prompt, _Module, _Function, _ExtraArgs}, _State) ->
    eof;
processIORequest(_Request = {get_until, _Prompt, _Module, _Function, _ExtraArgs}, _State) ->
    eof;
processIORequest(_Request = {get_chars, _Prompt, _N}, _State) ->
    eof;
processIORequest(_Request = {get_line, _Prompt}, _State) ->
    eof;
processIORequest(_Request = {get_geometry, __Geometry}, _State) ->
    {error, enotsup};
processIORequest(_Request, _State) ->
    {error, request}.

% Multiple io requests.
processIORequests(_Requests = [], _State) ->
    void;
processIORequests(_Requests = [{io_request, From, ReplyAs, Request} | Rest], State) ->
    Reply = processIORequest(Request, State),
    From ! {io_reply, ReplyAs, Reply},
    processIORequests(Rest, State).
