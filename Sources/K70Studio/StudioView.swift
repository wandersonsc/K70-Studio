import K70Core
import SwiftUI

@MainActor
struct StudioView: View {
    @ObservedObject var model: StudioModel
    @State private var savingProfile = false
    @State private var profileName = ""

    private let accent = Color(red: 0.50, green: 0.92, blue: 0.78)
    private let presets: [(String, RGB)] = [
        ("Mint", RGB(123, 225, 195)),
        ("Blue", RGB(88, 158, 255)),
        ("Violet", RGB(184, 125, 255)),
        ("Amber", RGB(255, 176, 82)),
        ("White", RGB(255, 255, 255))
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            HStack(spacing: 0) {
                controls
                    .frame(width: 244)
                    .background(.white.opacity(0.024))
                Divider()
                preview
            }
            Divider()
            footer
        }
        .background(Color(red: 0.060, green: 0.075, blue: 0.088))
        .tint(accent)
        .sheet(isPresented: $savingProfile) { saveProfileSheet }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "keyboard")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 43, height: 43)
                .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text("K70 Studio")
                    .font(.system(size: 23, weight: .semibold))
                Text("K70 RGB MK.2 Low Profile RAPIDFIRE")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Label(connectionTitle, systemImage: connectionSymbol)
                .font(.callout.weight(.medium))
                .foregroundStyle(connectionColor)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(connectionColor.opacity(0.10), in: Capsule())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    private var controls: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 9) {
                    Text("Lighting effect").font(.headline)
                    ForEach(LightingEffect.allCases, id: \.self) { effect in
                        effectButton(effect)
                    }
                }
                Divider()
                if model.draft.effect.usesBaseColor {
                    VStack(alignment: .leading, spacing: 9) {
                        Text("Base color").font(.headline)
                        ColorField(title: "Base color", color: $model.draft.baseColor)
                        HStack(spacing: 9) {
                            ForEach(presets.indices, id: \.self) { index in
                                let preset = presets[index]
                                Button {
                                    model.draft.baseColor = preset.1
                                } label: {
                                    Circle()
                                        .fill(preset.1.color)
                                        .frame(width: 22, height: 22)
                                        .overlay {
                                            if model.draft.baseColor == preset.1 {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .foregroundStyle(.black)
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                                .help(preset.0)
                                .accessibilityLabel(preset.0)
                            }
                        }
                    }
                }
                if model.draft.effect != .off {
                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            Text("Brightness").font(.headline)
                            Spacer()
                            Text(model.draft.brightness, format: .percent.precision(.fractionLength(0)))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $model.draft.brightness, in: 0...1, step: 0.01) {
                            Text("Brightness")
                        }
                        .labelsHidden()
                    }
                }
                if model.draft.effect.isAnimated {
                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            Text("Cycle duration").font(.headline)
                            Spacer()
                            Text("\(model.draft.period, specifier: "%.1f") s")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $model.draft.period, in: 1...12, step: 0.5) {
                            Text("Cycle duration")
                        }
                        .labelsHidden()
                    }
                }
            }
            .padding(20)
        }
    }

    private var preview: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Keyboard preview").font(.title3.weight(.semibold))
                    Text("Brazilian layout (ABNT2)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                profileMenu
            }

            KeyboardPreview(settings: model.draft, selectedKey: model.selectedKey, onSelect: model.select)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(RadialGradient(
                            colors: [accent.opacity(0.09), .clear],
                            center: .center, startRadius: 20, endRadius: 390
                        ))
                        .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 18))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.09))
                }

            keyInspector
                .frame(height: 40)
        }
        .padding(20)
    }

    @ViewBuilder private var keyInspector: some View {
        if model.draft.effect == .perKey, let key = model.selectedLight {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(key.name).font(.headline)
                    Text(model.draft.overrides[key.id] == nil ? "Uses base color" : "Custom color")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ColorField(title: "Color for \(key.name)", color: Binding {
                    model.draft.overrides[key.id] ?? model.draft.baseColor
                } set: {
                    model.draft.overrides[key.id] = $0
                })
                .id(key.id)
                .frame(width: 140)
                Button("Use Base Color") { model.draft.overrides[key.id] = nil }
                    .disabled(model.draft.overrides[key.id] == nil)
            }
        } else {
            Label("Click any key in the preview to edit its color.", systemImage: "cursorarrow.click")
                .foregroundStyle(.secondary)
                .font(.callout)
        }
    }

    private var profileMenu: some View {
        Menu {
            Button("Save Current Lighting…") {
                profileName = ""
                savingProfile = true
            }
            if !model.profiles.isEmpty {
                Divider()
                ForEach(model.profiles) { profile in
                    Button(profile.name) { model.load(profile.settings) }
                }
                Divider()
                Menu("Delete Profile") {
                    ForEach(model.profiles) { profile in
                        Button(profile.name, role: .destructive) { model.deleteProfile(id: profile.id) }
                    }
                }
            }
        } label: {
            Label("Profiles", systemImage: "square.stack")
        }
        .fixedSize()
    }

    private var saveProfileSheet: some View {
        let trimmedName = profileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let duplicate = model.profiles.contains { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }
        return VStack(alignment: .leading, spacing: 14) {
            Text("Save lighting profile").font(.title3.weight(.semibold))
            TextField("Profile name", text: $profileName)
                .textFieldStyle(.roundedBorder)
            if duplicate {
                Text("A profile already uses this name.").foregroundStyle(.secondary)
            }
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { savingProfile = false }
                Button("Save") {
                    model.saveProfile(named: trimmedName)
                    savingProfile = false
                }
                .disabled(trimmedName.isEmpty || trimmedName.count > 60 || duplicate)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 350)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            if model.isWorking {
                ProgressView().controlSize(.small)
            }
            Text(model.profileError ?? connectionDetail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer()
            Button("Restore Onboard Lighting", action: model.restore)
                .disabled(!model.canRestore)
                .fixedSize()
            Button("Apply to Keyboard", action: model.apply)
                .buttonStyle(.borderedProminent)
                .disabled(!model.canApply)
                .fixedSize()
                .help("Send this preview to the connected keyboard")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
    }

    private func effectButton(_ effect: LightingEffect) -> some View {
        let selected = model.draft.effect == effect
        return Button {
            model.draft.effect = effect
        } label: {
            HStack(spacing: 10) {
                Image(systemName: effect.symbol)
                    .frame(width: 17)
                    .accessibilityHidden(true)
                Text(effect.rawValue)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.semibold))
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .foregroundStyle(selected ? accent : .primary)
            .background(selected ? accent.opacity(0.10) : .clear, in: RoundedRectangle(cornerRadius: 7))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var connectionTitle: String {
        switch model.status {
        case .searching: "Checking USB"
        case .preview: "Preview only"
        case .disconnected: "Keyboard disconnected"
        case .lightingUnavailable: "Lighting interface unavailable"
        case .multipleDevices: "Multiple keyboards"
        case .available, .applied: "Keyboard connected"
        case .failed: "USB error"
        }
    }

    private var connectionSymbol: String {
        switch model.status {
        case .available, .applied: "checkmark.circle.fill"
        case .failed, .multipleDevices, .lightingUnavailable: "exclamationmark.circle"
        default: "circle.dashed"
        }
    }

    private var connectionColor: Color {
        switch model.status {
        case .available, .applied: accent
        case .failed, .multipleDevices, .lightingUnavailable: .orange
        default: .secondary
        }
    }

    private var connectionDetail: String {
        switch model.status {
        case .searching: "Looking for the keyboard’s USB lighting interface."
        case .preview: "You can edit and save lighting in preview mode."
        case .disconnected: "Plug in the keyboard’s USB connector to apply lighting."
        case .lightingUnavailable: "macOS sees the K70. Quit other RGB apps, then reconnect the keyboard directly."
        case .multipleDevices: "Connect one K70 RGB MK.2 Low Profile to apply lighting."
        case .available: "Ready to send lighting to the keyboard."
        case .applied:
            model.status.appliedSettings == model.draft
                ? "Lighting sent. Keep K70 Studio open to run effects."
                : "Preview edited. Apply to update the keyboard."
        case let .failed(message): message
        }
    }
}

private extension LightingEffect {
    var symbol: String {
        switch self {
        case .solid: "circle.fill"
        case .perKey: "square.grid.3x3"
        case .breathing: "waveform.path"
        case .rainbow: "rainbow"
        case .off: "moon"
        }
    }
}

private struct ColorField: View {
    let title: String
    @Binding var color: RGB
    @State private var hex = ""
    @FocusState private var editingHex: Bool

    var body: some View {
        HStack(spacing: 7) {
            ColorPicker(title, selection: Binding {
                color.color
            } set: { value in
                if let rgb = RGB(color: value) {
                    color = rgb
                    hex = rgb.hex
                }
            }, supportsOpacity: false)
            .labelsHidden()
            TextField("#RRGGBB", text: $hex)
                .textFieldStyle(.roundedBorder)
                .font(.system(.callout, design: .monospaced))
                .focused($editingHex)
                .accessibilityLabel("\(title) hex code")
                .onChange(of: hex) { _, value in
                    if editingHex, let rgb = RGB(hex: value) { color = rgb }
                }
                .onSubmit { hex = color.hex }
                .onChange(of: editingHex) { _, editing in
                    if !editing { hex = color.hex }
                }
                .onChange(of: color, initial: true) { _, value in
                    if !editingHex { hex = value.hex }
                }
        }
    }
}
