%dw 2.0

var measurements = (payload splitBy "\n") map $ as Number
var sums = measurements map sum(dw::core::Arrays::slice(measurements, $$, $$ + 3))

output application/json
---
sum(
    dw::core::Arrays::drop(sums, 1) map (item, index) ->
        if (item > sums[index])
            1
        else
            0
)
