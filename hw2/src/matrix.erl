-module(matrix). 
-export([
    size/1,
    row/2, 
    column/2, 
    zeros/2, 
    set_element/4,
    inner_product/4,
    product_dimension/2
]).

% generate a matrix with X rows and Y columns with zeros 
zeros(X, Y) ->
    list_to_tuple([list_to_tuple([0 || _Y <- lists:seq(1, Y)]) || _X <- lists:seq(1, X)]).

% return the Row of a Matrix in a tuple format 
row(Mat, Row) ->
    element(Row, Mat).

% return the Coloumn of a Matrix in a tuple format 
column(Mat, Col) ->
    list_to_tuple([element(Col,ColData) || ColData <- tuple_to_list(Mat)]).

% return a new Matrix which is a copy of OldMat with a NewVal as the value of Row,Col 
set_element(Row, Col, OldMat, NewVal) ->
    setelement(Row, OldMat, setelement(Col, element(Row, OldMat), NewVal)).

% return the inner product of Row and Col indices of Mat a matrix.
inner_product(Mat1, Row, Mat2, Col) ->
    RowVector = tuple_to_list(row(Mat1, Row)),
    ColumnVector = tuple_to_list(column(Mat2, Col)),
    lists:foldl(
        fun({R, C}, Sum) -> 
            R * C + Sum end, 
        0, lists:zip(RowVector, ColumnVector)).

% return the matrix dimensions A[M x N] (length Row x Column). 
size(Mat) ->
    M = tuple_size(row(Mat, 1)),
    N = tuple_size(column(Mat, 1)),
    {M, N}.

% return the dimensions of the product A · B = C
% A              ·  B              = C             
%  [Row1 x Col1]     [Row2 x Col2]    [Row1 x Col2]
product_dimension(Mat1, Mat2) ->
    {Row1, _Col1} = matrix:size(Mat1),
    {_Row2, Col2} = matrix:size(Mat2),
    {Row1, Col2}.