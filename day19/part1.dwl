%dw 2.0

fun vectorDiff(u: Array<Number>, v: Array<Number>): Array<Number> =
    u map ($ - v[$$])

fun vectorDiff(u: Array<String>, v: Array<String>): Array<String> =
    vectorDiff(u map $ as Number, v map $ as Number) map $ as String

fun vectorDiff(u: String, v: String): String =
    vectorDiff(u splitBy ",", v splitBy ",") joinBy ","

output application/json
---
dw::util::Timer::duration(() -> do {
    var scanners = (
        (payload splitBy /--- scanner (\d+) ---/) filter (not isEmpty($))
     ) map (trim($) splitBy "\n")
    ---
    scanners
})
