%dw 2.0

output application/json
---
dw::util::Timer::duration(() -> do {
    var entries = (payload splitBy "\n") map ($ splitBy " | ")
    var outputValues = entries map ($[1])
    ---
    outputValues map ($ splitBy " ") reduce (o, acc = 0) -> 
        acc + (o dw::core::Arrays::countBy ([2, 4, 3, 7] contains sizeOf($)))
})
