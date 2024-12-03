-module(part2).
-export([solve/0, sum/1]).

solve() ->
    {_, Content} = file:read_file("./input"),
    {_, List} = re:run(Content, "(mul\\(\\d{1,3}\\,\\d{1,3}\\)|do\\(\\)|don\\'t\\(\\))", [global, {capture, all, list}]),
    sum(List).

sum([["don't()","don't()"]|T]) -> find_do(T);
sum([["do()","do()"]|T]) -> sum(T);
sum([[H, _]|T]) ->
    {_, [[A], [B]]} = re:run(H, "\\d{1,3}", [global, {capture, all, list}]),
    list_to_integer(A) * list_to_integer(B) + sum(T);
sum([]) -> 0.

find_do([["do()", "do()"]|T]) -> sum(T);
find_do([_|T]) -> find_do(T);
find_do([]) -> 0.
