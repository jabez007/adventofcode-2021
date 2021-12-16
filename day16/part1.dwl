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

fun decodePacket(hex: String): LiteralPacket | OperatorPacket = do {
    var binary = toBinary(fromHex(hex))
    var packet = {
        version: fromBinary(binary[0 to 2]),
        typeId: fromBinary(binary[3 to 5]),
    }
    ---
    packet ++ (
        if (packet.typeId == 4) {
            value: do {
                var bits = binary[6 to (sizeOf(binary) - 1)]
                var bitGroups = bits dw::core::Strings::substringEvery 5
                ---
                fromBinary(
                    bitGroups reduce (b, acc = "") ->
                        acc ++ (b[1 to 4] default "")
                )
            }
        }
        else {
            subPackets: []
        }
    )
}

output application/json
---
dw::util::Timer::duration(() -> do {
    var transmissions = payload splitBy "\n"
    ---
    decodePacket(transmissions[0])
})
