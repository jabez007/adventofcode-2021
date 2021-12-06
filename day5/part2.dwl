%dw 2.0
// https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
// https://www.geeksforgeeks.org/program-for-point-of-intersection-of-two-lines/

type Point = {
    x: Number,
    y: Number
}

fun orientation(p: Point, q: Point, r: Point): Number = do {
    var val = ((q.y - p.y) * (r.x - q.x)) - ((q.x - p.x) * (r.y - q.y))
    ---
    if (val == 0)
        0 // collinear
    else if (val > 0)
        1 // clockwise
    else 
        2 // counterclockwise
}

fun findIntersection(A: Point, B: Point, C: Point, D: Point): Point|Null = do {
    var a1 = B.y - A.y
    var b1 = A.x - B.x
    var c1 = (a1 * A.x) + (b1 * A.y)

    var a2 = D.y - C.y
    var b2 = C.x - D.x
    var c2 = (a2 * C.x) + (b2 * C.y)

    var determinant = (a1 * b2) - (a2 * b1)
    ---
    if (determinant == 0) 
        null
    else do {
        var x = (b2 * c1 - b1 * c2) / determinant
        var y = (a1 * c2 - a2 * c1) / determinant
        ---
        if (isInteger(x) and isInteger(y)) { // lines can only cross on integers
            x: x,
            y: y
        } else null
    }
}

fun onSegment(p: Point, q: Point, r: Point): Boolean =
    if (q.x <= max([p.x, r.x]) and q.x >= min([p.x, r.x]) and
        q.y <= max([p.y, r.y]) and q.y >= min([p.y, r.y]))
        true
    else
        false

fun gcd(a: Number, b: Number): Number = 
    if (b == 0)
        a
    else
        gcd(b, a mod b)

fun generateSegment(q: Point, r: Point): Array<Point> = do {
    var xFactor = if (q.x == r.x) 0 else ((r.x - q.x) / abs(r.x - q.x))
    var yFactor = if (q.y == r.y) 0 else ((r.y - q.y) / abs(r.y - q.y))
    var length = gcd(abs(r.x - q.x), abs(r.y - q.y)) + 1 // https://www.geeksforgeeks.org/number-integral-points-two-points/
    var points = ("." dw::core::Strings::repeat length) splitBy ""
    ---
    points map {
        x: q.x + (xFactor * $$),
        y: q.y + (yFactor * $$)
    }
}

fun findOverlap(p1: Point, q1: Point, p2: Point, q2: Point): Array<Point> =
    generateSegment(p1,
        {
            x: (
                if (q1.x == p1.x)
                    q1.x
                else if (q1.x < p1.x)
                    max([q1.x, min([p2.x, q2.x])])
                else
                    min([q1.x, max([p2.x, q2.x])])
            ) default 0,
            y: (
                if (q1.y == p1.y)
                    q1.y
                else if (q1.y < p1.y)
                    max([q1.y, min([p2.y, q2.y])])
                else
                    min([q1.y, max([p2.y, q2.y])])
            ) default 0
        }
    )

fun doIntersect(p1: Point, q1: Point, p2: Point, q2: Point): Array<Point> = do {
    var o1 = orientation(p1, q1, p2)
    var o2 = orientation(p1, q1, q2)
    var o3 = orientation(p2, q2, p1)
    var o4 = orientation(p2, q2, q1)
    ---
    if (o1 != o2 and o3 != o4)
        [findIntersection(p1, q1, p2, q2)] filter $ != null
    else if (o1 == 0 and onSegment(p1, p2, q1))
        findOverlap(p2, q2, p1, q1)
    else if (o2 == 0 and onSegment(p1, q2, q1))
        findOverlap(q2, p2, p1, q1)
    else if (o3 == 0 and onSegment(p2, p1, q2))
        findOverlap(p1, q1, p2, q2)
    else if (o4 == 0 and onSegment(p2, q1, q2))
        findOverlap(q1, p1, p2, q2)
    else
        []
}

var vectors: Array<Array<Point>> = (payload splitBy "\n") map (
    (($ match /(\d+),(\d+) -> (\d+),(\d+)/) dw::core::Arrays::drop 1)
) map (item) -> do {
    var x1 = item[0] as Number
    var y1 = item[1] as Number
    var x2 = item[2] as Number
    var y2 = item[3] as Number
    ---
    [
        {
            x: x1,
            y: y1
        }, 
        {
            x: x2,
            y: y2
        }
    ]
}

var intersections = dw::util::Timer::duration(() -> 
    vectors reduce (v, acc = {}) -> do {
        var newDrop = (acc.drop default 0) + 1
        var remainingVectors = vectors dw::core::Arrays::drop newDrop
        var newIntersections = remainingVectors reduce (rv, xing = {}) -> (
            xing ++ (doIntersect(v[0], v[1], rv[0], rv[1]) reduce (p, xing_ = {}) -> 
                xing_ dw::core::Objects::mergeWith {
                    "$(p.x),$(p.y)": 1
                }
            )
        )
        ---
        acc update {
            case .drop! -> newDrop
            case .intersections! -> ($ default {}) dw::core::Objects::mergeWith newIntersections
        }
    }
)
//var time = log("intersections", "$(intersections.time)ms")

output application/json
---
{
    time: intersections.time,
    result: sizeOf(intersections.result.intersections default {})
}
