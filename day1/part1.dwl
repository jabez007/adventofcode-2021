%dw 2.0

var measurements = (payload splitBy "\n") map $ as Number

output application/json
---
sum(
    dw::core::Arrays::drop(measurements, 1) map (item, index) ->
        if (item > measurements[index])
            1
        else
            0
)
