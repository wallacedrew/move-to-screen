import AppKit
import SwiftUI
import MoveToScreenAdapters

@main
struct MoveToScreenApp: App {

    @State private var viewModel: MenuViewModel

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
        let accessibility = AXAdapter()
        let displays = NSScreenAdapter()
        _viewModel = State(initialValue: MenuViewModel(
            accessibility: accessibility,
            displayClient: displays
        ))
    }

    var body: some Scene {
        MenuBarExtra("MoveToScreen", systemImage: "square.3.stack.3d") {
            MenuBarRootView(viewModel: viewModel)
        }
    }
}
