%dw 2.0
import * from dw::core::Numbers

type Packet = {
    version: Number,
    typeId: Number,
}

type LiteralPacket = Packet & {
    value: Number
}

type OperatorPacket = Packet & {
    subPackets: Array<LiteralPacket | OperatorPacket>
}

fun reduceBitGroups(fives: Array<String>, included: String = "" ): String = do {
    var newIncluded = included ++ (fives[0][1 to 4] default "")
    ---
    if (fives[0][0] == "0")
        newIncluded
    else
        reduceBitGroups(
            fives dw::core::Arrays::drop 1, 
            newIncluded
        )
}

fun decodeSubPacketsByLength(
    binary: String, 
    totalBitLength: Number, 
    decoded: Array<LiteralPacket | OperatorPacket> = []
): Array<LiteralPacket | OperatorPacket> =
    if ((fromBinary(binary) == 0) or (sum(decoded map ($.size as Number)) == totalBitLength))
        decoded
    else do {
        var decodedPacket = decodePacket(binary)
        ---
        decodeSubPacketsByLength(
            (decodedPacket.leftOvers default "0") as String,
            totalBitLength,
            decoded + decodedPacket
        )
    }

fun decodeSubPacketsByCount(
    binary: String, 
    subPacketsContained: Number, 
    decoded: Array<LiteralPacket | OperatorPacket> = []
): Array<LiteralPacket | OperatorPacket> =
    if ((fromBinary(binary) == 0) or (sizeOf(decoded) == subPacketsContained))
        decoded
    else do {
        var decodedPacket = decodePacket(binary)
        ---
        decodeSubPacketsByCount(
            (decodedPacket.leftOvers default "0") as String,
            subPacketsContained,
            decoded + decodedPacket
        )
    }

fun decodePacket(binary: String): LiteralPacket | OperatorPacket = do {
    var packet = {
        version: fromBinary(binary[0 to 2]),
        typeId: fromBinary(binary[3 to 5]),
    }
    ---
    packet ++ (
        if (packet.typeId == 4) do {
            var bits = binary[6 to (sizeOf(binary) - 1)]
            var bitGroups = bits dw::core::Strings::substringEvery 5
            var literalValue = reduceBitGroups(bitGroups)
            var leftOvers = binary[
                (6 + sizeOf(literalValue) + (sizeOf(literalValue) / 4)) 
                to 
                (sizeOf(binary) - 1)
            ]
            ---
            {
                value: fromBinary(literalValue),
                size: (6 + sizeOf(literalValue) + (sizeOf(literalValue) / 4)),
                leftOvers: leftOvers
            }
        }
        else do {
            var lengthTypeId = binary[6]
            ---
            if (lengthTypeId == "0") do {
                var subPacketsLength = fromBinary(binary[7 to 21])
                ---
                {
                    subPacketsLength: subPacketsLength,
                    subPackets: decodeSubPacketsByLength(
                        binary[22 to (sizeOf(binary) - 1)],
                        subPacketsLength
                    ),
                    size: 22 + subPacketsLength
                }
            } else do {
                var subPacketsCount =  fromBinary(binary[7 to 17])
                var subPackets = decodeSubPacketsByCount(
                    binary[18 to (sizeOf(binary) - 1)],
                    subPacketsCount
                )
                ---
                {
                    subPacketsCount: subPacketsCount,
                    subPackets: subPackets,
                    size: 18 + sum(subPackets map ($.size as Number))
                }
            }
        }
    )
}

output application/json
---
dw::util::Timer::duration(() -> do {
    var transmissions = (payload splitBy "\n") map log(
        "binary", 
        dw::core::Strings::leftPad(
            toBinary(fromHex($)), 
            ceil(sizeOf(toBinary(fromHex($))) / 4) * 4, 
            "0"
        )
    )
    ---
    decodePacket(transmissions[0])
})
