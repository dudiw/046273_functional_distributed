-module(matrix_server). 
-export([
    start_server/0, 
    shutdown/0, 
    get_version/0, 
    mult/2, 
    explanation/0,
    loop/0
]).

start_server() -> 
    % register(matrix_server, spawn(fun()->loop() end)),
    matrix_supervisor:start().

shutdown() -> 
    io:format("shutdown ~n"),
    rpc(matrix_server, shutdown).

% MAKE SURE TO TEST get_version MULTIPLE TIMES !! IT WILL FAIL THE 2nd TIME
get_version() -> 
    version_1.

mult(A,B) -> 
    MsgRef = make_ref(),
    rpc(matrix_server, {self(), MsgRef, {multiple, A, B}}).

rpc(Name, Request) ->
    io:format("rpc1 ~p ~n",[Name]),
    io:format("rpc2 ~p ~n",[whereis(Name)]),
    Name ! Request,
    receive
        Response -> 
            io:format("Response ~n"),
            Response;
        _ -> 
            io:format("ok ~n"),
            ok
    end.

loop() ->
    receive
        {Pid, MsgRef, {multiple, Mat1, Mat2}} ->
            matrix_dispatch:multiply({Pid, MsgRef, Mat1, Mat2}),
            loop();
        shutdown ->
            io:format("shutdown2 ~p ~n",[whereis(matrix_server)]),
            exit(shutdown);
        {Pid, MsgRef, get_version} ->
            io:format("get_versionloop ~n"),
            Pid ! {MsgRef, get_version()},
            loop();
        sw_upgrade ->
            io:format("sw_upgrade ~p ~n",[get_version()]),
            ?MODULE:loop();
        _ ->
            io:format("empty loop ~p ~n",[get_version()]),
            loop()            
    end.

explanation() -> 
    {"The supervisor and the server module should be separated so that the server can be upgraded without stopping the supervisor"}.