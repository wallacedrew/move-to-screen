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
    private var moveSelectedItem: NSMenuItem?

    private typealias MoveRequest = (app: AppId, display: DisplayId)

    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        configureStatusItemIcon()
        configureMainMenu()
    }

    private func configureStatusItemIcon() {
        if let icon = NSImage(
            systemSymbolName: "square.3.stack.3d",
            accessibilityDescription: "MoveToScreen"
        ) {
            statusItem.button?.image = icon
        }
    }

    private func configureMainMenu() {
        wireDelegate(mainMenu)
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
        moveSelectedItem = nil

        let apps = viewModel.runningApps()
        let displays = viewModel.connectedDisplays()

        if apps.isEmpty {
            mainMenu.addItem(emptyPlaceholderItem())
        } else {
            mainMenu.addItem(makeMoveAllItem(displays: displays))
            let selectedItem = makeMoveSelectedItem(displays: displays)
            selectedItem.isHidden = !viewModel.hasMultipleSelections()
            mainMenu.addItem(selectedItem)
            moveSelectedItem = selectedItem
            mainMenu.addItem(.separator())
            for app in apps {
                mainMenu.addItem(makeAppItem(for: app, displays: displays))
            }
        }

        mainMenu.addItem(.separator())
        mainMenu.addItem(openAtLoginMenuItem())
        mainMenu.addItem(.separator())
        mainMenu.addItem(quitMenuItem())
    }

    private func openAtLoginMenuItem() -> NSMenuItem {
        let item = makeMenuItem(
            title: "Open at Login",
            action: #selector(toggleOpenAtLoginClicked)
        )
        item.state = viewModel.isOpenAtLoginEnabled() ? .on : .off
        return item
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
        appItem.view = AppRowView(
            app: app,
            isChecked: viewModel.isSelected(app.id),
            target: self,
            action: #selector(toggleSelectionFromCheckbox(_:))
        )
        appItem.submenu = displaySubmenu(for: app, displays: displays)
        return appItem
    }

    private func displaySubmenu(for app: AppDescription, displays: [DisplayInfo]) -> NSMenu {
        let submenu = NSMenu()
        wireDelegate(submenu)
        for display in displays {
            let item = makeMenuItem(title: display.name, action: #selector(displayPicked(_:)))
            item.representedObject = (app: app.id, display: display.id) as MoveRequest
            submenu.addItem(item)
            displayByItem[ObjectIdentifier(item)] = display
        }
        return submenu
    }

    private func makeMoveAllItem(displays: [DisplayInfo]) -> NSMenuItem {
        let item = NSMenuItem(title: "Move all windows", action: nil, keyEquivalent: "")
        item.submenu = moveAllDisplaySubmenu(displays: displays)
        return item
    }

    private func moveAllDisplaySubmenu(displays: [DisplayInfo]) -> NSMenu {
        let submenu = NSMenu()
        wireDelegate(submenu)
        for display in displays {
            let item = makeMenuItem(title: display.name, action: #selector(moveAllPicked(_:)))
            item.representedObject = display.id
            submenu.addItem(item)
            displayByItem[ObjectIdentifier(item)] = display
        }
        return submenu
    }

    private func makeMoveSelectedItem(displays: [DisplayInfo]) -> NSMenuItem {
        let item = NSMenuItem(title: "Move selected windows", action: nil, keyEquivalent: "")
        item.submenu = moveSelectedDisplaySubmenu(displays: displays)
        return item
    }

    private func moveSelectedDisplaySubmenu(displays: [DisplayInfo]) -> NSMenu {
        let submenu = NSMenu()
        wireDelegate(submenu)
        for display in displays {
            let item = makeMenuItem(title: display.name, action: #selector(moveSelectedPicked(_:)))
            item.representedObject = display.id
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

    private func wireDelegate(_ menu: NSMenu) {
        menu.delegate = self
        menu.autoenablesItems = false
    }

    @objc private func displayPicked(_ sender: NSMenuItem) {
        guard let request = sender.representedObject as? MoveRequest else { return }
        viewModel.move(app: request.app, to: request.display)
    }

    @objc private func moveAllPicked(_ sender: NSMenuItem) {
        guard let display = sender.representedObject as? DisplayId else { return }
        viewModel.moveAllWindows(to: display)
    }

    @objc private func moveSelectedPicked(_ sender: NSMenuItem) {
        guard let display = sender.representedObject as? DisplayId else { return }
        viewModel.moveSelected(to: display)
    }

    @objc private func toggleSelectionFromCheckbox(_ sender: NSButton) {
        let appId = AppId(rawValue: pid_t(sender.tag))
        viewModel.toggleSelection(appId)
        moveSelectedItem?.isHidden = !viewModel.hasMultipleSelections()
    }

    @objc private func toggleOpenAtLoginClicked() {
        viewModel.toggleOpenAtLogin()
    }

    @objc private func quitClicked() {
        viewModel.dismissAllHoverIndicators()
        NSApp.terminate(nil)
    }
}
