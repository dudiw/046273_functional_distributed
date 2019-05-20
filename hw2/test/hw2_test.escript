#!/usr/bin/env escript
%%%%%%%%%%%%%%%%%%% Testing Script For HW2 In Erlang, May 2016 %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Test start, shutdown:
cd("../src").
c(matrix).
c(helper).
c(restarter).
c(matrix_server).

matrix_server:start_server().
i(). %%%Here you should make sure that the process and the supervisor are running
whereis(matrix_server).% make sure registration worked- could also use registered().

matrix_server:shutdown().
i().% make sure both are dead
whereis(matrix_server).% should be 'undefined'


% test supervisor
matrix_server:start_server().
whereis(matrix_server).
%%matrix_server!stop. doesnt work for me - I just changed the code to exit
i().%make sure both process are back to life.

%test version change - change the version number in the source code before each call
% note that you must compile between versions.
matrix_server:sw_upgrade().
matrix_server:get_version().%version 2
matrix_server:sw_upgrade().
matrix_server:sw_upgrade().
matrix_server:get_version().%version 4
matrix_server:sw_upgrade().
matrix_server:get_version().%version 5

%test matrix multiplication:
I2 = {{1, 0}, {0, 1}}.
A2 = {{3, 6}, {9, 12}}.
B2 = {{13, 90}, {1, 0}}.
I4 = {{1, 0, 0, 0}, {0, 1, 0, 0},{0, 0, 1, 0}, {0, 0, 0, 1}}.
A4 = {{1, 2, 3, 4}, {5, 6, 7, 8},{9, 10, 11, 12}, {13, 14, 15, 16}}.
B4 = {{13, 14, 15, 16}, {3, 4, 1, 2},{11, 12, 9, 10}, {5, 6, 7, 8}}.
A4_3 = {{1, 2, 3}, {5, 6, 7},{9, 10, 11}, {13, 14, 15}}.
B3_4 = {{13, 14, 15, 16}, {3, 4, 1, 2},{11, 12, 9, 10}}.


% test 2*2 matrices: - matlab code to do the same (for the correct results) in the end of the test
matrix_server:mult(I2, A2 ). %get A2
matrix_server:mult(I2, B2 ). %get B2
matrix_server:mult(A2, I2 ). %get A2
matrix_server:mult( B2, I2 ). %get B2
matrix_server:mult(A2, A2 ). 
matrix_server:mult(B2, B2 ). 
matrix_server:mult(A2, B2 ). 
matrix_server:mult(B2, A2 ). 

% test 4*4 matrices:
matrix_server:mult(I4, A4). %get A4
matrix_server:mult(I4, B4). %get B4
matrix_server:mult(A4, I4). %get A2
matrix_server:mult(B4, I4). %get B2
matrix_server:mult(A4, A4 ). 
matrix_server:mult(B4, B4 ). 
matrix_server:mult(A4, B4 ). 
matrix_server:mult(B4, A4 ). 

% test different size matrices matrices:
matrix_server:mult(A4_3, B3_4 ). 

%make sure we get reply after server dies:
matrix_server:mult(I2, A2 ). %get A2
matrix_server:mult(I2, B2 ). %get B2

matrix_server:mult(A2, I2 ). %get A2
matrix_server:mult( B2, I2 ). %get B2
matrix_server:mult(A2, A2 ). 
matrix_server:mult(B2, B2 ). 

matrix_server:explanation().
matrix_server:shutdown().

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
