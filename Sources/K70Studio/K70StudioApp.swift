import AppKit
import SwiftUI

@main
@MainActor
struct K70StudioApp: App {
    @NSApplicationDelegateAdaptor(StudioAppDelegate.self) private var delegate
    @StateObject private var model = StudioModel()

    var body: some Scene {
        Window("K70 Studio", id: "studio") {
            StudioView(model: model)
                .preferredColorScheme(.dark)
                .frame(minWidth: 970, minHeight: 585)
                .onAppear { delegate.controller = model.controller }
        }
        .defaultSize(width: 1200, height: 650)
        .windowResizability(.contentMinSize)
    }
}

@MainActor
final class StudioAppDelegate: NSObject, NSApplicationDelegate {
    var controller: KeyboardController?

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let controller else { return .terminateNow }
        controller.shutDown {
            sender.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }
}
