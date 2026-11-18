import XCTest
@testable import K70Core

final class LightingTests: XCTestCase {
    func testBrazilianLayoutHasUniqueInRangeLEDAddresses() {
        let lights = KeyboardLayout.brazilian
        XCTAssertEqual(lights.count, 116)
        XCTAssertEqual(Set(lights.map(\.id)).count, lights.count)
        XCTAssertTrue(lights.allSatisfy { (0..<LightingReports.channelLength).contains($0.id) })
        XCTAssertEqual(lights.first { $0.id == 0x7B }?.label, "Ç")
        XCTAssertEqual(lights.first { $0.id == 0x8A }?.label, "/")
        XCTAssertEqual(lights.first { $0.id == 0x7E }?.stepped, true)
        XCTAssertTrue(lights.allSatisfy {
            $0.x >= 0 && $0.y >= 0 && $0.x + $0.width <= KeyboardLayout.width + 0.0001 &&
            $0.y + $0.height <= KeyboardLayout.height + 0.0001
        })
    }

    func testHexValidatesExactlySixASCIIDigits() {
        XCTAssertEqual(RGB(hex: "  #7be1c3\n")?.hex, "#7BE1C3")
        XCTAssertEqual(RGB(hex: "00ff00"), RGB(0, 255, 0))
        for invalid in ["", "#fff", "##FFFFF", "#FF0000FF", "+1abcd", "１２３４５６", "#FF 000"] {
            XCTAssertNil(RGB(hex: invalid), invalid)
        }
    }

    func testPerKeyOverrideAndBrightness() throws {
        let key = try XCTUnwrap(KeyboardLayout.brazilian.first { $0.label == "Ç" })
        var settings = LightingSettings(effect: .perKey, baseColor: RGB(0, 0, 240),
                                        brightness: 0.5, overrides: [key.id: RGB(255, 0, 0)])
        XCTAssertEqual(settings.color(for: key), RGB(128, 0, 0))
        XCTAssertEqual(settings.frame()[0], RGB(0, 0, 120))
        settings.effect = .solid
        XCTAssertEqual(settings.color(for: key), RGB(0, 0, 120))
        settings.effect = .off
        XCTAssertTrue(settings.frame().values.allSatisfy { $0 == .black })
    }

    func testAnimatedEffectsFollowTheConfiguredPeriod() throws {
        let key = try XCTUnwrap(KeyboardLayout.brazilian.first)
        let breathing = LightingSettings(effect: .breathing, baseColor: RGB(200, 100, 0),
                                         brightness: 1, period: 4)
        XCTAssertEqual(breathing.color(for: key, elapsed: 0), RGB(200, 100, 0))
        XCTAssertEqual(breathing.color(for: key, elapsed: 2), RGB(24, 12, 0))
        XCTAssertEqual(breathing.frame(elapsed: 0), breathing.frame(elapsed: 4))

        let rainbow = LightingSettings(effect: .rainbow, period: 4)
        XCTAssertNotEqual(rainbow.frame(elapsed: 0), rainbow.frame(elapsed: 1))
        XCTAssertEqual(rainbow.frame(elapsed: 0), rainbow.frame(elapsed: 4))
        XCTAssertGreaterThan(Set(rainbow.frame().values.map(\.hex)).count, 10)
    }

    func testProfilesRoundTripIncludingOverrides() throws {
        let settings = LightingSettings(effect: .perKey, overrides: [0x7B: RGB(0, 255, 0)])
        let profile = LightingProfile(name: "At night", settings: settings)
        let data = try JSONEncoder().encode([profile])
        let saved = try XCTUnwrap(JSONDecoder().decode([LightingProfile].self, from: data).first)
        XCTAssertEqual(saved.id, profile.id)
        XCTAssertEqual(saved.name, "At night")
        XCTAssertEqual(saved.settings, settings)
    }
}
