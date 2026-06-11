import AppKit
import SwiftUI
import MoveToScreenDomain

/// Top-level content for the MenuBarExtra. Just orchestrates dumb child
/// views. The view model is read fresh on every body evaluation so the
/// menu reflects current state when the user opens it.
struct MenuBarRootView: View {

    let viewModel: MenuViewModel

    var body: some View {
        let apps = viewModel.runningApps()
        let displays = viewModel.connectedDisplays()

        if apps.isEmpty {
            Text("No apps with movable windows")
        } else {
            AppListMenu(
                apps: apps,
                displays: displays,
                onMove: { app, display in viewModel.move(app: app, to: display) },
                onHoverDisplay: { display, isHovering in
                    if isHovering {
                        viewModel.startHoverIndicator(for: display)
                    } else {
                        viewModel.endHoverIndicator(for: display.id)
                    }
                }
            )
        }

        Divider()

        Button("Quit MoveToScreen") {
            viewModel.dismissAllHoverIndicators()
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
