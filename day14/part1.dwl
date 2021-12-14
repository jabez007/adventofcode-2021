%dw 2.0

fun cycle(start: String, insertRules: Object, steps: Number): String =
    if (steps == 0)
        start
    else
        cycle(step(start, insertRules), insertRules, steps - 1)

fun step(temp: String, insertRules: Object): String = do {
    var inputPairs = (
        (temp splitBy "") map (char, index) -> 
            if (index < (sizeOf(temp) - 1))
                char ++ temp[index + 1]
            else
                ""
    )
    ---
    inputPairs reduce (ip, acc = temp[0]) -> acc ++ (
        ((insertRules[ip] default "") as String)
        ++
        (ip[1] default "")
    )
}

output application/json
---
dw::util::Timer::duration(() -> do {
    var puzzle = payload splitBy "\n"
    var template = puzzle[0]
    var rules = (puzzle dw::core::Arrays::drop 2) reduce (pi, acc = {}) -> do {
        var pairInsertion = pi splitBy " -> "
        ---
        acc ++ {
            (pairInsertion[0]): pairInsertion[1]
        }
    }
    var result = cycle(template, rules, 10)
    var occurances = (result splitBy "") groupBy $ mapObject { ($$): sizeOf($) }
    ---
    max(occurances pluck $) - min(occurances pluck $)
})
