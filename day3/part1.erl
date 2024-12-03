-module(part1).
-export([solve/0, sum/1]).

solve() ->
    {_, Content} = file:read_file("./input"),
    {_, List} = re:run(Content, "mul\\(\\d{1,3}\\,\\d{1,3}\\)", [global, {capture, all, list}]),
    sum(List).

sum([H|T]) ->
    {_, [[A], [B]]} = re:run(H, "\\d{1,3}", [global, {capture, all, list}]),
    list_to_integer(A) * list_to_integer(B) + sum(T);
sum([]) -> 0.
