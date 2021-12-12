%dw 2.0

fun findOut(allPaths: Array<Array<String>>, visited: Array<String>, canRevisit = true): Array<Array<String>> = 
    if (visited[-1] == "end")
        [visited]
    else do {
        var current = visited[-1]
        var next = (allPaths filter ($ contains current)) map ($ -- [current])[0]
        ---
        (next filter (n) -> (
            dw::core::Strings::isUpperCase(n)
            or
            (
                (n != "start")
                and
                (
                    if (visited contains n)
                        canRevisit
                    else
                        true 
                ) 
            )        
        )) flatMap findOut(
            allPaths, 
            visited + $,
            if (canRevisit and dw::core::Strings::isLowerCase($)) (
                not (visited contains $)
            ) else
                canRevisit
        )
    }

output application/json
---
dw::util::Timer::duration(() -> do {
    var paths = (payload splitBy "\n") map ($ splitBy "-")
    ---
    sizeOf(findOut(paths, ["start"]))
})
