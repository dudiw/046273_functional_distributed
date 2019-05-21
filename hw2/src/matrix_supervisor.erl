-module(matrix_supervisor).
-export([start/0, restarter/0]).


start() ->
	io:format("matrix_supervisor:start ~p ~n", [?MODULE]),
	spawn(?MODULE, restarter, []).

restarter() ->
	io:format("matrix_supervisor:restarter ~n"),
	% Make current process become a system process
	process_flag(trap_exit, true),
	Pid = spawn_link(matrix_server, loop, []),
	register(matrix_server, Pid),
	io:format("matrix_server Pid ~p ~n",[whereis(matrix_server)]),
			
	receive 
		{'EXIT', Pid, normal} -> 
			io:format("normal ~p ~n",[whereis(matrix_server)]),
			ok;
		{'EXIT', Pid, shutdown} -> 
			io:format("shutdown Pid ~p whereis ~p ~n",[Pid, whereis(matrix_server)]),
			ok;
		{'EXIT', Pid, _} -> 
			io:format("start whereis ~p ~n",[whereis(matrix_server)]),
			start()
	end.
