%dw 2.0

output application/json
---
dw::util::Timer::duration(() -> do {
    var positions = (payload splitBy ",") map ($ as Number)
    var median = (positions orderBy $)[sizeOf(positions) / 2]
    ---
    positions reduce (p, acc = 0) -> acc + abs(median - p)
})
