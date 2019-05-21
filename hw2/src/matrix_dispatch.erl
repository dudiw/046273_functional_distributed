-module(matrix_dispatch). 
-export([multiply/1]).

% spawn a process to manage matrix multiplication.
multiply(Request) ->
    spawn(fun() -> multiply_async(Request) end).

% spawn worker processes to perform the multiplication
multiply_async(Request) ->
    {Pid, MsgRef, Mat1, Mat2} = Request,
    SelfPid = self(),
    {M, N} = matrix:product_dimension(Mat1, Mat2),

    % spawn 'worker' processes to perform the multiplication
    [spawn(fun() ->
           multiply_task(SelfPid, Mat1, Row, Mat2, Col)
         end) || Row <- lists:seq(1, M), Col <- lists:seq(1, N)],

    % total count of product elements
    Pending = M * N,
    Target = matrix:zeros(M, N),

    % wait for the workers to complete the multiplication
    Result = await_response(Pending, Target),
    Pid ! {MsgRef, Result}.

await_response(0, Result) ->
    Result;
await_response(Pending, Target) ->
    receive
        {Row, Col, Value} ->
            Update = matrix:set_element(Row, Col, Target, Value),
            await_response(Pending - 1, Update)
    end.

% calculate the element [Row, Col] of the matrix product Mat1 · Mat2
multiply_task(CallerPid, Mat1, Row, Mat2, Col) ->
    Product = matrix:inner_product(Mat1, Row, Mat2, Col),
    CallerPid ! {Row, Col, Product}.
