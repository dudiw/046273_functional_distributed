-module(game_test).
-export([run/0]).


run() ->
	erlang:display("testing game module"),
	io:format("game:canWin(1) expected ~p  received ~p ~n",[true, game:canWin(1)]),
	io:format("game:canWin(2) expected ~p  received ~p ~n",[true, game:canWin(2)]),
	io:format("game:canWin(3) expected ~p received ~p ~n",[false, game:canWin(3)]),
	io:format("game:canWin(4) expected ~p  received ~p ~n",[true, game:canWin(4)]),
	io:format("game:canWin(5) expected ~p  received ~p ~n",[true, game:canWin(5)]),
	io:format("game:canWin(6) expected ~p received ~p ~n",[false, game:canWin(6)]),
	io:format("game:canWin(7) expected ~p  received ~p ~n",[true, game:canWin(7)]),
	{true, 1} = game:nextMove(1),
	{true, 2} = game:nextMove(2),
	false     = game:nextMove(3),
	{true, 1} = game:nextMove(4),
	{true, 2} = game:nextMove(5),
	false     = game:nextMove(6),
	{true, 1} = game:nextMove(7),
	erlang:display(game:explanation()),
	ok.
