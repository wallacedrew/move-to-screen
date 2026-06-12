import AppKit
import ApplicationServices
import MoveToScreenPorts

/// First-launch Accessibility-permission gate. When the grant is
/// missing, opens System Settings → Privacy & Security → Accessibility,
/// then shows a modal alert that polls AXIsProcessTrusted() twice a
/// second and dismisses itself the moment the user flips the toggle —
/// so the app keeps running without a relaunch.
@MainActor
struct PermissionsCoordinator {

    let accessibility: AccessibilityClient

    /// Returns true if Accessibility access is granted, either
    /// immediately or after the user grants it while the alert is
    /// showing. Returns false if the user picks Quit.
    func awaitGrantOrQuit() -> Bool {
        if accessibility.isAccessibilityGranted() {
            return true
        }
        openAccessibilitySettings()
        return runWaitingAlert()
    }

    // MARK: - Private

    private func runWaitingAlert() -> Bool {
        let alert = makeWaitingAlert()
        let grantedCode = NSApplication.ModalResponse(rawValue: 9999)
        // Add the poller to the main run loop in `.common` modes so it
        // continues to fire while NSAlert.runModal() is pumping the run
        // loop in NSModalPanelRunLoopMode. A DispatchSource on .main does
        // not always get drained during modal sessions; an explicit
        // RunLoop-attached Timer in .common does.
        let timer = Timer(timeInterval: 0.25, repeats: true) { _ in
            guard AXIsProcessTrusted() else { return }
            MainActor.assumeIsolated {
                NSApp.stopModal(withCode: grantedCode)
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        defer { timer.invalidate() }

        let response = alert.runModal()
        return response == grantedCode || AXIsProcessTrusted()
    }

    private func makeWaitingAlert() -> NSAlert {
        let alert = NSAlert()
        alert.messageText = "Enable MoveToScreen in Accessibility"
        alert.informativeText = """
            System Settings has opened to Privacy & Security → Accessibility.

            Toggle MoveToScreen on (or add it via + if it isn't listed). \
            This dialog closes automatically and the menu bar icon will \
            appear — no need to relaunch.
            """
        alert.addButton(withTitle: "Quit")
        alert.alertStyle = .warning
        return alert
    }

    private func openAccessibilitySettings() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
