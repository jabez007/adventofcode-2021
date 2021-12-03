%dw 2.0

type ReportCount = {
    "0": Number,
    "1": Number 
}

fun bitCount(report: Array<String>): Array<ReportCount> = 
    report reduce (item, acc = []) -> 
        (item splitBy "") map (bit, index) -> {
            "0": (acc[index][0] default 0) + 
                if (bit == "0")
                    1
                else
                    0,
            "1": (acc[index][1] default 0)  + 
                if (bit == "1")
                    1
                else
                    0,
        }

type BitCount = {
    bit: String,
    count: Number
}

fun pluckBitCount(reportCount: ReportCount): Array<BitCount> =
    reportCount pluck (value, key) -> { 
        bit: key as String,
        count: value 
    }

fun gamma(report: Array<String>): String =
    bitCount(report) reduce (item, acc = "") -> 
        acc ++ 
            if (item[0] == item[1])
                "1"
            else
                ((pluckBitCount(item) maxBy $.count).bit as String)

fun oxygenGenerator(report: Array<String>, gamma_: String, bit: Number = 0): String =
    if (sizeOf(report) == 1)
        report[0]
    else do {
        var newReport = report filter $[bit] == gamma_[bit]
        ---
        oxygenGenerator(newReport, gamma(newReport), bit + 1)
    }

fun oxygenGenerator(report: Array<String>): String =
    oxygenGenerator(report, gamma(report))

fun epsilon(report: Array<String>): String =
    bitCount(report) reduce (item, acc = "") -> 
        acc ++ 
            if (item[0] == item[1])
                "0"
            else
                ((pluckBitCount(item) minBy $.count).bit as String)

fun co2Scrubber(report: Array<String>, epsilon_: String, bit: Number = 0): String =
    if (sizeOf(report) == 1)
        report[0]
    else do {
        var newReport = report filter $[bit] == epsilon_[bit]
        ---
        co2Scrubber(newReport, epsilon(newReport), bit + 1)
    }

fun co2Scrubber(report: Array<String>): String =
    co2Scrubber(report, epsilon(report))

var report = (payload splitBy "\n")

output application/json
---
dw::core::Numbers::fromBinary(oxygenGenerator(report)) 
*
dw::core::Numbers::fromBinary(co2Scrubber(report))
