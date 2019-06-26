-module(hw3_test).
-export([run/0]).


run() ->
    io:format("hw3_test:run ~n"),
    io:format("loadBalance1:start ~p ~n", [loadBalance:startServers()]),
    io:format("hw3_test:whereis(server1) ~p ~n", [whereis(server1)]),
    io:format("hw3_test:whereis(server2) ~p ~n", [whereis(server2)]),
    io:format("hw3_test:whereis(server3) ~p ~n", [whereis(server3)]),

    io:format("hw3_test:generate_tasks start ~n"),
    TaskDuration = 3000,
    Count = 300,
    {Duration,_} = timer:tc(fun() -> generate_tasks(TaskDuration, Count) end),
    Delay = round(Duration/1000) + 1,
    io:format("hw3_test:generate_tasks done ~p ms ~n", [Delay]),

    timer:sleep(round(Delay/10)),
    io:format("hw3_test:countTasks1 ~n"),
    io:format("loadBalance:countTasks1 ~p ~n", [loadBalance:numberOfRunningFunctions(1)]),
    io:format("loadBalance:countTasks2 ~p ~n", [loadBalance:numberOfRunningFunctions(2)]),
    io:format("loadBalance:countTasks3 ~p ~n", [loadBalance:numberOfRunningFunctions(3)]),

    timer:sleep(round(Delay/10)),
    io:format("hw3_test:countTasks2 ~n"),
    io:format("loadBalance:countTasks1 ~p ~n", [loadBalance:numberOfRunningFunctions(1)]),
    io:format("loadBalance:countTasks2 ~p ~n", [loadBalance:numberOfRunningFunctions(2)]),
    io:format("loadBalance:countTasks3 ~p ~n", [loadBalance:numberOfRunningFunctions(3)]),

    timer:sleep(round(Delay/10)),
    io:format("hw3_test:countTasks3 ~n"),
    io:format("loadBalance:countTasks1 ~p ~n", [loadBalance:numberOfRunningFunctions(1)]),
    io:format("loadBalance:countTasks2 ~p ~n", [loadBalance:numberOfRunningFunctions(2)]),
    io:format("loadBalance:countTasks3 ~p ~n", [loadBalance:numberOfRunningFunctions(3)]),
    
    io:format("hw3_test:sleep ~p ms ~n", [TaskDuration + Delay]),
    timer:sleep(TaskDuration + Delay),
    io:format("loadBalance3:stop ~p ~n", [loadBalance:stopServers()]).

generate_tasks(TaskDuration, Count) ->
    lists:foreach(fun(N) -> start_async_task(N, TaskDuration) end, lists:seq(1,Count)).

start_async_task(N, TaskDuration) ->
    spawn(fun() ->
            ClientPid = self(),
            MsgRef = make_ref(),            
            F = fun() -> timer:sleep(TaskDuration), N end,
            loadBalance:calcFun(ClientPid, F, MsgRef),
            receive
                {MsgRef, F_result} -> ok
              % {MsgRef, F_result} -> io:format("async_t res ~p ref ~p pid ~p ~n", [F_result, MsgRef, ClientPid])
            end
         end).
