%dw 2.0

var open = ["(", "[", "{", "<"]
var close = [")", "]", "}", ">"]
var score = [ 1,   2,   3,   4 ]

fun parse(line: Array<String>, parsed: String = ""): String =
    if (isEmpty(line))
        parsed
    else do {
        var character = line[0]
        ---
        if (open contains character)
            parse(line dw::core::Arrays::drop 1, parsed ++ character)
        else do {
            var closing = open[close dw::core::Arrays::indexOf character]
            ---
            if (parsed[-1] != closing)
                character
            else
                parse(line dw::core::Arrays::drop 1, parsed[0 to -2] default "")
        }
    }

fun parse(line: String): String = 
    parse(line splitBy  "")

output application/json
---
dw::util::Timer::duration(() -> do {
    var lines = payload splitBy "\n"
    var scores = (
        lines map parse($) filter sizeOf($) > 1 map (incomplete) ->
            incomplete[-1 to 0] reduce (char, acc = 0) ->
                (acc * 5) + score[open dw::core::Arrays::indexOf char]
    ) orderBy $
    ---
    scores[sizeOf(scores) / 2]
})
