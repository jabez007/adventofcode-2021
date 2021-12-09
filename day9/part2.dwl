%dw 2.0

fun basin(heightmap: Array<String>, rIndex: Number, cIndex: Number): Array<Array<Number>> = do {
    var row = heightmap[rIndex]
    var item = row[cIndex]
    var adjacent = [
        if (cIndex == 0) -1 else row[cIndex - 1],
        row[cIndex + 1] default -1,
        if (rIndex == 0) -1 else heightmap[rIndex - 1][cIndex],
        heightmap[rIndex + 1][cIndex] default -1,
    ]
    ---
    (
        (if (item < 9) [[rIndex, cIndex]] else []) 
        ++
        (if (adjacent[0] > item) basin(heightmap, rIndex, cIndex - 1) else [])
        ++
        (if (adjacent[1] > item) basin(heightmap, rIndex, cIndex + 1) else [])
        ++
        (if (adjacent[2] > item) basin(heightmap, rIndex - 1, cIndex) else [])
        ++
        (if (adjacent[3] > item) basin(heightmap, rIndex + 1, cIndex) else [])
    ) distinctBy "$($[0]),$($[1])"
}


output application/json
---
dw::util::Timer::duration(() -> do {
    var heightmap = (payload splitBy "\n")
    var adjacent = heightmap map (row, rIndex) ->
        (row splitBy "") map (item, cIndex) -> [
            item,
            [
                if (cIndex == 0) null else row[cIndex - 1],
                row[cIndex + 1],
                if (rIndex == 0) null else heightmap[rIndex - 1][cIndex],
                heightmap[rIndex + 1][cIndex],
            ] filter not isEmpty($)
        ]
    var lows = flatten(
        adjacent map (row, rIndex) ->
            row map (item, cIndex) -> do {
                var isLowPoint = (
                    (min(item[1]) != item[0])
                    and
                    (min([item[0], min(item[1])]) == item[0])
                )
                ---
                if (isLowPoint) [rIndex, cIndex] else []
            }
    ) filter not isEmpty($)
    var basins = lows map basin(heightmap, $[0], $[1])
    var basinSizes = basins map sizeOf($) orderBy -$
    ---
    basinSizes[0] * basinSizes[1] * basinSizes[2]
})
