import SwiftUI

@main
struct MoveToScreenApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        // SwiftUI requires at least one Scene; the menu bar is built
        // by MenuBarController via NSStatusItem (so we get reliable
        // NSMenu delegate callbacks). The Settings scene never appears
        // for an accessory-policy app.
        Settings { EmptyView() }
    }
}
