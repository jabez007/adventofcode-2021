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

fun reduceBitGroups(binary: String, included: String = "" ): String = do {
    var groupPrefix = binary[0]
    var newIncluded = included ++ (binary[1 to 4] default "")
    ---
    if (groupPrefix == "0")
        newIncluded
    else
        reduceBitGroups(
            binary[5 to -1], 
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
            var bits = binary[6 to -1]
            var literalValue = reduceBitGroups(bits)
            var packetSize = (6 + sizeOf(literalValue) + (sizeOf(literalValue) / 4))
            var leftOvers = binary[packetSize to -1]
            ---
            {
                value: fromBinary(literalValue),
                size: packetSize,
                leftOvers: leftOvers
            }
        }
        else do {
            var lengthTypeId = binary[6]
            var operatorPacket =
                if (lengthTypeId == "0") do {
                    var subPacketsLength = fromBinary(binary[7 to 21])
                    var subPackets = decodeSubPacketsByLength(
                        binary[22 to -1],
                        subPacketsLength
                    )
                    ---
                    {
                        subPacketsLength: subPacketsLength,
                        subPackets: subPackets,
                        size: 22 + subPacketsLength,
                        leftOvers: subPackets[-1].leftOvers
                    }
                } else do {
                    var subPacketsCount =  fromBinary(binary[7 to 17])
                    var subPackets = decodeSubPacketsByCount(
                        binary[18 to -1],
                        subPacketsCount
                    )
                    ---
                    {
                        subPacketsCount: subPacketsCount,
                        subPackets: subPackets,
                        size: 18 + sum(subPackets map ($.size as Number)),
                        leftOvers: subPackets[-1].leftOvers
                    }
                } 
            ---
            operatorPacket ++ 
                if (packet.typeId == 0) {
                    value: sum(operatorPacket.subPackets map ($.value as Number))
                } else if (packet.typeId == 1) {
                    value: (operatorPacket.subPackets map ($.value as Number)) reduce (v, acc = 1) -> acc * v
                } else if (packet.typeId == 2) {
                    value: min(operatorPacket.subPackets map ($.value as Number))
                } else if (packet.typeId == 3) {
                    value: max(operatorPacket.subPackets map ($.value as Number))
                } else if (packet.typeId == 5) {
                    value: 
                        if ((operatorPacket.subPackets[0].value) > (operatorPacket.subPackets[1].value))
                            1
                        else
                            0
                } else if (packet.typeId == 6) {
                    value: 
                        if ((operatorPacket.subPackets[0].value) < (operatorPacket.subPackets[1].value))
                            1
                        else
                            0
                } else if (packet.typeId == 7) {
                    value: 
                        if ((operatorPacket.subPackets[0].value) == (operatorPacket.subPackets[1].value))
                            1
                        else
                            0
                } else {
                    value: -1
                }
        }
    )
}

output application/json
---
dw::util::Timer::duration(() -> do {
    var transmissions = (payload splitBy "\n") map (
        dw::core::Strings::leftPad(
            toBinary(fromHex($)), 
            sizeOf($) * 4, 
            "0"
        )
    )
    ---
    transmissions map decodePacket($).value
})
