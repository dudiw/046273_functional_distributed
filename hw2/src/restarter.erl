-module(restarter).
-export([start/0, restarter/0]).

start() ->
	 spawn(?MODULE, restarter, []).

restarter() ->
	% Make current process become a system process
	process_flag(trap_exit, true),
	Pid = spawn_link(?MODULE, matrix_server, []),
	register(matrix_server, Pid),
			
	receive 
		{'EXIT', Pid, normal} -> ok;
		{'EXIT', Pid, shutdown} -> ok;
		{'EXIT', Pid, _} -> restarter()
	end.