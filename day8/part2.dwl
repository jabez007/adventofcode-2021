%dw 2.0

fun splits(entry: String): Array<Array<String>> = 
    (entry splitBy " ") map (($ splitBy "") orderBy $)

type Grouped = {
    "2": Array<Array<String>>,
    "3": Array<Array<String>>,
    "4": Array<Array<String>>,
    "5": Array<Array<String>>,
    "6": Array<Array<String>>,
    "7": Array<Array<String>>,
}

type Decoded = {
    "0": String,
    "1": String,
    "2": String,
    "3": String,
    "4": String,
    "5": String,
    "6": String,
    "7": String,
    "8": String,
    "9": String,
}

fun decode(signal: Grouped): Decoded = {
    "0": (signal["6"] filter ( // if the difference from 8 is a segment used in 4 but not in 1, that must be 0
        (signal["4"][0] contains ((signal["7"][0] -- $)[0]))
        and
        not (signal["2"][0] contains ((signal["7"][0] -- $)[0]))
    ))[0] joinBy "",
    "1": signal["2"][0] joinBy "",
    "2": (signal["5"] filter ( // if the entire difference from 8 are segments used in 4, that must be 2
       (signal["7"][0] -- $) dw::core::Arrays::every (d) -> signal["4"][0] contains d
    ))[0] joinBy "",
    "3": (signal["5"] filter ( // if some of the difference from 8 are segments used in 4 but not in 1, that must be 3
        (sizeOf(((signal["7"][0] -- $) -- signal["4"][0])) == 1)
        and
        (sizeOf(((signal["7"][0] -- $) -- signal["2"][0])) == 2)
    ))[0] joinBy "",
    "4": signal["4"][0] joinBy "",
    "5": (signal["5"] filter ( // if some of the difference from 8 are segments used in 4 and 1, that must be 5
        (sizeOf(((signal["7"][0] -- $) -- signal["4"][0])) == 1)
        and
        (sizeOf(((signal["7"][0] -- $) -- signal["2"][0])) == 1)
    ))[0] joinBy "",
    "6": (signal["6"] filter ( // if the difference from 8 is a segment used in 1, that must be 6
        signal["2"][0] contains ((signal["7"][0] -- $)[0])
    ))[0] joinBy "",
    "7": signal["3"][0] joinBy "",
    "8": signal["7"][0] joinBy "",
    "9": (signal["6"] filter ( // if the difference from 8 is not a segment used in 4, that must be 9
        not (signal["4"][0] contains ((signal["7"][0] -- $)[0]))
    ))[0] joinBy ""
}

output application/json
---
dw::util::Timer::duration(() -> do {
    var entries = (payload splitBy "\n") map ($ splitBy " | ")
    var signals = entries map ($[0]) map splits($) map ($ groupBy sizeOf($))
    var decodedSignals = signals map decode($)
    var outputValues = entries map ($[1]) map splits($) map ($ map ($ joinBy ""))
    ---
    sum(outputValues map (o, index) -> do {
        var decoder = decodedSignals[index] mapObject { ($): $$ }
        ---
        ((o map decoder[$]) joinBy "") as Number
    })
})
