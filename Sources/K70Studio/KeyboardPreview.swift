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
            let unit = max(1, min(
                (proxy.size.width - 44) / KeyboardLayout.width,
                (proxy.size.height - 40) / KeyboardLayout.height
            ))
            let width = unit * KeyboardLayout.width
            let height = unit * KeyboardLayout.height
            TimelineView(.animation(minimumInterval: 1.0 / 20, paused: !settings.effect.isAnimated || reduceMotion)) {
                context in
                let elapsed = reduceMotion ? 0 : context.date.timeIntervalSince(started)
                keyboard(unit: unit, elapsed: elapsed)
                    .frame(width: width, height: height)
                    .padding(11)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [Color(white: 0.14), Color(white: 0.075)],
                                                 startPoint: .top, endPoint: .bottom))
                            .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(.white.opacity(0.18)) }
                            .shadow(color: .black.opacity(0.55), radius: 12, y: 8)
                    }
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
        }
        .onChange(of: settings.effect) { _, _ in started = Date() }
        .accessibilityLabel("Brazilian keyboard lighting preview")
    }

    private func keyboard(unit: CGFloat, elapsed: TimeInterval) -> some View {
        ZStack(alignment: .topLeading) {
            Capsule()
                .fill(.white.opacity(0.10))
                .overlay { Capsule().strokeBorder(.white.opacity(0.12)) }
                .frame(width: unit * 2.6, height: unit * 0.46)
                .offset(x: unit * 20.06, y: unit * 0.13)
                .accessibilityHidden(true)

            ForEach(KeyboardLayout.brazilian) { key in
                let selected = settings.effect == .perKey && key.id == selectedKey
                let light = settings.color(for: key, elapsed: elapsed).color
                let shape = Keycap(stepped: key.stepped)
                Button {
                    onSelect(key)
                } label: {
                    shape
                        .fill(Color(white: 0.16))
                        .overlay { shape.fill(light.opacity(0.34)) }
                        .overlay {
                            shape.stroke(selected ? .white : light.opacity(0.82), lineWidth: selected ? 1.8 : 1)
                        }
                        .overlay {
                            Text(key.label)
                                .font(.system(size: max(7, min(unit * 0.29, 12)), weight: .semibold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.94))
                                .lineLimit(1)
                                .minimumScaleFactor(0.68)
                                .padding(.horizontal, 2)
                        }
                        .contentShape(shape)
                }
                .buttonStyle(.plain)
                .frame(width: key.width * unit - 3, height: key.height * unit - 3)
                .offset(x: key.x * unit + 1.5, y: key.y * unit + 1.5)
                .help(key.name)
                .accessibilityLabel(key.name)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
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
