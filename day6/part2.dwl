%dw 2.0

type Population = {
    "0"?: Number,
    "1"?: Number,
    "2"?: Number,
    "3"?: Number,
    "4"?: Number,
    "5"?: Number,
    "6"?: Number,
    "7"?: Number,
    "8"?: Number,
}

fun lanternfishModel(state: Population, days: Number): Population =
    (("." dw::core::Strings::repeat days) splitBy "") 
        reduce (item, acc = state) ->
            log(
                "$(days)", 
                {
                    "0": acc."1" default 0,
                    "1": acc."2" default 0,
                    "2": acc."3" default 0,
                    "3": acc."4" default 0,
                    "4": acc."5" default 0,
                    "5": acc."6" default 0,
                    "6": (acc."0" default 0) + (acc."7" default 0),
                    "7": acc."8" default 0,
                    "8": acc."0" default 0,
                }
            )

fun lanternfishModel(state: Array<String>, days: Number): Population = do {
    var populationState = (state groupBy $) mapObject {
        ($$): sizeOf($)
    }
    ---
    lanternfishModel(populationState, days)
}

var init = payload splitBy ","

var population = dw::util::Timer::duration(() -> lanternfishModel(init, 256))

output application/json
---
{
    time: population.time,
    result: sum(population.result pluck $)
}
