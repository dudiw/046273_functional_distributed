-module(calc_supervisor).
-behaviour(supervisor).
-export([start_link/0, init/1]).
-export([count_tasks/1, set_task/2, get_report/0]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	% Supervisor configuration:
	% Strategies  - restart strategy 'rest_for_one'
	% MaxRestarts - restrict to 3 restarts during 'MaxTime' interval
	% MaxTime     - time interval of 1 hour for 'MaxRestarts'
	Names = list_servers(),
	Servers = config_servers(Names),
	{ok, {{rest_for_one, 3, 60000}, Servers}}.

% creates 'calc_server' server that reimplements a gen_server. 
config_servers(Servers) ->
	% Servers (worker) configuration:
	% Id       - unique Id of the format 'server#'
	% {M,F,A}  - module 'calc_server', function 'start_link', args '[Id]'
	% Restart  - restart on abnormal failure 'transient'
	% Shutdown - termination deadline set to 2000 miliseconds
	% Type     - a 'worker' type
	% Modules  - callback module used by the child 'calc_server'
	[{Server, {calc_server, start_link, [Server]}, transient, 2000, worker, [calc_server]} || Server <- Servers].

get_name(Number) -> list_to_atom("server" ++ integer_to_list(Number)).

list_servers() -> [get_name(N) || N <- lists:seq(1,3)].

count_tasks(Number) -> 
	Name = get_name(Number),
	Count = gen_server:call(Name, count_tasks),
	{message_queue_len, Length} = erlang:process_info(whereis(Name), message_queue_len),
	{Name, Count + Length}.

set_task(Name, Task) -> 
	gen_server:call(Name, {add, Task}),
	ok.

get_report() -> [calc_supervisor:count_tasks(N) || N <- lists:seq(1,3)].