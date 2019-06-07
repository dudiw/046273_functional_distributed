-module(hw3_test).
-export([run/0]).


run() ->
    io:format("hw3_test:run ~n"),
    io:format("loadBalance1 ~p ~n", [loadBalance:startServers()]),
    io:format("loadBalance2.1 ~p ~n", [whereis(server1)]),
    io:format("loadBalance2.2 ~p ~n", [whereis(server2)]),
    io:format("loadBalance2.3 ~p ~n", [whereis(server3)]),

    io:format("hw3_test:numberOfRunningFunctions ~n"),
    io:format("numberOfRunningFunctions1 ~p ~n", [loadBalance:numberOfRunningFunctions(1)]),
    io:format("numberOfRunningFunctions2 ~p ~n", [loadBalance:numberOfRunningFunctions(2)]),
    io:format("numberOfRunningFunctions3 ~p ~n", [loadBalance:numberOfRunningFunctions(3)]),

    io:format("hw3_test:start_async_task ~n"),
    lists:foreach(fun(N) -> start_async_task(N), timer:sleep(1) end, lists:seq(1,10000)),

    io:format("hw3_test:sleep 2 sec ~n"),
    timer:sleep(8000),
    io:format("loadBalance3 ~p ~n", [loadBalance:stopServers()]).

start_async_task(N) ->
    spawn(fun() ->
            ClientPid = self(),
            MsgRef = make_ref(),            
            F = fun() -> timer:sleep(3000), N end,
            loadBalance:calcFun(ClientPid, F, MsgRef),
            receive
                {MsgRef, F_result} -> io:format("async_t res ~p ref ~p pid ~p ~n", [F_result, MsgRef, ClientPid])
            end
         end).

% get_version_async(Ref) ->
%     Pid = self(),
%     MsgRef = make_ref(),
%     Request = {Pid, MsgRef, get_version},
%     matrix_server ! Request,
%     receive
%             {MsgRef, Response} -> 
%                 message_debug("get_version", "rpc", Ref, Response)
%     end.
