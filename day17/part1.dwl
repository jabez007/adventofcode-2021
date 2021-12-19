%dw 2.0

output application/json
---
dw::util::Timer::duration(() -> do {
    var target = payload match /target area: x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)/
    var xRange = [target[1] as Number, target[2] as Number]
    var yRange = [target[3] as Number, target[4] as Number]
    ---
    /*
     * from launch (y = 0) to maximum height and back down to y = 0
     * is going to be symmetrical, we are always going to touch 0 exactly.
     * So, we need the exact velocity to get from y = 0 to 
     * the bottom of our target area in one step
     * subtract 1, and we will have our starting velocity
     * then it's just the sum from 1 to that starting velocity 
     * to get our maximum height 
     */
    (abs(min(yRange) default 0) * (abs(min(yRange) default 0) - 1)) / 2
})
