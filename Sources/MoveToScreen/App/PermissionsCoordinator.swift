import AppKit
import MoveToScreenPorts

/// First-launch Accessibility-permission gate. Slice 1 form: stock
/// NSAlert with an "Open Settings" button that deep-links to
/// Privacy & Security → Accessibility. After granting, the user
/// re-launches the app. Slice 2 will replace this with a polished
/// SwiftUI explainer window that polls AXIsProcessTrusted() and
/// dismisses itself the moment permission flips true.
@MainActor
struct PermissionsCoordinator {

    let accessibility: AccessibilityClient

    /// Returns true if permission is already granted (app should proceed).
    /// Returns false if permission was missing — caller should terminate
    /// after this method returns; the user has been shown the NSAlert and
    /// either opened Settings or chose Quit.
    func isGrantedOrPrompt() -> Bool {
        if accessibility.isAccessibilityGranted() {
            return true
        }
        promptAndOpenSettingsIfChosen()
        return false
    }

    // MARK: - Private

    private func promptAndOpenSettingsIfChosen() {
        let alert = NSAlert()
        alert.messageText = "MoveToScreen needs Accessibility access"
        alert.informativeText = """
            Without this permission, MoveToScreen cannot move other apps' windows.

            Click Open Settings, enable MoveToScreen under \
            Privacy & Security → Accessibility, then re-launch.
            """
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Quit")
        alert.alertStyle = .warning

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openAccessibilitySettings()
        }
    }

    private func openAccessibilitySettings() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
