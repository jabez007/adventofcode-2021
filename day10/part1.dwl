%dw 2.0

var open = ["(", "[", "{", "<"]
var close = [")", "]", "}", ">"]
var score = [ 3,   57, 1197, 25137 ]

fun parse(line: Array<String>, parsed: String = ""): String =
    if (isEmpty(line))
        ""
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
    ---
    sum(lines map parse($) filter not isEmpty($) map score[close dw::core::Arrays::indexOf $])
})
