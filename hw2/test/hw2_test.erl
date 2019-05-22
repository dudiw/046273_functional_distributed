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
    I2 = {{ 1, 0},{ 0, 1}},
    A2 = {{ 3, 6},{ 9,12}},
    B2 = {{13,90},{ 1, 0}},
    I4 = {{1, 0, 0, 0}, {0, 1, 0, 0},{0, 0, 1, 0}, {0, 0, 0, 1}},
    A4 = {{1, 2, 3, 4}, {5, 6, 7, 8},{9, 10, 11, 12}, {13, 14, 15, 16}},
    B4 = {{13, 14, 15, 16}, {3, 4, 1, 2},{11, 12, 9, 10}, {5, 6, 7, 8}},
    A4_3 = {{1, 2, 3}, {5, 6, 7},{9, 10, 11}, {13, 14, 15}},
    B3_4 = {{13, 14, 15, 16}, {3, 4, 1, 2},{11, 12, 9, 10}},

    A2_A2 = {{63,90},{135,198}},
    B2_B2 = {{259,1170},{13,90}},
    A2_B2 = {{45,270},{129,810}},
    B2_A2 = {{849,1158},{3,6}},
    A4_A4 = {
        { 90,100,110,120},
        {202,228,254,280},
        {314,356,398,440},
        {426,484,542,600}
    },
    B4_B4 = {
        {456,514,456,514},
        { 72, 82, 72, 82},
        {328,370,328,370},
        {200,226,200,226}
    },
    A4_B4 = {
        { 72, 82, 72, 82},
        {200,226,200,226},
        {328,370,328,370},
        {456,514,456,514}
    },
    B4_A4 = {
        {426,484,542,600},
        { 58, 68, 78, 88},
        {282,324,366,408},
        {202,228,254,280}
    },
    A4_3_B3_4 = {
        { 52, 58, 44, 50},
        {160,178,144,162},
        {268,298,244,274},
        {376,418,344,386}
    },
    B3_4_A4_3 = {
        {426,484,542},
        { 58, 68, 78},
        {282,324,366}
    },

    % test 2*2 matrices: - matlab code to do the same (for the correct results) in the end of the test
    io:format("start5 ~n"),
    multiply_match_matrices(I2, A2, A2), % get A2
    multiply_match_matrices(I2, B2, B2), % get B2
    multiply_match_matrices(A2, I2, A2), % get A2
    multiply_match_matrices(B2, I2, B2), % get B2
    
    multiply_match_matrices(A2, A2, A2_A2), % get A2_A2
    multiply_match_matrices(A2, B2, A2_B2), % get A2_B2
    multiply_match_matrices_async(B2, B2, B2_B2), % get B2_B2
    multiply_match_matrices_async(B2, A2, B2_A2), % get B2_A2

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
    multiply_match_matrices_async(A4, A4, A4_A4), % get A4_A4
    multiply_match_matrices_async(B4, B4, B4_B4), % get B4_B4
    io:format("start7.1 ~n"),
    multiply_match_matrices_async(A4, B4, A4_B4), % get A4_B4
    multiply_match_matrices_async(B4, A4, B4_A4), % get B4_A4

    % test different size matrices matrices:
    io:format("start7.2 ~n"),
    multiply_match_matrices(A4_3, B3_4, A4_3_B3_4), % get A4_3_B4_3
    multiply_match_matrices_async(B3_4, A4_3, B3_4_A4_3), % get B3_4_A4_3

    %make sure we get reply after server dies:
    io:format("start7.3 ~n"),
    matrix_server:mult(I2, A2 ), %get A2
    matrix_server:mult(I2, B2 ), %get B2

    io:format("start7.4 ~n"),
    matrix_server:mult(A2, I2 ), %get A2
    matrix_server:mult(B2, I2 ), %get B2
    matrix_server:mult(A2, A2 ), 
    matrix_server:mult(B2, B2 ), 

    io:format("start8 ~n"),
    io:format("matrix_server:explanation() ~n ~p ~n",[matrix_server:explanation()]),
    matrix_server:shutdown().


multiply_match_matrices(A, B, Ref) ->
    Result = matrix_server:mult(A, B),
    multiply_debug(A, B, Ref, Result).

multiply_match_matrices_async(A, B, Ref) ->
    Pid = self(),
    MsgRef = make_ref(),
    Request = {Pid, MsgRef, {multiple, A, B}},
    matrix_server ! Request,
    receive
            {MsgRef, Response} -> 
                multiply_debug(A, B, Ref, Response)
    end.

multiply_debug(A, B, Ref, Result) ->
    if
        Ref == Result ->
            io:format("Pass ~n");
        true -> 
            io:format("Ref ~p Result ~p match ~p ~n",[Ref, Result, Ref == Result])
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
