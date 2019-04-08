-module(shapes_test).
-export ([run/0]).


%---valid shapes
validRectangle1() -> {rectangle,{dim,1,2}}.		% size 2
validRectangle3() -> {rectangle,{dim,5,5}}.		% size 25
validRectangle4() -> {rectangle,{dim,1,1}}.		% size 1

validTriangle2() -> {triangle,{dim,3,2}}.		% size 3
validTriangle3() -> {triangle,{dim,4,4}}.		% size 8

validEllipse1() -> {ellipse,{radius,1,2}}.       	
validEllipse2() -> {ellipse,{radius,3,2}}.			

%---valid structs
validShapes1() -> {shapes,[validEllipse1(), validEllipse1(), validRectangle1(), validTriangle2(), validRectangle3() ]}.
validShapes4() -> {shapes,[validEllipse2(),validRectangle1(), validTriangle2() , validTriangle3(), validRectangle3(), validRectangle4()]}.


run() ->
	erlang:display("testing shapes module"),
	io:format("expecting ~p and got ~p ~n",[57.84955592153876,shapes:shapesArea(validShapes4())]),
	RectFun1 = shapes:shapesFilter(rectangle),
	io:format("expecting ~p and got ~p ~n",[{shapes,[{rectangle,{dim,1,2}},{rectangle,{dim,5,5}}]},RectFun1(validShapes1())]),

	% Additional tests

	Square1 = {rectangle, {dim, 1, 1}},
	Rectangle2 = {rectangle, {dim, 2, 4}},
	Rectangle_ill = {rectangle, {dim, 1, 0}},
	Rectangle_ill2 = {rectangle, {dim, -1, 1}},
	Triangle1 = {triangle, {dim, 1, 1}},
	Triangle2 = {triangle, {dim, 2, 2}},
	Triangle_ill = {triangle, {dim, -1, 1}},
	Ellipse1 = {ellipse, {radius, 1, 2}},
	Circle2 = {ellipse, {radius, 1, 1}},
	Ellipse_ill = {ellipse, {radius, -1, 1}},

	0 = shapes:shapesArea({shapes, []}),
	1 = shapes:shapesArea({shapes, [Square1]}),
	14.141592653589793 = shapes:shapesArea({shapes, [Square1, Triangle2, Rectangle2, Circle2]}),

	try shapes:shapesArea({shapes, [Square1, Square1, Rectangle_ill]}) of
		_ -> erlang:display("45 expected error not thrown!!! Problem in your code")
	catch
		error:Error0 -> erlang:display({error, caught, Error0})
	end,

	try shapes:shapesArea({shapes, [Square1, Square1, Rectangle_ill2]}) of
		_ -> erlang:display("51 expected error not thrown!!! Problem in your code")
	catch
		error:Error1 -> erlang:display({error, caught, Error1})
	end,

	0 = shapes:squaresArea({shapes, [Circle2, Triangle1, Triangle2, Ellipse1]}), %no squares.
	1 = shapes:squaresArea({shapes, [Circle2, Triangle1, Square1]}),

	try shapes:shapesArea({shapes, [Circle2, Triangle_ill, Square1]}) of
		_ -> erlang:display("60 expected error not thrown!!! Problem in your code")
	catch
		error:Error2 -> erlang:display({error, caught, Error2})
	end,

	try shapes:squaresArea({shapes, [Circle2, Triangle_ill, Square1]}) of
		_ -> erlang:display("66 expected error not thrown!!! Problem in your code")
	catch
		error:Error3 -> erlang:display({error, caught, Error3})
	end,
	2 = shapes:squaresArea({shapes, [Square1, Circle2, Rectangle2, Triangle1, Square1]}),

	0 = shapes:trianglesArea({shapes, [Circle2, Rectangle2, Rectangle2, Ellipse1]}), %no tri.
	0.5 = shapes:trianglesArea({shapes, [Circle2, Triangle1, Square1]}),

	try shapes:trianglesArea({shapes, [Circle2, Triangle_ill, Square1]}) of
		_ -> erlang:display("76 expected error not thrown!!! Problem in your code")
	catch
		error:Error4 -> erlang:display({error, caught, Error4})
	end,

	2.5 = shapes:trianglesArea({shapes, [Triangle2, Circle2, Rectangle2, Triangle1, Square1]}),

	F1 = shapes:shapesFilter(rectangle),
	F2 = shapes:shapesFilter(triangle),
	F3 = shapes:shapesFilter(ellipse),

	({shapes, []}) = F1({shapes, []}), %empty
	({shapes, []}) = F1({shapes, [Ellipse1]}), %no rectangle
	({shapes, [Square1]}) = F1({shapes, [Square1]}),
	({shapes, [Square1]}) = F1({shapes, [Square1, Ellipse1]}),
	({shapes, [Square1, Rectangle2]}) = F1({shapes, [Square1, Triangle1, Rectangle2]}),

	try F1({shapes, [Square1, Ellipse_ill]}) of
		_ -> erlang:display("94 expected error not thrown!!! Problem in your code")
	catch
		error:Error5 -> erlang:display({error, caught, Error5})
	end,

	({shapes, []}) = F2({shapes, []}), %empty
	({shapes, []}) = F2({shapes, [Ellipse1]}), %no triangle
	({shapes, [Triangle1]}) = F2({shapes, [Triangle1]}),
	({shapes, [Triangle1]}) = F2({shapes, [Triangle1, Ellipse1]}),
	({shapes, [Triangle1, Triangle2]}) = F2({shapes, [Square1, Triangle1, Triangle2]}),

	try F2({shapes, [Square1, Ellipse_ill]}) of
		_ -> erlang:display("106 expected error not thrown!!! Problem in your code")
	catch
	error:Error6 -> erlang:display({error, caught, Error6})
	end,

	({shapes, []}) = F3({shapes, []}), %empty
	({shapes, []}) = F3({shapes, [Rectangle2]}), %no ellipse
	({shapes, [Ellipse1]}) = F3({shapes, [Ellipse1]}),
	({shapes, [Ellipse1]}) = F3({shapes, [Square1, Ellipse1]}),
	({shapes, [Ellipse1, Circle2]}) = F3({shapes, [Ellipse1, Triangle1, Circle2]}),

	try F3({shapes, [Square1, Ellipse_ill]}) of
		_ -> erlang:display("118 expected error not thrown!!! Problem in your code")
	catch
		error:Error7 -> erlang:display({error, caught, Error7})
	end,

	F4 = shapes:shapesFilter(rectangle),
	F5 = shapes:shapesFilter2(square),
	F6 = shapes:shapesFilter(triangle),

	({shapes, []}) = F4({shapes, []}), %empty
	({shapes, []}) = F4({shapes, [Ellipse1]}), %no rectangle
	({shapes, [Square1]}) = F4({shapes, [Square1]}),
	({shapes, [Square1]}) = F4({shapes, [Square1, Ellipse1]}),
	({shapes, [Square1, Rectangle2]}) = F4({shapes, [Square1, Triangle1, Rectangle2]}),

	try F4({shapes, [Square1, Ellipse_ill]}) of
		_ -> erlang:display("134 expected error not thrown!!! Problem in your code")
	catch
		error:Error8 -> erlang:display({error, caught, Error8})
	end,

	({shapes, []}) = F5({shapes, []}), %empty
	({shapes, []}) = F5({shapes, [Ellipse1]}), %no square
	({shapes, [Square1]}) = F5({shapes, [Square1]}),
	({shapes, [Square1]}) = F5({shapes, [Square1, Ellipse1]}),
	({shapes, [Square1]}) = F5({shapes, [Square1, Triangle1, Rectangle2]}),

	try F5({shapes, [Square1, Ellipse_ill]}) of
		_ -> erlang:display("146 expected error not thrown!!! Problem in your code")
	catch
		error:Error9 -> erlang:display({error, caught, Error9})
	end,

	({shapes, []}) = F6({shapes, []}), %empty
	({shapes, []}) = F6({shapes, [Ellipse1]}), %no triangle
	({shapes, [Triangle1]}) = F6({shapes, [Triangle1]}),
	({shapes, [Triangle1]}) = F6({shapes, [Triangle1, Ellipse1]}),
	({shapes, [Triangle1, Triangle2]}) = F6({shapes, [Square1, Triangle1, Triangle2]}),

	try F6({shapes, [Square1, Ellipse_ill]}) of
		_ -> erlang:display("158 expected error not thrown!!! Problem in your code")
	catch
		error:Error10 -> erlang:display({error, caught, Error10})
	end,

	F7 = shapes:shapesFilter(ellipse),
	({shapes, []}) = F7({shapes, []}), %empty
	({shapes, []}) = F7({shapes, [Rectangle2]}), %no ellipse
	({shapes, [Ellipse1]}) = F7({shapes, [Ellipse1]}),
	({shapes, [Ellipse1]}) = F7({shapes, [Square1, Ellipse1]}),
	({shapes, [Ellipse1, Circle2]}) = F7({shapes, [Ellipse1, Triangle1, Circle2]}),

	try F7({shapes, [Square1, Ellipse_ill]}) of
		_ -> erlang:display("171 expected error not thrown!!! Problem in your code")
	catch
		error:Error11 -> erlang:display({error, caught, Error11})
	end,

	F8 = shapes:shapesFilter2(circle),
	({shapes, []}) = F8({shapes, []}), %empty
	({shapes, []}) = F8({shapes, [Rectangle2]}), %no circle
	({shapes, [Circle2]}) = F8({shapes, [Circle2]}),
	({shapes, [Circle2]}) = F8({shapes, [Square1, Circle2]}),
	({shapes, [Circle2]}) = F8({shapes, [Ellipse1, Triangle1, Circle2]}),

	try F8({shapes, [Square1, Ellipse_ill]}) of
		_ -> erlang:display("184 expected error not thrown!!! Problem in your code")
	catch
		error:Error12 -> erlang:display({error, caught, Error12})
	end,
	erlang:display("Shapes: Pass!"),
	ok.
