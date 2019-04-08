-module(game_test).
-export([run/0]).


run() ->
	true=game:canWin(1),
	true=game:canWin(2),
	false = game:canWin(3),
	true = game:canWin(4),
	true = game:canWin(5),
	true = game:canWin(7),
	true=game:canWin(4),
	{true,1}=game:nextMove(1),
	{true,2}=game:nextMove(2),
	false = game:nextMove(3),
	{true,1} = game:nextMove(4),
	{true,2}= game:nextMove(5),
	false = game:nextMove(6),
	ok.




