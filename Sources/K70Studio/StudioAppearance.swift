import SwiftUI

struct StudioBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.07, green: 0.10, blue: 0.15), Color(red: 0.035, green: 0.05, blue: 0.08)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color(red: 0.19, green: 0.55, blue: 0.59).opacity(0.34), .clear],
                center: .topTrailing, startRadius: 10, endRadius: 670
            )
            RadialGradient(
                colors: [Color(red: 0.38, green: 0.30, blue: 0.62).opacity(0.30), .clear],
                center: .bottomLeading, startRadius: 0, endRadius: 580
            )
        }
        .ignoresSafeArea()
    }
}

private struct StudioPanel: ViewModifier {
    let radius: CGFloat

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius)
        content
            .background {
                if reduceTransparency {
                    shape.fill(Color(red: 0.09, green: 0.12, blue: 0.16))
                } else {
                    shape.fill(.ultraThinMaterial)
                        .overlay {
                            shape.fill(LinearGradient(colors: [.white.opacity(0.075), .white.opacity(0.015)],
                                                      startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                }
            }
            .overlay {
                shape.strokeBorder(
                    LinearGradient(colors: [.white.opacity(0.19), .white.opacity(0.065)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .allowsHitTesting(false)
            }
    }
}

private struct StudioActionStyle: ButtonStyle {
    let accent: Color
    let prominent: Bool

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .foregroundStyle(prominent ? Color(red: 0.04, green: 0.16, blue: 0.14) : .primary)
            .background {
                if prominent {
                    Capsule().fill(
                        LinearGradient(colors: [accent.opacity(0.86), accent],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .overlay { Capsule().strokeBorder(.white.opacity(0.32)) }
                } else {
                    Capsule().fill(.regularMaterial)
                        .overlay { Capsule().strokeBorder(.white.opacity(0.14)) }
                }
            }
            .opacity(isEnabled ? (configuration.isPressed ? 0.76 : 1) : 0.42)
            .contentShape(Capsule())
    }
}

extension View {
    func studioPanel(radius: CGFloat = 22) -> some View {
        modifier(StudioPanel(radius: radius))
    }

    @ViewBuilder func studioGlassCapsule(_ tint: Color, interactive: Bool = false) -> some View {
        #if compiler(>=6.2) && canImport(FoundationModels)
        if #available(macOS 26, *) {
            glassEffect(.regular.tint(tint.opacity(0.16)).interactive(interactive), in: Capsule())
        } else {
            materialCapsule(tint)
        }
        #else
        materialCapsule(tint)
        #endif
    }

    @ViewBuilder func studioAction(_ accent: Color, prominent: Bool = false) -> some View {
        #if compiler(>=6.2) && canImport(FoundationModels)
        if #available(macOS 26, *) {
            if prominent {
                buttonStyle(.glassProminent).buttonBorderShape(.capsule).controlSize(.large)
            } else {
                buttonStyle(.glass).buttonBorderShape(.capsule).controlSize(.large)
            }
        } else {
            buttonStyle(StudioActionStyle(accent: accent, prominent: prominent))
        }
        #else
        buttonStyle(StudioActionStyle(accent: accent, prominent: prominent))
        #endif
    }

    private func materialCapsule(_ tint: Color) -> some View {
        background {
            Capsule().fill(.regularMaterial)
                .overlay { Capsule().fill(tint.opacity(0.10)) }
                .overlay { Capsule().strokeBorder(.white.opacity(0.16)) }
        }
    }
}
