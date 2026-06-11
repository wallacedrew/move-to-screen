import AppKit
import SwiftUI
import MoveToScreenAdapters

@main
struct MoveToScreenApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    @State private var viewModel = MenuViewModel(
        accessibility: AXAdapter(),
        displayClient: NSScreenAdapter()
    )

    var body: some Scene {
        MenuBarExtra("MoveToScreen", systemImage: "square.3.stack.3d") {
            MenuBarRootView(viewModel: viewModel)
        }
    }
}
