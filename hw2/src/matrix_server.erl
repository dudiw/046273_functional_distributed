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
    matrix_supervisor:start().

shutdown() -> 
    exit(whereis(matrix_server), shutdown).

get_version() -> 
    version_1.

mult(A,B) -> 
    rpc(matrix_server, {multiple, A, B}).

rpc(Name, Request) ->
    MsgRef = make_ref(),
    Name ! {self(), MsgRef, Request},
    receive
        {MsgRef, Response} -> 
            Response
    end.

loop() ->
    receive
        {Pid, MsgRef, {multiple, Mat1, Mat2}} ->
            matrix_dispatch:multiply({Pid, MsgRef, Mat1, Mat2}),
            loop();
        shutdown ->
            exit(shutdown),
            ok;
        {Pid, MsgRef, get_version} ->
            Pid ! {MsgRef, get_version()},
            loop();
        sw_upgrade ->
            ?MODULE:loop();
        _ ->
            loop()            
    end.

explanation() -> 
    {"The supervisor and the server module should be separated so that the server can be upgraded without stopping the supervisor"}.