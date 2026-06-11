import AppKit
import MoveToScreenAdapters

/// Bridges SwiftUI's App lifecycle to AppKit hooks. The activation-policy
/// flip and the permissions gate both want NSApp running, which is
/// guaranteed by the time applicationDidFinishLaunching fires.
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let coordinator = PermissionsCoordinator(accessibility: AXAdapter())
        if !coordinator.isGrantedOrPrompt() {
            NSApp.terminate(nil)
        }
    }
}
