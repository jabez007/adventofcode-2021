%dw 2.0

var course = (payload splitBy "\n") map (item) -> do {
    var parts = item splitBy " "
    ---
    {
        x:
            if (parts[0] == "forward")
                parts[1] as Number
            else
                0,
        y:
            if (parts[0] == "down")
                parts[1] as Number
            else if (parts[0] == "up")
                -(parts[1] as Number)
            else
                0
    }
}

output application/json
---
sum(course map $.x) * sum(course map $.y)
