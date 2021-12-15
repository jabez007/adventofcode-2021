%dw 2.0

fun findPaths(
    riskMap: Array<String>,
    queue: Array<Array<Number>> = [[0,0]],
    visited: Object<String, Boolean> = {},
    riskPaths: Object<String, Array<Number>> = {}
): Object<String, Array<Number>> =
    if (isEmpty(queue))
        riskPaths
    else do {
        var current = queue[0]
        var currentKey = "$(current[0]),$(current[1])"
        var neighbors = [
            [current[0], current[1] - 1],
            [current[0], current[1] + 1],
            [current[0] - 1, current[1]],
            [current[0] + 1, current[1]]
        ] filter (
            isEmpty(visited["$($[0]),$($[1])"])
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
        var newRiskPaths = neighbors reduce (n, acc = riskPaths) -> 
            acc update {
                case ."$(n[0]),$(n[1])"! -> (riskPaths[currentKey] default []) ++ [ riskMap[n[0]][n[1]] as Number ]
            }
        ---
        findPaths(
            riskMap,
            ((queue dw::core::Arrays::drop 1) ++ neighbors) distinctBy $,
            visited update {
                case ."$(currentKey)"! -> true
            },
            newRiskPaths)
    }

output application/json
---
dw::util::Timer::duration(() -> do {
    var riskLevels = payload splitBy "\n"
    ---
    sum(
        findPaths(riskLevels)["$(sizeOf(riskLevels) - 1),$(sizeOf(riskLevels[sizeOf(riskLevels) - 1]) - 1)"]
    )
})
