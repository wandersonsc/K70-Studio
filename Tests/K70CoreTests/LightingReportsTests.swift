import XCTest
@testable import K70Core

final class LightingReportsTests: XCTestCase {
    func testReportsMatchTheNXPWireFormat() {
        let values = [0: RGB(1, 2, 3), 59: RGB(4, 5, 6), 60: RGB(7, 8, 9),
                      120: RGB(10, 11, 12), 167: RGB(13, 14, 15), 168: RGB(255, 255, 255)]
        let reports = LightingReports.encode(frame: values)
        XCTAssertEqual(reports.count, 12)
        guard reports.count == 12 else { return }
        XCTAssertTrue(reports.allSatisfy { $0.count == 64 })
        for channel in 0..<3 {
            let offset = 4 * channel
            let delta = UInt8(channel)
            XCTAssertEqual(Array(reports[offset].prefix(5)), [0x7F, 1, 60, 0, 1 + delta])
            XCTAssertEqual(reports[offset].last, 4 + delta)
            XCTAssertEqual(Array(reports[offset + 1].prefix(5)), [0x7F, 2, 60, 0, 7 + delta])
            XCTAssertEqual(Array(reports[offset + 2].prefix(5)), [0x7F, 3, 48, 0, 10 + delta])
            XCTAssertEqual(reports[offset + 2][51], 13 + delta)
            XCTAssertTrue(reports[offset + 2][52...].allSatisfy { $0 == 0 })
            let finish: UInt8 = channel == 2 ? 2 : 1
            XCTAssertEqual(Array(reports[offset + 3].prefix(5)), [0x07, 0x28, 1 + delta, 3, finish])
        }
    }

    func testModeReportsArePaddedAndDoNotAddressOnboardStorage() {
        let activate = LightingReports.activate
        let restore = LightingReports.restore
        XCTAssertEqual(activate.count, 8)
        guard activate.count == 8 else { return }
        XCTAssertTrue(activate.allSatisfy { $0.count == 64 })
        XCTAssertEqual(Array(activate[0].prefix(3)), [0x07, 0x04, 0x02])
        XCTAssertEqual(Array(activate[7].prefix(5)), [0x07, 0x05, 0x02, 0x00, 0x03])
        XCTAssertTrue(activate[7].dropFirst(5).allSatisfy { $0 == 0 })
        for (index, packet) in activate[1...6].enumerated() {
            let count = index == 5 ? 2 : 30
            XCTAssertEqual(Array(packet.prefix(4)), [0x07, 0x40, UInt8(count), 0])
            let expected = (0..<count).flatMap { [UInt8(index * 30 + $0), UInt8(0xC0)] }
            XCTAssertEqual(Array(packet.dropFirst(4).prefix(2 * count)), expected)
            XCTAssertTrue(packet.dropFirst(4 + 2 * count).allSatisfy { $0 == 0 })
        }
        XCTAssertEqual(restore.count, 64)
        XCTAssertEqual(Array(restore.prefix(3)), [0x07, 0x04, 0x01])
        XCTAssertTrue(restore.dropFirst(3).allSatisfy { $0 == 0 })
    }
}
