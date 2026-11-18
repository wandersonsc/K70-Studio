import Foundation

public struct RGB: Equatable, Codable, Sendable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8

    public static let black = RGB(0, 0, 0)

    public init(_ red: UInt8, _ green: UInt8, _ blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public init?(hex: String) {
        let text = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let digits = text.hasPrefix("#") ? String(text.dropFirst()) : text
        guard digits.utf8.count == 6, digits.utf8.allSatisfy({ byte in
            (48...57).contains(byte) || (65...70).contains(byte) || (97...102).contains(byte)
        }), let value = UInt32(digits, radix: 16) else { return nil }
        self.init(UInt8(value >> 16), UInt8(truncatingIfNeeded: value >> 8), UInt8(truncatingIfNeeded: value))
    }

    public var hex: String { String(format: "#%02X%02X%02X", Int(red), Int(green), Int(blue)) }

    public func scaled(by fraction: Double) -> RGB {
        let amount = fraction.isFinite ? min(max(fraction, 0), 1) : 0
        return RGB(
            UInt8((Double(red) * amount).rounded()),
            UInt8((Double(green) * amount).rounded()),
            UInt8((Double(blue) * amount).rounded())
        )
    }

    static func rainbow(hue: Double) -> RGB {
        let turns = hue - floor(hue)
        func channel(_ offset: Double) -> UInt8 {
            let sector = (6 * turns + offset).truncatingRemainder(dividingBy: 6)
            let intensity = 1 - max(0, min(sector, 4 - sector, 1))
            return UInt8((35 + intensity * 220).rounded())
        }
        return RGB(channel(5), channel(3), channel(1))
    }
}

public enum LightingEffect: String, CaseIterable, Codable, Sendable {
    case solid = "Solid"
    case perKey = "Per-key"
    case breathing = "Breathe"
    case rainbow = "Rainbow"
    case off = "Off"

    public var isAnimated: Bool { self == .breathing || self == .rainbow }
    public var usesBaseColor: Bool { self != .rainbow && self != .off }
}

public struct LightingSettings: Equatable, Codable, Sendable {
    public var effect: LightingEffect
    public var baseColor: RGB
    public var brightness: Double
    public var period: Double
    public var overrides: [Int: RGB]

    public init(
        effect: LightingEffect = .solid, baseColor: RGB = RGB(123, 225, 195),
        brightness: Double = 0.8, period: Double = 5, overrides: [Int: RGB] = [:]
    ) {
        self.effect = effect
        self.baseColor = baseColor
        self.brightness = brightness
        self.period = period
        self.overrides = overrides
    }

    public func color(for key: KeyLight, elapsed: TimeInterval = 0) -> RGB {
        let phase = (elapsed.isFinite ? elapsed : 0) / (period.isFinite ? max(1, period) : 5)
        switch effect {
        case .solid:
            return baseColor.scaled(by: brightness)
        case .perKey:
            return (overrides[key.id] ?? baseColor).scaled(by: brightness)
        case .breathing:
            return baseColor.scaled(by: brightness * (0.12 + 0.88 * (0.5 + 0.5 * cos(2 * .pi * phase))))
        case .rainbow:
            return RGB.rainbow(hue: key.x / KeyboardLayout.width - phase).scaled(by: brightness)
        case .off:
            return .black
        }
    }

    public func frame(elapsed: TimeInterval = 0) -> [Int: RGB] {
        Dictionary(uniqueKeysWithValues: KeyboardLayout.brazilian.map { ($0.id, color(for: $0, elapsed: elapsed)) })
    }
}

public struct LightingProfile: Codable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let settings: LightingSettings

    public init(name: String, settings: LightingSettings) {
        id = UUID()
        self.name = name
        self.settings = settings
    }
}
