-module(part2).
-export([solve/0]).

solve() ->
    Width = 141,
    {_, Content} = file:read_file("./input"),
    iterate(0, Width + 1, Content, Width).

iterate(Sum, Idx, Binary, Width) when Idx >= byte_size(Binary) - Width - 2 ->
    Sum;

iterate(Sum, Idx, Binary, Width) when Idx rem Width == Width - 2 ->
    iterate(Sum, Idx + 3, Binary, Width);

iterate(Sum, Idx, Binary, Width) ->
    X = {[
          binary:at(Binary, Idx - Width - 1),
          binary:at(Binary, Idx),
          binary:at(Binary, Idx + Width + 1)
         ],[
            binary:at(Binary, Idx - Width + 1),
            binary:at(Binary, Idx),
            binary:at(Binary, Idx + Width - 1)
           ]},
    iterate(Sum + xmas(X), Idx + 1, Binary, Width).

xmas({F, L}) when ((F == "MAS") or (F == "SAM")) and ((L == "MAS") or (L == "SAM")) -> 1;
xmas(_) -> 0.
