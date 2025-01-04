-module(part2).
-export([solve/0, count/2, fork/3, walk/9]).

solve() ->
    W = 131,
    O = $#,
    Dir = [-W, +1, W, -1],

    {_, Lab} = file:read_file("./input"),
    Pos = find_guard(0, Lab),

    io:format("~p~n", [self()]),
    CountID = spawn(part2, count, [0, #{}]),
    io:format("spawned count~n"),

    List = initial(W, Lab, O, Dir, Pos, 0, #{}),
    io:format("distinct positions ~p~n", [length(List)]),

    spawn(part2, fork, [CountID, List, [W, Lab, O, Dir, Pos, 0, #{}]]),
    io:format("spawned fork~n").

count(Count, Map) ->
    receive
        {Pid, spawn} ->
            count(Count, Map#{Pid => spawned});
        {Pid, 0} ->
            count(Count, Map#{Pid => no_loop});
        {Pid, 1} ->
            count(Count+1, Map#{Pid => loop});
        {done} ->
            io:format("spawned the last one~n"),
            count(Count, Map)
    after 50 ->
        NotTerminated = [Key || {Key, MapValue} <- maps:to_list(Map), MapValue == spawned],
        io:format("non terminated ~p~ntotal number ~p~nloop ~p~n", [length(NotTerminated), map_size(Map), Count]),
        init:stop()
    end.

find_guard(Idx, Content) ->
    Curr = binary:at(Content, Idx),
    if
        Curr == $^ -> 
            Idx;
        true ->
            find_guard(Idx + 1, Content)
    end.

initial(W, Lab, _, _, Pos, _, Seen)
  when (Pos < 0) or
       (Pos > byte_size(Lab)) or
       (Pos rem W == W - 1) -> 
    [K || {K, _} <- maps:to_list(Seen)];

initial(W, Lab, Obstacle, Dir, Pos, Vector, Seen) -> 
    Curr = binary:at(Lab, Pos),
    if
        Curr == Obstacle -> 
            initial(W, Lab, Obstacle, Dir, Pos-lists:nth((Vector rem 4) + 1, Dir), (Vector + 1) rem 4, Seen);
        is_map_key(Pos, Seen) ->
            initial(W, Lab, Obstacle, Dir, Pos+lists:nth((Vector rem 4) + 1, Dir), Vector, Seen);
        true ->
            initial(W, Lab, Obstacle, Dir, Pos+lists:nth((Vector rem 4) + 1, Dir), Vector, Seen#{ Pos => true })
    end.

fork(Master, [], _) ->
    Master ! {done};

fork(Master, List, Args) ->
    [ObsPos|Tail] = List,
    Pid = spawn(part2, walk, [ObsPos, Master|Args]),
    Master ! {Pid, spawn},
    fork(Master, Tail, Args).

walk(_, Master, W, Lab, _, _, Pos, _, _)
  when (Pos < 0) or
       (Pos > byte_size(Lab)) or
       (Pos rem W == W - 1) -> 
    Master ! {self(), 0};

walk(ObstaclePos, Master, W, Lab, Obstacle, Dir, Pos, Vector, Seen) -> 
    Curr = binary:at(Lab, Pos),
    if
        Curr == Obstacle orelse Pos == ObstaclePos -> 
            walk(ObstaclePos, Master, W, Lab, Obstacle, Dir, Pos-lists:nth((Vector rem 4) + 1, Dir), (Vector + 1) rem 4, Seen);
        is_map_key({Pos, Vector}, Seen) ->
            Master ! {self(), 1};
        true ->
            walk(ObstaclePos, Master, W, Lab, Obstacle, Dir, Pos+lists:nth((Vector rem 4) + 1, Dir), Vector, Seen#{ {Pos, Vector} => true })
    end.
