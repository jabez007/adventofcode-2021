%dw 2.0

fun moveSum(steps: Number): Number = // sum 1..n
    (steps * (steps + 1)) / 2

output application/json
---
dw::util::Timer::duration(() -> do {
    var positions = (payload splitBy ",") map ($ as Number)
    var median = (positions orderBy $)[sizeOf(positions) / 2]
    var mean = sum(positions) / sizeOf(positions)
    var mean_floor = floor(mean)
    var mean_ceil = ceil(mean)
    ---
    min([
        positions reduce (p, acc = 0) -> acc + moveSum(abs(mean_floor - p)),
        positions reduce (p, acc = 0) -> acc + moveSum(abs(mean_ceil - p))
    ])
})
