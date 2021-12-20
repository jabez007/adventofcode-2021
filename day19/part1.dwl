%dw 2.0

fun vectorDiff(u: Array<Number>, v: Array<Number>): Array<Number> =
    u map ($ - v[$$])

fun vectorDiff(u: Array<String>, v: Array<String>): Array<String> =
    vectorDiff(u map $ as Number, v map $ as Number) map $ as String

fun vectorDiff(u: String, v: String): String =
    vectorDiff(u splitBy ",", v splitBy ",") joinBy ","

fun combinations(items: Array<String>, size: Number): Array<Array<String>> =
    /*
     * Suppose you are given nnn items and asked to choose kkk out of them. 
     * To do this, you pick the first item and look at it. 
     * You have two options. 
     * You either pick the item, in which case you have reduced the problem to that of choosing k−1 items from the n−1 items left, 
     * or you can choose not to pick the first item in which the problem is reduced to choosing k from the n−1 items left.
     */
    if (size == 0)
        [[]]
    else if (isEmpty(items))
        []
    else (
        (combinations(items[1 to -1] default [], size - 1) map ([items[0]] ++ $))
        ++
        combinations(items[1 to -1] default [], size)
    )

output application/json
---
dw::util::Timer::duration(() -> do {
    var scanners = (
        (payload splitBy /--- scanner (\d+) ---/) filter (not isEmpty($))
     ) map (trim($) splitBy "\n")
    ---
    scanners
})
