%%% -------------------------------------------------------------------
%%% Author  : carl
%%% Description :
%%%
%%% Created : 23 May 2011
%%% -------------------------------------------------------------------
-module(node8583_server).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {lsock}).

%% ====================================================================
%% External functions
%% ====================================================================
start_link(LSock) ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [LSock], []).

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([LSock]) ->
    {ok, #state{lsock=LSock}, 0}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({tcp, Socket, RawData}, State) ->
	{Length, Data} = lists:split(2, RawData),
	io:format("Received: ~p~n", [Data]),
	Request = erl8583_marshaller_ascii:unmarshal(Data),
	Response = erl8583_message:response(Request),
	gen_tcp:send(Socket, Length ++ erl8583_marshaller_ascii:marshal(Response)),
    {noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
	{stop, normal, State};
handle_info(timeout, #state{lsock = LSock} = State) ->
	io:format("Listening...~n"),
	{ok, _Sock} = gen_tcp:accept(LSock),
	io:format("Accepted.~n"),
	{noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

