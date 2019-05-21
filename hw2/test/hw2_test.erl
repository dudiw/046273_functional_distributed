-module(hw2_test).
-export([run/0]).


run() ->
    io:format("start0 ~p ~n", [self()]),
    matrix_server:start_server(),
    io:format("start0.1 ~p ~n", [matrix_server:get_version()]),
    io:format("start0.2 ~p ~n", [matrix_server:get_version()]),
    c:i(), %%%Here you should make sure that the process and the supervisor are running
    io:format("start1.1 ~p ~n", [whereis(matrix_server)]),
    % make sure registration worked- could also use registered().

    io:format("start2 ~p ~n", [whereis(matrix_server)]),
    whereis(matrix_server) ! shutdown,
    io:format("start2.1 ~n"),
    matrix_server:start_server(),
    io:format("start2.2 ~p ~n", [matrix_server:get_version()]),
    io:format("start2.2 ~n"),
    matrix_server:shutdown(),
    io:format("start2.3 ~n"),
    c:i(),% make sure both are dead
    whereis(matrix_server),% should be 'undefined'

    io:format("start3 ~n"),
    % test supervisor
    matrix_server:start_server(),
    whereis(matrix_server),
    c:i(),%make sure both process are back to life.

    %test version change - change the version number in the source code before each call
    % note that you must compile between versions.
    io:format("start4 ~n"),
    whereis(matrix_server) ! sw_upgrade,
    matrix_server:get_version(),%version 2
    io:format("start4.1 ~p ~n",[whereis(matrix_server)]),
    whereis(matrix_server) ! sw_upgrade,
    whereis(matrix_server) ! sw_upgrade,
    matrix_server:get_version(),%version 4
    whereis(matrix_server) ! sw_upgrade,
    io:format("start4.2 ~p ~n", [matrix_server:get_version()]),%version 5

    %test matrix multiplication:
    I2 = {{1, 0}, {0, 1}},
    A2 = {{3, 6}, {9, 12}},
    B2 = {{13, 90}, {1, 0}},
    I4 = {{1, 0, 0, 0}, {0, 1, 0, 0},{0, 0, 1, 0}, {0, 0, 0, 1}},
    A4 = {{1, 2, 3, 4}, {5, 6, 7, 8},{9, 10, 11, 12}, {13, 14, 15, 16}},
    B4 = {{13, 14, 15, 16}, {3, 4, 1, 2},{11, 12, 9, 10}, {5, 6, 7, 8}},
    A4_3 = {{1, 2, 3}, {5, 6, 7},{9, 10, 11}, {13, 14, 15}},
    B3_4 = {{13, 14, 15, 16}, {3, 4, 1, 2},{11, 12, 9, 10}},

    % test 2*2 matrices: - matlab code to do the same (for the correct results) in the end of the test
    io:format("start5 ~n"),
    multiply_match_matrices(I2, A2, A2), % get A2
    multiply_match_matrices(I2, B2, B2), % get B2
    multiply_match_matrices(A2, I2, A2), % get A2
    multiply_match_matrices(B2, I2, B2), % get B2
    matrix_server:mult(A2, A2 ), 
    matrix_server:mult(B2, B2 ), 
    matrix_server:mult(A2, B2 ), 
    matrix_server:mult(B2, A2 ), 

    % test 4*4 matrices:
    io:format("start6.1 sync ~n"),
    multiply_match_matrices(I4, A4, A4), % get A4
    multiply_match_matrices(I4, B4, B4), % get B4
    multiply_match_matrices(A4, I4, A4), % get A2
    multiply_match_matrices(B4, I4, B4), % get B2
    io:format("start6.2 async ~n"),
    multiply_match_matrices_async(I4, A4, A4), % get A4
    multiply_match_matrices_async(I4, B4, B4), % get B4
    multiply_match_matrices_async(A4, I4, A4), % get A2
    multiply_match_matrices_async(B4, I4, B4), % get B2

    io:format("start7 ~n"),
    multiply_match_matrices_async(A4, A4, A4), % get A4
    multiply_match_matrices_async(B4, B4, B4), % get B4
    multiply_match_matrices_async(A4, B4, A2), % get A2
    multiply_match_matrices_async(B4, A4, B2), % get B2

    % test different size matrices matrices:
    matrix_server:mult(A4_3, B3_4 ), 

    %make sure we get reply after server dies:
    matrix_server:mult(I2, A2 ), %get A2
    matrix_server:mult(I2, B2 ), %get B2

    matrix_server:mult(A2, I2 ), %get A2
    matrix_server:mult( B2, I2 ), %get B2
    matrix_server:mult(A2, A2 ), 
    matrix_server:mult(B2, B2 ), 

    io:format("start8 ~n"),
    io:format("matrix_server:explanation() ~n ~p ~n",[matrix_server:explanation()]),
    matrix_server:shutdown().

multiply_match_matrices(A, B, Ref) ->
    Result = matrix_server:mult(A, B),
    io:format("Ref ~p Result ~p match ~p ~n",[Ref, Result, Ref == Result]).

multiply_match_matrices_async(A, B, Ref) ->
    Pid = self(),
    MsgRef = make_ref(),
    Request = {Pid, MsgRef, {multiple, A, B}},
    matrix_server ! Request,
    receive
            {MsgRef, Response} -> 
                io:format("Ref ~p Result ~p match ~p ~n",[Ref, Response, Ref == Response])
    end.

%%%%%%%%%%%%%%%%%%%%matlab code for testing: run line by line 
%
%
%clc;
%clear;
%close all;
%% define variables
%I2 = [1, 0; 0, 1];
%A2 = [3, 6 ; 9, 12];
%B2 = [13, 90; 1, 0];
%
%I4 = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1];
%A4 = [1, 2, 3, 4; 5, 6, 7, 8;9, 10, 11, 12; 13, 14, 15, 16];
%B4 = [13, 14, 15, 16; 3, 4, 1, 2; 11, 12, 9, 10; 5, 6, 7, 8];
%A4_3 = [1, 2, 3; 5, 6, 7; 9, 10, 11;13, 14, 15];
%B3_4 = [13, 14, 15, 16; 3, 4, 1, 2; 11, 12, 9, 10];
%
%%calculate:
%A2^2
%B2^2
%A2*B2 
%B2*A2
%
%
%% test 4*4 matrices:
%A4*A4 
%B4*B4
%A4*B4 
%B4*A4
%
%% test different size matrices matrices:
%A4_3*B3_4
