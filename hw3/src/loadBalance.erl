-module(loadBalance). 
-export([startServers/0, stopServers/0, numberOfRunningFunctions/1, calcFun/3]).

% start the system
% returns {ok, Pid} | {ok, Pid, State} | {error, Reason}
startServers() -> calc_supervisor:start_link().

% stops the system.
% shuts down the supervisor and all child processes.
stopServers() -> 
    % exit as normal so that the calling process is retained
    Pid = whereis(calc_supervisor),
    exit(Pid, normal),

    % monitor the process to wait for it to exit
    Ref = monitor(process, Pid),
    receive
        {'DOWN', Ref, process, Pid, _Reason} ->
            ok
    after 1000 ->
            error(exit_timeout)
    end.

numberOfRunningFunctions(Number) -> 
    {_Name, Count} = calc_supervisor:count_tasks(Number),
    Count.

calcFun(Pid, F, MsgRef) -> 
    Report = calc_supervisor:get_report(),
    Sorted = lists:keysort(2, Report),
    Status = lists:nth(1, Sorted),
    Server = element(1, Status),
    io:format("ldBl:pre-clcFun report ~p dst srv ~p~n", [Report, Server]),
    calc_supervisor:set_task(Server, {Pid, F, MsgRef}),
    ok.

