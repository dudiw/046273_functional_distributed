-module(game).
-export([canWin/1, nextMove/1, explanation/0]).


canWin(1) -> true;
canWin(2) -> true;
canWin(N) when N > 2 ->
    not (canWin(N - 2) and canWin(N - 1)).

nextMove(1) -> {true, 1};
nextMove(2) -> {true, 2};
nextMove(N) when N > 2 -> 
    ResultTwo = nextMove(N - 2),
    LoseTwo = case ResultTwo of
        {true, _} -> true;
        false -> false
    end,
    ResultOne = nextMove(N - 1),
    LoseOne = case ResultOne of
        {true, _} -> true;
        false -> false
    end,
    if
        not LoseTwo -> {true, 2};
        not LoseOne -> {true, 1};
        true -> false
    end.

explanation() -> {'Each step of the recursive call (of canWin or nextMove) needs to account for the independent outcomes of the next two recursive calls of removing either 1 or 2 matches. Hence the challenge in implementing as a tail recursion'}.
