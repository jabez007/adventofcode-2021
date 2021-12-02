%dw 2.0

type Course = {
    x: Number,
    y: Number
}

fun courseWithAim(course: Array<Course>, aim: Number = 0): Course = 
    course reduce (item, acc = {x: 0, y: 0, aim: 0}) ->
        acc update {
            case .x -> $ + item.x
            case .y -> $ + (item.x * (acc.aim + item.y))
            case .aim -> $ + item.y
        }

var course = courseWithAim(
    (payload splitBy "\n") map (item) -> do {
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
)

output application/json
---
course.x * course.y
