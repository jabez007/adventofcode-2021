%dw 2.0

output application/json
---
dw::util::Timer::duration(() -> do {
    var puzzle = (payload splitBy "\n") dw::core::Arrays::splitWhere $ == ""
    var dots = puzzle.l map ($ match /(\d+),(\d+)/) map [$[1] as Number, $[2] as Number]
    var folds = (puzzle.r dw::core::Arrays::drop 1) map (f) -> f match {
        case fold matches /fold along x=(\d+)/ -> [fold[1] as Number, 0]
        case fold matches /fold along y=(\d+)/ -> [0, fold[1] as Number]
        else -> [0, 0]
    }
    ---
    sizeOf(
        [folds[0]] reduce (f, acc = dots) -> (
            acc map (d) ->
                d map (
                    if ((f[$$] > 0) and $ > f[$$])
                        f[$$] - ($ - f[$$])
                    else
                        $
                )
        ) distinctBy "$($[0]),$($[1])"
    )
})
