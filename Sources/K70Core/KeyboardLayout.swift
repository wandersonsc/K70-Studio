public struct KeyLight: Identifiable, Sendable {
    public let id: Int
    public let label: String
    public let name: String
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
    public let stepped: Bool

    init(
        _ id: Int, _ label: String, x: Double, y: Double, width: Double = 1,
        height: Double = 1, name: String? = nil, stepped: Bool = false
    ) {
        self.id = id
        self.label = label
        self.name = name ?? label
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.stepped = stepped
    }
}

public enum KeyboardLayout {
    public static let width = 22.9
    public static let height = 7.35

    // LED addresses are Corsair matrix indices. The surface matches CH-9109018-BR.
    public static let brazilian: [KeyLight] = makeLayout()

    private static func makeLayout() -> [KeyLight] {
        let top: [KeyLight] = [
            KeyLight(0x7D, "Profile", x: 3.65, y: 0, width: 1.05, height: 0.72, name: "Profile switch"),
            KeyLight(0x89, "☀", x: 4.7, y: 0, width: 0.85, height: 0.72, name: "Brightness button"),
            KeyLight(0x08, "Lock", x: 5.55, y: 0, width: 0.85, height: 0.72, name: "Windows lock"),
            KeyLight(0x2F, "Logo", x: 9.8, y: 0, width: 1.35, height: 0.72, name: "Left logo light"),
            KeyLight(0x3B, "Logo", x: 11.15, y: 0, width: 1.35, height: 0.72, name: "Right logo light"),
            KeyLight(0x14, "Mute", x: 18.9, y: 0, height: 0.72),
            KeyLight(0x00, "Esc", x: 0, y: 1.15, name: "Escape")
        ] + row(1.15, 1.7, [
            (0x0C, "F1"), (0x18, "F2"), (0x24, "F3"), (0x30, "F4")
        ]) + row(1.15, 6.2, [
            (0x3C, "F5"), (0x48, "F6"), (0x54, "F7"), (0x60, "F8")
        ]) + row(1.15, 10.7, [
            (0x6C, "F9"), (0x78, "F10"), (0x84, "F11"), (0x06, "F12")
        ]) + [
            KeyLight(0x12, "PrtSc", x: 15.45, y: 1.15, name: "Print Screen"),
            KeyLight(0x1E, "ScrLk", x: 16.45, y: 1.15, name: "Scroll Lock"),
            KeyLight(0x2A, "Pause", x: 17.45, y: 1.15),
            KeyLight(0x20, "■", x: 18.9, y: 1.15, height: 0.8, name: "Stop"),
            KeyLight(0x2C, "⏮", x: 19.9, y: 1.15, height: 0.8, name: "Previous track"),
            KeyLight(0x38, "⏯", x: 20.9, y: 1.15, height: 0.8, name: "Play or pause"),
            KeyLight(0x44, "⏭", x: 21.9, y: 1.15, height: 0.8, name: "Next track")
        ]
        let numberRow = row(2.35, 0, [
            (0x01, "'"), (0x0D, "1"), (0x19, "2"), (0x25, "3"), (0x31, "4"), (0x3D, "5"),
            (0x49, "6"), (0x55, "7"), (0x61, "8"), (0x6D, "9"), (0x79, "0"), (0x85, "-"), (0x07, "=")
        ]) + [
            KeyLight(0x1F, "⌫", x: 13, y: 2.35, width: 2, name: "Backspace")
        ]
        let topLetterRow = [
            KeyLight(0x02, "Tab", x: 0, y: 3.35, width: 1.5)
        ] + row(3.35, 1.5, [
            (0x0E, "Q"), (0x1A, "W"), (0x26, "E"), (0x32, "R"), (0x3E, "T"), (0x4A, "Y"),
            (0x56, "U"), (0x62, "I"), (0x6E, "O"), (0x7A, "P"), (0x86, "´"), (0x5A, "[")
        ]) + [
            KeyLight(0x7E, "Enter", x: 13.5, y: 3.35, width: 1.5, height: 2, stepped: true)
        ]
        let homeRow = [
            KeyLight(0x03, "Caps", x: 0, y: 4.35, width: 1.75, name: "Caps Lock")
        ] + row(4.35, 1.75, [
            (0x0F, "A"), (0x1B, "S"), (0x27, "D"), (0x33, "F"), (0x3F, "G"), (0x4B, "H"),
            (0x57, "J"), (0x63, "K"), (0x6F, "L"), (0x7B, "Ç"), (0x87, "~"), (0x72, "]")
        ])
        let shiftRow = [
            KeyLight(0x04, "Shift", x: 0, y: 5.35, width: 1.25, name: "Left Shift")
        ] + row(5.35, 1.25, [
            (0x10, "\\"), (0x1C, "Z"), (0x28, "X"), (0x34, "C"), (0x40, "V"), (0x4C, "B"),
            (0x58, "N"), (0x64, "M"), (0x70, ","), (0x7C, "."), (0x88, ";"), (0x8A, "/")
        ]) + [
            KeyLight(0x4F, "Shift", x: 13.25, y: 5.35, width: 1.75, name: "Right Shift")
        ]
        let bottomRow = [
            KeyLight(0x05, "Ctrl", x: 0, y: 6.35, width: 1.25, name: "Left Control"),
            KeyLight(0x11, "Win", x: 1.25, y: 6.35, width: 1.25, name: "Left Windows key"),
            KeyLight(0x1D, "Alt", x: 2.5, y: 6.35, width: 1.25, name: "Left Alt"),
            KeyLight(0x35, "", x: 3.75, y: 6.35, width: 6.25, name: "Space bar"),
            KeyLight(0x59, "Alt Gr", x: 10, y: 6.35, width: 1.25),
            KeyLight(0x65, "Win", x: 11.25, y: 6.35, width: 1.25, name: "Right Windows key"),
            KeyLight(0x71, "Menu", x: 12.5, y: 6.35, width: 1.25),
            KeyLight(0x5B, "Ctrl", x: 13.75, y: 6.35, width: 1.25, name: "Right Control")
        ]
        let navigation = [
            KeyLight(0x36, "Ins", x: 15.45, y: 2.35, name: "Insert"),
            KeyLight(0x42, "Home", x: 16.45, y: 2.35),
            KeyLight(0x4E, "PgUp", x: 17.45, y: 2.35, name: "Page Up"),
            KeyLight(0x2B, "Del", x: 15.45, y: 3.35, name: "Delete"),
            KeyLight(0x37, "End", x: 16.45, y: 3.35),
            KeyLight(0x43, "PgDn", x: 17.45, y: 3.35, name: "Page Down"),
            KeyLight(0x67, "↑", x: 16.45, y: 5.35, name: "Up arrow"),
            KeyLight(0x73, "←", x: 15.45, y: 6.35, name: "Left arrow"),
            KeyLight(0x7F, "↓", x: 16.45, y: 6.35, name: "Down arrow"),
            KeyLight(0x8B, "→", x: 17.45, y: 6.35, name: "Right arrow")
        ]
        let numberPad = [
            KeyLight(0x50, "Num", x: 18.9, y: 2.35, name: "Num Lock"),
            KeyLight(0x5C, "/", x: 19.9, y: 2.35, name: "Numpad divide"),
            KeyLight(0x68, "*", x: 20.9, y: 2.35, name: "Numpad multiply"),
            KeyLight(0x74, "-", x: 21.9, y: 2.35, name: "Numpad subtract"),
            KeyLight(0x80, "+", x: 21.9, y: 3.35, height: 2, name: "Numpad add"),
            KeyLight(0x8C, "Enter", x: 21.9, y: 5.35, height: 2, name: "Numpad Enter"),
            KeyLight(0x81, "0", x: 18.9, y: 6.35, width: 2, name: "Numpad 0"),
            KeyLight(0x8D, ",", x: 20.9, y: 6.35, name: "Numpad decimal")
        ] + row(3.35, 18.9, [(0x09, "7"), (0x15, "8"), (0x21, "9")], prefix: "Numpad ") +
            row(4.35, 18.9, [(0x39, "4"), (0x45, "5"), (0x51, "6")], prefix: "Numpad ") +
            row(5.35, 18.9, [(0x5D, "1"), (0x69, "2"), (0x75, "3")], prefix: "Numpad ")
        let lights = top + numberRow + topLetterRow + homeRow + shiftRow + bottomRow + navigation + numberPad
        return lights.sorted { ($0.y, $0.x) < ($1.y, $1.x) }
    }

    private static func row(
        _ y: Double, _ start: Double, _ keys: [(Int, String)], prefix: String = ""
    ) -> [KeyLight] {
        keys.enumerated().map { index, key in
            KeyLight(key.0, key.1, x: start + Double(index), y: y, name: prefix + key.1)
        }
    }
}
