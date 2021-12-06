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
    if (days == 0)
        state
    else do {
        var newState = log(
            "$(days)", 
            state update {
                case ."0"! -> state."1" default 0
                case ."1"! -> state."2" default 0
                case ."2"! -> state."3" default 0
                case ."3"! -> state."4" default 0
                case ."4"! -> state."5" default 0
                case ."5"! -> state."6" default 0
                case ."6"! -> (state."0" default 0) + (state."7" default 0)
                case ."7"! -> state."8" default 0
                case ."8"! -> state."0" default 0
            }
        )
        ---
        lanternfishModel(newState, days - 1)
    }

fun lanternfishModel(state: Array<Number>, days: Number): Population = do {
    var populationState = (state groupBy $) mapObject {
        ($$): sizeOf($)
    }
    ---
    lanternfishModel(populationState, days)
}

var init = (payload splitBy ",") map ($ as Number)

var population = dw::util::Timer::duration(() -> lanternfishModel(init, 80))

output application/json
---
{
    time: population.time,
    result: sum(population.result pluck $)
}
