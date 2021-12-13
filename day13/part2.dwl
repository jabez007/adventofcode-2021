%dw 2.0

fun plot(dots: Array<Array<Number>>): String = do {
    var xMax = max(dots map $[0]) default 0
    var yMax = max(dots map $[1]) default 0
    ---
    (
        (0 to yMax) map (y) -> (
            (0 to xMax) map (x) -> 
                if (dots contains [x, y])
                    "*"
                else
                    " "
        ) joinBy ""
    ) joinBy "\n"
}

output text/markdown with text
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
    plot(folds reduce (f, acc = dots) -> (
        acc map (d) ->
            d map (
                if ((f[$$] > 0) and $ > f[$$])
                    f[$$] - ($ - f[$$])
                else
                    $
            )
    ) distinctBy "$($[0]),$($[1])")
}).result
