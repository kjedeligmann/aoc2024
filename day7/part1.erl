-module(part1).
-export([solve/0, count/1, evaluate/3, find/3, fork/2]).

solve() ->
    {_, Content} = file:read_file("./input"),
    Lines = binary:split(Content,<<"\n">>,[trim, global]),
    Tuples = [{Target, Nums} ||
              L <- Lines,
              [ST, SN] <- [binary:split(L, <<":">>, [global])],
              Target <- [binary_to_integer(ST)],
              Nums <- [[binary_to_integer(N) ||
                        N <- binary:split(SN, <<" ">>, [trim, global]),
                        N =/= <<>>
                       ]]
             ],

    Master = spawn(part1, count, [0]),
    fork(Master, Tuples).

fork(Master, []) -> Master ! 0;
fork(Master, [{Target, Nums}|Tail]) ->
    spawn(part1, evaluate, [Master, Target, Nums]),
    fork(Master, Tail).

count(Count) ->
    receive
        Num ->
            count(Count+Num)
    after 10 ->
        io:format("~p~n", [Count])
    end.

evaluate(Master, Target, [First|Other]) ->
    Result = find(Target, First, Other),
    if
        Result > 0 -> Master ! Target;
        true -> Master ! 0
    end.

find(Target, Sofar, _)
  when Sofar > Target -> 0;

find(Target, Sofar, _)
  when Sofar == Target -> 1;

find(_, _, []) -> 0;

find(Target, Sofar, [Next|Other]) ->
    find(Target, Sofar * Next, Other) +
    find(Target, Sofar + Next, Other).
