%dw 2.0

output application/json
---
dw::util::Timer::duration(() -> do {
    var heightmap = (payload splitBy "\n")
    var adjacent = heightmap map (row, rIndex) ->
        (row splitBy "") map (column, cIndex) -> [
            column, 
            [
                if (cIndex == 0) null else row[cIndex - 1],
                row[cIndex + 1],
                if (rIndex == 0) null else heightmap[rIndex - 1][cIndex],
                heightmap[rIndex + 1][cIndex],
            ] filter not isEmpty($)
        ]
    var lows = flatten(adjacent) filter (
        (min($[1]) != $[0])
        and
        (min([$[0], min($[1])]) == $[0])
    )
    var riskLevel = lows map ($[0] + 1)
    ---
    sum(riskLevel)
})
