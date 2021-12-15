%dw 2.0

fun findPaths(
    riskMap: Array<String>,
    priorityQueue: Object<String, Number> = { "0,0": 0 },
    visited: Object<String, Boolean> = {},
    riskPaths: Object<String, Array<Number>> = {}
): Object<String, Array<Number>> =
    if (isEmpty(priorityQueue))
        riskPaths
    else do {
        var currentKey = (priorityQueue pluck [$$, $] orderBy $[1])[0][0] as String
        var current = currentKey splitBy "," map ($ as Number)
        ---
        if ((current[0] == (sizeOf(riskMap) - 1)) and (current[1] == (sizeOf(riskMap[current[0]]) - 1)))
            riskPaths
        else do {
            var neighbors = [
                [current[0], current[1] - 1],
                [current[0], current[1] + 1],
                [current[0] - 1, current[1]],
                [current[0] + 1, current[1]]
            ] filter (
                (not (visited["$($[0]),$($[1])"] default false))
                and
                (($[0] >= 0) and ($[0] < sizeOf(riskMap)))
                and
                (($[1] >= 0) and ($[1] < sizeOf(riskMap[$[0]])))
            ) filter (n) -> do {
                var newPath = (riskPaths[currentKey] default []) ++ [ riskMap[n[0]][n[1]] as Number ]
                var nKey = "$(n[0]),$(n[1])"
                var currentPathToNeighbor = riskPaths[nKey]
                ---
                isEmpty(currentPathToNeighbor)
                or
                (sum(newPath) < sum(currentPathToNeighbor))
            } 
            ---
            findPaths(
                riskMap,
                neighbors reduce (n, acc = (priorityQueue -- [currentKey])) ->
                    acc update {
                        case ."$(n[0]),$(n[1])"! -> sum((riskPaths[currentKey] default []) ++ [ riskMap[n[0]][n[1]] as Number ])
                    },
                visited update {
                    case ."$(currentKey)"! -> true
                },
                neighbors reduce (n, acc = riskPaths) -> 
                    acc update {
                        case ."$(n[0]),$(n[1])"! -> (riskPaths[currentKey] default []) ++ [ riskMap[n[0]][n[1]] as Number ]
                    }
            )
        }
    }

output application/json
---
dw::util::Timer::duration(() -> do {
    var riskLevels = payload splitBy "\n"
    ---
    findPaths(riskLevels)["$(sizeOf(riskLevels) - 1),$(sizeOf(riskLevels[sizeOf(riskLevels) - 1]) - 1)"]
})
