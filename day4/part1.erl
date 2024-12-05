-module(part1).
-export([solve/0]).

solve() ->
    {_, Content} = file:read_file("./input"),
    iterate(0, 0, Content).

iterate(Sum, Idx, Binary) when Idx == byte_size(Binary) ->
    Sum;
iterate(Sum, Idx, Binary) ->
    Curr = binary:at(Binary, Idx),

    if
        Curr == $X ->
            NewSum = Sum + expand(Idx, Binary),
            iterate(NewSum, Idx + 1, Binary);
        true ->
            iterate(Sum, Idx + 1, Binary)
    end.

expand(Idx, Binary) ->
    Width = 141,

    Ends = [Idx - 3 * Width - 3, Idx - 3 * Width, Idx - 3 * Width + 3,
            Idx - 3, Idx + 3,
            Idx + 3 * Width - 3, Idx + 3 * Width, Idx + 3 * Width + 3],
    Ss = [I || I <- Ends,
               I >= 0,
               I < byte_size(Binary),
               (I div Width == Idx div Width) or (I div Width == Idx div Width - 3) or (I div Width == Idx div Width + 3),
               binary:at(Binary, I) == $S
         ],

    Closer = bring_closer(Idx, Ss, []),
    As = [I || I <- Closer, binary:at(Binary, I) == $A],

    CloserCloser = bring_closer(Idx, As, []),
    Ms = [I || I <- CloserCloser, binary:at(Binary, I) == $M],

    length(Ms).

bring_closer(X, [Idx|T], Result) ->
    Width = 141,

    if
        Idx div Width > X div Width ->
            Idx1 = Idx - Width;
        Idx div Width < X div Width ->
            Idx1 = Idx + Width;
        true ->
            Idx1 = Idx
    end,

    if
        Idx rem Width > X rem Width -> Idx2 = Idx1 - 1;
        Idx rem Width < X rem Width -> Idx2 = Idx1 + 1;
        true -> Idx2 = Idx1
    end,

    bring_closer(X, T, [Idx2|Result]);
bring_closer(_, [], Result) -> Result.
