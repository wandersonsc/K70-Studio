import AppKit
import K70Core
import SwiftUI

@MainActor
final class StudioModel: ObservableObject {
    @Published var draft = LightingSettings()
    @Published var selectedKey: Int?
    @Published private(set) var status: KeyboardStatus = .searching
    @Published private(set) var profiles: [LightingProfile] = []
    @Published private(set) var profileError: String?
    @Published private(set) var isWorking = false

    private let defaults: UserDefaults
    private let profileKey = "lightingProfiles.v1"
    private let preview: Bool
    private(set) lazy var controller = KeyboardController(preview: preview) { [weak self] status in
        guard let self else { return }
        self.status = status
        self.isWorking = false
    }

    init(preview: Bool = CommandLine.arguments.contains("--preview")) {
        self.preview = preview
        defaults = preview ? (UserDefaults(suiteName: "app.k70studio.preview") ?? .standard) : .standard
        if let data = defaults.data(forKey: profileKey) {
            do {
                profiles = try JSONDecoder().decode([LightingProfile].self, from: data)
            } catch {
                profileError = "Saved profiles could not be loaded."
            }
        }
        _ = controller
    }

    var selectedLight: KeyLight? {
        KeyboardLayout.brazilian.first { $0.id == selectedKey }
    }

    var canApply: Bool { status.canApply && !isWorking }
    var canRestore: Bool { status.appliedSettings != nil && !isWorking }

    func select(_ key: KeyLight) {
        selectedKey = key.id
        draft.effect = .perKey
    }

    func apply() {
        guard canApply else { return }
        isWorking = true
        controller.apply(draft)
    }

    func restore() {
        guard canRestore else { return }
        isWorking = true
        controller.restore()
    }

    func load(_ settings: LightingSettings) {
        draft = settings
        selectedKey = nil
    }

    func saveProfile(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let profile = LightingProfile(name: trimmed, settings: draft)
        save(profiles + [profile])
    }

    func deleteProfile(id: UUID) {
        save(profiles.filter { $0.id != id })
    }

    private func save(_ updated: [LightingProfile]) {
        do {
            defaults.set(try JSONEncoder().encode(updated), forKey: profileKey)
            profiles = updated
            profileError = nil
        } catch {
            profileError = "Lighting profiles could not be saved."
        }
    }
}

extension RGB {
    var color: Color {
        Color(.sRGB, red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }

    init?(color: Color) {
        guard let converted = NSColor(color).usingColorSpace(.sRGB) else { return nil }
        func byte(_ component: CGFloat) -> UInt8 {
            UInt8((max(0, min(1, component)) * 255).rounded())
        }
        self.init(byte(converted.redComponent), byte(converted.greenComponent), byte(converted.blueComponent))
    }
}
