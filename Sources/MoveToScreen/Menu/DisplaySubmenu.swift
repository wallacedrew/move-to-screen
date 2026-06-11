import SwiftUI
import MoveToScreenDomain

/// One row per app: the app's name, with a submenu listing every
/// connected display. Clicking a display issues the bulk-move.
struct DisplaySubmenu: View {

    let app: AppDescription
    let displays: [DisplayInfo]
    let onPick: (DisplayId) -> Void

    var body: some View {
        Menu(app.displayName) {
            ForEach(displays, id: \.id) { display in
                Button(display.name) {
                    onPick(display.id)
                }
            }
        }
    }
}
