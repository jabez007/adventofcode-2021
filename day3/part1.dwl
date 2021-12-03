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
        acc ++ ((pluckBitCount(item) maxBy $.count).bit as String)

fun epsilon(report: Array<String>): String =
    bitCount(report) reduce (item, acc = "") -> 
        acc ++ ((pluckBitCount(item) minBy $.count).bit as String)

var report = (payload splitBy "\n")

output application/json
---
dw::core::Numbers::fromBinary(gamma(report)) * dw::core::Numbers::fromBinary(epsilon(report))
