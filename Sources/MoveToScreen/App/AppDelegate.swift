import AppKit
import MoveToScreenAdapters

/// Bridges SwiftUI's App lifecycle to AppKit. Owns the view model and
/// the menu bar controller — both live for the app's lifetime. NSApp
/// is fully up by the time `applicationDidFinishLaunching` fires, so
/// permission prompts (NSAlert) and NSStatusItem creation are safe here.
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var viewModel: MenuViewModel?
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let accessibility = AXAdapter()
        let permissions = PermissionsCoordinator(accessibility: accessibility)
        guard permissions.isGrantedOrPrompt() else {
            NSApp.terminate(nil)
            return
        }

        let model = MenuViewModel(
            accessibility: accessibility,
            displayClient: NSScreenAdapter()
        )
        self.viewModel = model
        self.menuBarController = MenuBarController(viewModel: model)
    }
}
