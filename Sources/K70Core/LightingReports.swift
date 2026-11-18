public enum LightingReports {
    public static let vendorID = 0x1B1C
    public static let productID = 0x1B55
    public static let usagePage = 0xFFC2
    public static let reportLength = 64
    public static let channelLength = 168

    public static let begin = report(header: [0x07, 0x05, 0x02, 0x00, 0x03])
    public static let restore = report(header: [0x07, 0x04, 0x01])

    public static func encode(frame: [Int: RGB]) -> [[UInt8]] {
        let colors = (0..<channelLength).map { frame[$0] ?? .black }
        let channels = [colors.map(\.red), colors.map(\.green), colors.map(\.blue)]
        var reports: [[UInt8]] = []
        reports.reserveCapacity(12)

        for (channelIndex, channel) in channels.enumerated() {
            for (packetIndex, offset) in stride(from: 0, to: channelLength, by: 60).enumerated() {
                let payload = channel[offset..<min(offset + 60, channelLength)]
                reports.append(report(header: [0x7F, UInt8(packetIndex + 1), UInt8(payload.count), 0],
                                      payload: payload))
            }
            let finish: UInt8 = channelIndex == 2 ? 2 : 1
            reports.append(report(header: [0x07, 0x28, UInt8(channelIndex + 1), 0x03, finish]))
        }
        return reports
    }

    private static func report(header: [UInt8], payload: ArraySlice<UInt8> = []) -> [UInt8] {
        let padding = reportLength - header.count - payload.count
        return header + payload + Array(repeating: 0, count: padding)
    }
}
