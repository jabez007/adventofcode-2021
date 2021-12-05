%dw 2.0

fun gcd(a: Number, b: Number): Number = 
    if (b == 0)
        a
    else
        gcd(b, a mod b)

fun generateLine(x1: Number, y1: Number, x2: Number, y2: Number): Array<String> = do {
    var xFactor = if (x1 == x2) 0 else ((x2 - x1) / abs(x2 - x1))
    var yFactor = if (y1 == y2) 0 else ((y2 - y1) / abs(y2 - y1))
    var length = gcd(abs(x2 - x1), abs(y2 - y1)) + 1
    var points = ("." dw::core::Strings::repeat length) splitBy ""
    ---
    points map "$(x1 + (xFactor * $$)),$(y1 + (yFactor * $$))"
}

var points = (payload splitBy "\n") map (
    (($ match /(\d+),(\d+) -> (\d+),(\d+)/) dw::core::Arrays::drop 1)
) reduce (item, acc = []) -> do {
    var x1 = item[0] as Number
    var y1 = item[1] as Number
    var x2 = item[2] as Number
    var y2 = item[3] as Number
    ---
    acc ++ 
        if (x1 == x2 or y1 == y2) // Consider only horizontal and vertical lines
            generateLine(x1, y1, x2, y2)
        else
            []
}

output application/json
---
sizeOf(points groupBy $ filterObject sizeOf($) > 1)
