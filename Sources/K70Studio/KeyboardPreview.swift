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
            let caseInset: CGFloat = 12
            let totalInset = 2 * (caseInset + 16)
            let unit = min(
                (proxy.size.width - totalInset) / KeyboardLayout.width,
                (proxy.size.height - totalInset) / KeyboardLayout.height
            )
            if unit > 0 {
                TimelineView(.animation(minimumInterval: 1.0 / 20, paused: !settings.effect.isAnimated || reduceMotion)) {
                    context in
                    let elapsed = reduceMotion ? 0 : context.date.timeIntervalSince(started)
                    keyboard(unit: unit, elapsed: elapsed)
                        .frame(width: unit * KeyboardLayout.width, height: unit * KeyboardLayout.height)
                        .padding(caseInset)
                        .background { backplate }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
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

    private func keyboard(unit: CGFloat, elapsed: TimeInterval) -> some View {
        GeometryReader { _ in
            // Each position is measured from the same board bounds used by the backplate.
            ZStack {
                Capsule()
                    .fill(.white.opacity(0.10))
                    .overlay { Capsule().strokeBorder(.white.opacity(0.12)) }
                    .frame(width: unit * 2.6, height: unit * 0.46)
                    .position(x: unit * 21.36, y: unit * 0.36)
                    .accessibilityHidden(true)

                ForEach(KeyboardLayout.brazilian) { key in
                    keyButton(key, unit: unit, elapsed: elapsed)
                        .position(
                            x: (key.x + key.width / 2) * unit,
                            y: (key.y + key.height / 2) * unit
                        )
                }
            }
        }
    }

    private func keyButton(_ key: KeyLight, unit: CGFloat, elapsed: TimeInterval) -> some View {
        let selected = settings.effect == .perKey && key.id == selectedKey
        let light = settings.color(for: key, elapsed: elapsed).color
        let shape = Keycap(stepped: key.stepped)
        let gap = min(3, unit * 0.09)

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
                .frame(width: key.width * unit - gap, height: key.height * unit - gap)
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        .help(key.name)
        .accessibilityLabel(key.name)
        .accessibilityAddTraits(selected ? .isSelected : [])
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
