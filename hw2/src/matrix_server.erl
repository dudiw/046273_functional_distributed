-module(matrix_server). 
-compile(
    [start_server/0, 
    shutdown/0, 
    get_version/0, 
    mult/2, 
    explanation/0]).


start_server() -> 
    register(matrix_server, spawn(fun() -> loop(version_1) end)).

shutdown() -> 
    rpc(matrix_server, shutdown).

% MAKE SURE TO TEST get_version MULTIPLE TIMES !! IT WILL FAIL THE 2nd TIME
get_version() -> 
    MsgRef = make_ref(),
    rpc(matrix_server, {self(), MsgRef, get_version}).

mult(A,B) -> 
    MsgRef = make_ref(),
    rpc(matrix_server, {self(), MsgRef, {multiple, A, B}}).

rpc(Name, Request) ->
    Name ! Request,
    receive
        Response -> Response;
        _        -> ok
    end.

loop(VersionIdentifier) ->
    receive
        {Pid, MsgRef, {multiple, Mat1, Mat2}} ->
            Mat = mult(Mat1, Mat2),
            Pid ! {MsgRef, Mat},
            loop(VersionIdentifier);
        shutdown ->
                ok;
        {Pid, MsgRef, get_version} ->
            Pid ! {MsgRef, VersionIdentifier},
            loop(VersionIdentifier);
        sw_upgrade ->
            ?MODULE:loop(VersionIdentifier);
        _ ->
            loop(VersionIdentifier)            
    end.

explanation() -> 
    {"The supervisor and the server module should be separated so that the server can be upgraded without stopping the supervisor"}.