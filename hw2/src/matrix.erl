-module(matrix). 
-compile([
    zeros/2, 
    get_row/2, 
    get_column/2, 
    set_element/4,
    inner_product/2
]).

% generate a matrix with X rows and Y columns with zeros 
zeros(X, Y) ->
    list_to_tuple([list_to_tuple([0 || _Y <- lists:seq(1, Y)]) || _X <- lists:seq(1, X)]).

% return the Row of a Matrix in a tuple format 
get_row(Mat, Row) ->
    element(Row, Mat).

% return the Coloumn of a Matrix in a tuple format 
get_column(Mat, Col) ->
    list_to_tuple([element(Col,ColData) || ColData <- tuple_to_list(Mat)]).

% return a new Matrix which is a copy of OldMat with a NewVal as the value of Row,Col 
set_element(Row, Col, OldMat, NewVal) ->
    setelement(Row, OldMat, setelement(Col, element(Row, OldMat), NewVal)).

% return the inner product of Row a row vector and Col a column vector.
inner_product(Row, Col) ->
    RowVector = tuple_to_list(Row),
    ColumnVector = tuple_to_list(Col),
    [ X * Y || X <- RowVector, Y <- ColumnVector ].