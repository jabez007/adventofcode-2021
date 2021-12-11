%dw 2.0

fun cycle(state: Object, steps: Number, totalFlashed: Number = 0): Object = 
    if (steps == 0) {
            state: state,
            totalFlashed: totalFlashed
    }
    else do {
        var newState = step(state)
        ---
        cycle(newState, steps - 1, totalFlashed + sizeOf(newState filterObject $ == 0))
    }

fun flash(state: Object): Object = do {
    var ready = state filterObject $ > 9
    ---
    if (sizeOf(ready) > 0)
        flash (
            namesOf(ready) reduce (rc, acc = state) -> do {
                var coords = rc match /(\d+),(\d+)/
                var rIndex = coords[1]
                var cIndex = coords[2]
                ---
                acc update {
                    case ."$(rIndex - 1),$(cIndex - 1)" if ($ > 0) -> $ + 1
                    case ."$(rIndex - 1),$(cIndex)" if ($ > 0) -> $ + 1
                    case ."$(rIndex - 1),$(cIndex + 1)" if ($ > 0) -> $ + 1
                    case ."$(rIndex),$(cIndex - 1)" if ($ > 0) -> $ + 1
                    case ."$(rc)" -> 0
                    case ."$(rIndex),$(cIndex + 1)" if ($ > 0) -> $ + 1
                    case ."$(rIndex + 1),$(cIndex - 1)" if ($ > 0) -> $ + 1
                    case ."$(rIndex + 1),$(cIndex)" if ($ > 0) -> $ + 1
                    case ."$(rIndex + 1),$(cIndex + 1)" if ($ > 0) -> $ + 1
                }
            }
        )
    else
        state
}

fun step(state: Object): Object = 
    flash(state mapObject { ($$): $ + 1 })

output application/json
---
dw::util::Timer::duration(() -> do {
    var energies = (
        ((payload splitBy "\n") map ($ splitBy "")) flatMap (row, rIndex) ->
            row map (item, cIndex) -> {
                "$(rIndex),$(cIndex)": item as Number
            }
    ) reduce (e, acc = {}) -> acc ++ e
    ---
    cycle(energies, 100).totalFlashed
})
