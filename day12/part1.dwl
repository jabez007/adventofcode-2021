%dw 2.0

fun findOut(allPaths: Array<Array<String>>, visited: Array<String>): Array<Array<String>> = 
    if (visited[-1] == "end")
        log("visited", [visited])
    else do {
        var current = visited[-1]
        var next = (allPaths filter ($ contains current)) map ($ -- [current])[0]
        ---
        (next filter (n) -> (
            dw::core::Strings::isUpperCase(n)
            or
            not (visited contains n)
        )) flatMap findOut(allPaths, visited + $)
    }

output application/json
---
dw::util::Timer::duration(() -> do {
    var paths = (payload splitBy "\n") map ($ splitBy "-")
    ---
    sizeOf(findOut(paths, ["start"]))
})
