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

calcFun(ClientPid, F, MsgRef) -> gen_server:cast(?MODULE, {ClientPid, F, MsgRef}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Callback Routines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init([Name]) -> 
	process_flag(trap_exit, true),
	{ok, {Name, dict:new()}, 1000}.

handle_call(stop, _From, State) -> 
    {stop, normal, stopped, State};

handle_call(count_tasks, _From, State = {_Name, Tasks}) ->
    {reply, dict:size(Tasks), State}.

handle_cast({add, Task}, {Name, Tasks}) ->
    {ClientPid, F, MsgRef} = Task,
    Updated = dict:store(MsgRef, ClientPid, Tasks),

    % spawn 'worker' processes to perform the action
    spawn(fun() ->
            F_result = F(),
            ClientPid ! {MsgRef, F_result},
            gen_server:cast(Name, {complete, MsgRef})
         end),
	{noreply, {Name, Updated}};

handle_cast({track, Update}, {Name, _Tasks}) ->
	{noreply, {Name, Update}};

handle_cast({complete, MsgRef}, {Name, Tasks}) ->
	{noreply, {Name, dict:erase(MsgRef, Tasks)}}.

handle_info(timeout, State) ->
	{noreply, State, 1000}.

terminate(_Reason, _State) -> ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.