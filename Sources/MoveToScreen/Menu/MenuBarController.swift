import AppKit
import MoveToScreenDomain

/// Owns the NSStatusItem + NSMenu and acts as NSMenuDelegate so we can
/// hook into `willHighlight` — SwiftUI's `.onHover` doesn't fire inside
/// MenuBarExtra submenus on macOS 13/14, so the menu is built by hand
/// to get reliable hover detection.
///
/// All Move logic still goes through MenuViewModel, which still owns
/// the DisplayBadgePresenter — this controller just translates NSMenu
/// events into viewModel calls.
@MainActor
final class MenuBarController: NSObject, NSMenuDelegate {

    private let statusItem: NSStatusItem
    private let viewModel: MenuViewModel
    private let mainMenu = NSMenu()
    private var displayByItem: [ObjectIdentifier: DisplayInfo] = [:]

    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        if let icon = NSImage(
            systemSymbolName: "square.3.stack.3d",
            accessibilityDescription: "MoveToScreen"
        ) {
            statusItem.button?.image = icon
        }

        mainMenu.delegate = self
        mainMenu.autoenablesItems = false
        statusItem.menu = mainMenu
    }

    // MARK: - NSMenuDelegate

    func menuNeedsUpdate(_ menu: NSMenu) {
        guard menu === mainMenu else { return }
        rebuildMainMenu()
    }

    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        viewModel.dismissAllHoverIndicators()
        guard let item, let display = displayByItem[ObjectIdentifier(item)] else { return }
        viewModel.startHoverIndicator(for: display)
    }

    func menuDidClose(_ menu: NSMenu) {
        viewModel.dismissAllHoverIndicators()
    }

    // MARK: - Building

    private func rebuildMainMenu() {
        mainMenu.removeAllItems()
        displayByItem.removeAll()

        let apps = viewModel.runningApps()
        let displays = viewModel.connectedDisplays()

        if apps.isEmpty {
            mainMenu.addItem(emptyPlaceholderItem())
        } else {
            for app in apps {
                mainMenu.addItem(makeAppItem(for: app, displays: displays))
            }
        }

        mainMenu.addItem(.separator())
        mainMenu.addItem(quitMenuItem())
    }

    private func emptyPlaceholderItem() -> NSMenuItem {
        let item = NSMenuItem(title: "No apps with movable windows", action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    private func quitMenuItem() -> NSMenuItem {
        makeMenuItem(title: "Quit MoveToScreen", action: #selector(quitClicked), keyEquivalent: "q")
    }

    private func makeAppItem(for app: AppDescription, displays: [DisplayInfo]) -> NSMenuItem {
        let appItem = NSMenuItem(title: app.displayName, action: nil, keyEquivalent: "")
        appItem.submenu = displaySubmenu(for: app, displays: displays)
        return appItem
    }

    private func displaySubmenu(for app: AppDescription, displays: [DisplayInfo]) -> NSMenu {
        let submenu = NSMenu()
        submenu.delegate = self
        submenu.autoenablesItems = false
        for display in displays {
            let item = makeMenuItem(title: display.name, action: #selector(displayPicked(_:)))
            item.representedObject = MoveRequest(app: app.id, display: display.id)
            submenu.addItem(item)
            displayByItem[ObjectIdentifier(item)] = display
        }
        return submenu
    }

    private func makeMenuItem(title: String, action: Selector, keyEquivalent: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        return item
    }

    @objc private func displayPicked(_ sender: NSMenuItem) {
        guard let pick = sender.representedObject as? MoveRequest else { return }
        viewModel.move(app: pick.app, to: pick.display)
    }

    @objc private func quitClicked() {
        viewModel.dismissAllHoverIndicators()
        NSApp.terminate(nil)
    }

    private final class MoveRequest {
        let app: AppId
        let display: DisplayId
        init(app: AppId, display: DisplayId) {
            self.app = app
            self.display = display
        }
    }
}
