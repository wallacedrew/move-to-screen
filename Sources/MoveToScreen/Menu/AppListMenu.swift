import SwiftUI
import MoveToScreenDomain

/// Renders the list of running apps (each with a "Move to →" submenu).
struct AppListMenu: View {

    let apps: [AppDescription]
    let displays: [DisplayInfo]
    let onMove: (AppId, DisplayId) -> Void

    var body: some View {
        ForEach(apps, id: \.id) { app in
            DisplaySubmenu(
                app: app,
                displays: displays,
                onPick: { displayId in onMove(app.id, displayId) }
            )
        }
    }
}
