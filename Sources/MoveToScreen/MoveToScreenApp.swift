import AppKit
import SwiftUI

@main
struct MoveToScreenApp: App {
    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra("MoveToScreen", systemImage: "square.3.stack.3d") {
            Button("Quit MoveToScreen") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
