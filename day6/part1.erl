-module(part1).
-export([solve/0]).

solve() ->
    W = 131,
    O = $#,
    Dir = [-W, +1, W, -1],

    {_, Lab} = file:read_file("./input"),
    Pos = find_guard(0, Lab),

    walk(W, Lab, O, Dir, Pos, 0, #{}).

find_guard(Idx, Content) ->
    Curr = binary:at(Content, Idx),
    if
        Curr == $^ -> 
            Idx;
        true ->
            find_guard(Idx + 1, Content)
    end.

walk(W, Lab, _, _, Pos, _, Seen)
  when (Pos < 0) or
       (Pos > byte_size(Lab)) or
       (Pos rem W == W - 1) -> 
    map_size(Seen);

walk(W, Lab, Obstacle, Dir, Pos, Vector, Seen) -> 
    Curr = binary:at(Lab, Pos),
    if
        Curr == Obstacle -> 
            walk(W, Lab, Obstacle, Dir, Pos-lists:nth((Vector rem 4) + 1, Dir), (Vector + 1) rem 4, Seen);
        is_map_key(Pos, Seen) ->
            walk(W, Lab, Obstacle, Dir, Pos+lists:nth((Vector rem 4) + 1, Dir), Vector, Seen);
        true ->
            walk(W, Lab, Obstacle, Dir, Pos+lists:nth((Vector rem 4) + 1, Dir), Vector, Seen#{ Pos => true })
    end.
