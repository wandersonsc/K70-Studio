import K70Core
import SwiftUI

struct KeyboardPreview: View {
    let settings: LightingSettings
    let selectedKey: Int?
    let onSelect: (KeyLight) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var started = Date()

    var body: some View {
        GeometryReader { proxy in
            let geometry = KeyboardPreviewGeometry(in: proxy.size)
            if geometry.unit > 0 {
                TimelineView(.animation(minimumInterval: 1.0 / 20, paused: !settings.effect.isAnimated || reduceMotion)) {
                    context in
                    let elapsed = reduceMotion ? 0 : context.date.timeIntervalSince(started)
                    keyboard(geometry: geometry, elapsed: elapsed)
                }
                .frame(width: geometry.keyArea.width, height: geometry.keyArea.height)
                .padding(KeyboardPreviewGeometry.caseInset)
                .background { backplate }
                .position(x: geometry.keyArea.midX, y: geometry.keyArea.midY)
            }
        }
        .onChange(of: settings.effect) { _, _ in started = Date() }
        .accessibilityLabel("Brazilian keyboard lighting preview")
    }

    private var backplate: some View {
        let shape = RoundedRectangle(cornerRadius: 14)
        return shape
            .fill(LinearGradient(colors: [Color(white: 0.15), Color(white: 0.064)],
                                 startPoint: .top, endPoint: .bottom))
            .overlay {
                shape.strokeBorder(
                    LinearGradient(colors: [.white.opacity(0.20), .white.opacity(0.055)],
                                   startPoint: .top, endPoint: .bottom)
                )
            }
            .shadow(color: .black.opacity(0.48), radius: 12, y: 8)
    }

    private func keyboard(geometry: KeyboardPreviewGeometry, elapsed: TimeInterval) -> some View {
        let unit = geometry.unit
        return GeometryReader { _ in
            // Each position is measured from the same board bounds used by the backplate.
            ZStack {
                Capsule()
                    .fill(.white.opacity(0.10))
                    .overlay { Capsule().strokeBorder(.white.opacity(0.12)) }
                    .frame(width: unit * 2.6, height: unit * 0.46)
                    .position(x: unit * 21.36, y: unit * 0.36)
                    .accessibilityHidden(true)

                ForEach(KeyboardLayout.brazilian) { key in
                    let frame = geometry.keycapFrame(for: key)
                    keyButton(key, size: frame.size, unit: unit, elapsed: elapsed)
                        .position(x: frame.midX, y: frame.midY)
                }
            }
        }
    }

    private func keyButton(_ key: KeyLight, size: CGSize, unit: CGFloat, elapsed: TimeInterval) -> some View {
        let selected = settings.effect == .perKey && key.id == selectedKey
        let light = settings.color(for: key, elapsed: elapsed).color
        let shape = Keycap(stepped: key.stepped)

        return Button {
            onSelect(key)
        } label: {
            shape
                .fill(LinearGradient(colors: [Color(white: 0.19), Color(white: 0.10)],
                                     startPoint: .top, endPoint: .bottom))
                .overlay {
                    shape.fill(LinearGradient(colors: [light.opacity(0.16), light.opacity(0.38)],
                                              startPoint: .top, endPoint: .bottom))
                }
                .overlay {
                    shape.stroke(.white.opacity(0.15), lineWidth: 0.8)
                    shape.stroke(selected ? .white : light.opacity(0.70), lineWidth: selected ? 1.8 : 0.9)
                }
                .overlay {
                    Text(key.label)
                        .font(.system(size: max(7, min(unit * 0.30, 12)), weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.94))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                        .padding(.horizontal, 2)
                }
                .frame(width: size.width, height: size.height)
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        .help(key.name)
        .accessibilityLabel(key.name)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct KeyboardPreviewGeometry {
    static let caseInset: CGFloat = 12
    let unit: CGFloat
    let keyArea: CGRect

    init(in size: CGSize) {
        let margins = 2 * (Self.caseInset + 16)
        unit = max(0, min(
            (size.width - margins) / KeyboardLayout.width,
            (size.height - margins) / KeyboardLayout.height
        ))
        let width = unit * KeyboardLayout.width
        let height = unit * KeyboardLayout.height
        keyArea = CGRect(x: (size.width - width) / 2, y: (size.height - height) / 2, width: width, height: height)
    }

    func keycapFrame(for key: KeyLight) -> CGRect {
        let gap = min(3, unit * 0.09)
        return CGRect(x: key.x * unit + gap / 2, y: key.y * unit + gap / 2,
                      width: key.width * unit - gap, height: key.height * unit - gap)
    }
}

private struct Keycap: Shape {
    let stepped: Bool

    func path(in rect: CGRect) -> Path {
        guard stepped else {
            return RoundedRectangle(cornerRadius: 4).path(in: rect)
        }

        let inset = rect.width / 6
        return Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + inset, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.closeSubpath()
        }
    }
}
