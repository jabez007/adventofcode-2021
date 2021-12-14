%dw 2.0

fun cycle(inputPairs: Object<String, Number>, insertRules: Object<String, String>, steps: Number): Object<String, Number> =
    if (steps == 0)
        inputPairs
    else
        cycle(step(inputPairs, insertRules), insertRules, steps - 1)

fun step(inputPairs: Object<String, Number>, insertRules: Object<String, String>): Object<String, Number> =
    (inputPairs pluck $$) reduce (p, acc = {}) -> do {
        var insert = insertRules[p] default ""
        ---
        if (not isEmpty(insert))
            acc update {
                case ."$(p[0])$(insert)"! -> ($ default 0) + inputPairs[p]
                case ."$(insert)$(p[1])"! -> ($ default 0) + inputPairs[p]
            }
        else
            acc
    }

output application/json
---
dw::util::Timer::duration(() -> do {
    var puzzle = payload splitBy "\n"
    var template = puzzle[0]
    var pairs = (
        (template splitBy "") map (char, index) ->
            if (index < (sizeOf(template) - 1))
                char ++ template[index + 1]
            else
                ""
    ) filter not isEmpty($) groupBy $ mapObject { ($$): sizeOf($) }
    var rules = (puzzle dw::core::Arrays::drop 2) reduce (pi, acc = {}) -> do {
        var pairInsertion = pi splitBy " -> "
        ---
        acc ++ {
            (pairInsertion[0]): pairInsertion[1]
        }
    }
    var result = cycle(pairs, rules, 40)
    var occurences = (result pluck $$ flatMap ($ splitBy "") distinctBy $) reduce (char, acc = {}) -> do {
        var startsWithChar = result filterObject ($$ startsWith char)
        var endsWithChar = result filterObject ($$ endsWith char)
        ---
        acc ++ {
            (char): max([
                sum(startsWithChar pluck ($ as Number)),
                sum(endsWithChar pluck ($ as Number))
            ])
        } as Object
    }
    ---
    max(occurences pluck $) - min(occurences pluck $)
})
