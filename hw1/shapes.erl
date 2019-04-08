-module(shapes).
-export([shapesArea/1, 
	shapesFilter/1, 
	shapesFilter2/1,
	squaresArea/1, 
	trianglesArea/1]
).


shapesArea({shapes, []}) -> 0;

shapesArea({shapes, [H | T]}) -> 
	area(H) + shapesArea({shapes, T}).

area({rectangle, {dim, Width, Height}}) 
	when Width > 0, Height > 0 -> 
		Width * Height;
area({triangle, {dim, Base, Height}}) 
	when Base > 0, Height > 0 -> 
		0.5 * Base * Height;
area({ellipse, {radius, Radius1, Radius2}}) 
	when Radius1 > 0, Radius2 > 0 -> 
		math:pi() * Radius1 * Radius2.

squaresArea({shapes, [H | T]}) -> 
	Filtered = shapesFilter2(square),
	shapesArea(Filtered({shapes, [H | T]})).

trianglesArea({shapes, [H | T]}) -> 
	Filtered = shapesFilter2(triangle),
	shapesArea(Filtered({shapes, [H | T]})).

valid({_shape, {dim, A, B}}) when A > 0, B > 0 -> true;
valid({_shape, {radius, A, B}}) when A > 0, B > 0 -> true.

shapesFilter(Shape) 
	when Shape =:= rectangle; 
	Shape =:= ellipse; 
	Shape =:= triangle -> 

	fun(Shapes) -> 
		{_shapes, Elements} = Shapes,
		{shapes, [Element || {Target, _Dim} = Element <- Elements, 
			valid(Element), Target =:= Shape]}
	end.

shapesFilter2(Shape) 
	when Shape =:= rectangle; 
	Shape =:= ellipse; 
	Shape =:= triangle -> 
		shapesFilter(Shape);

shapesFilter2(Shape) 
	when Shape =:= square; 
	Shape =:= circle -> 

	% Reshape descriptors of 'square' and 'circle' to 'rectangle' and 'ellipse' 
	Reshape = case Shape of
		square -> rectangle;
		circle -> ellipse
	end,
	Reshape,
	fun(Shapes) -> 
		Filter = shapesFilter(Reshape),
		{_shapes, Elements} = Filter(Shapes),
		{shapes, [Element || {_Target, {_Dim, A, B}} = Element <- Elements, A == B]}
	end.
