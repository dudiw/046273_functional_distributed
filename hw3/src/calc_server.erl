-module(calc_server). 
-behaviour(gen_server).
-export([start_link/1, start/1, stop/0, countTasks/0, calcFun/3]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Interface Routines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_link(Name) -> 
    gen_server:start_link({local, Name}, ?MODULE, [Name], []).

start(Name) -> gen_server:start_link({local, Name}, ?MODULE, [Name], []).

stop() -> gen_server:call(?MODULE, stop).

countTasks() -> gen_server:call(?MODULE, count_tasks).

calcFun(ClientPid, F, MsgRef) -> gen_server:call(?MODULE, {add, {ClientPid, F, MsgRef}}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Callback Routines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init([Name]) -> 
	process_flag(trap_exit, true),
    Count = 0,
	{ok, {Name, Count}, 1000}.

handle_call(stop, _From, State) -> 
    {stop, normal, stopped, State};

handle_call(count_tasks, _From, State = {_Name, Count}) ->
    {reply, Count, State};

handle_call({add, Task}, _From, _State = {Name, Count}) ->
    {reply, gen_server:cast(Name, {add, Task}), {Name, Count + 1}}.

handle_cast({add, Task}, _State = {Name, Count}) ->
    {ClientPid, F, MsgRef} = Task,
    % spawn 'worker' processes to perform the action
    spawn(fun() ->
            F_result = F(),
            ClientPid ! {MsgRef, F_result},
            gen_server:cast(Name, {complete, MsgRef})
         end),
	{noreply, {Name, Count}};

handle_cast({complete, _MsgRef}, _State = {Name, Count}) ->
	{noreply, {Name, Count - 1}}.

handle_info(timeout, State) ->
	{noreply, State, 1000}.

terminate(_Reason, _State) -> ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.