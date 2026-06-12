import Foundation
import OSLog
import MoveToScreenDomain
import MoveToScreenPorts
import MoveToScreenUseCases

/// Pulls fresh state from the ports and dispatches move requests to the
/// use case. The view layer reads through this — no SwiftUI body should
/// import a port or a use case directly.
@MainActor
final class MenuViewModel {

    private let accessibility: AccessibilityClient
    private let displayClient: DisplayClient
    private let loginItem: LoginItemClient
    private let moveAppWindows: MoveAppWindowsToDisplay
    private let moveAppsUseCase: MoveAppsWindowsToDisplay
    private let toggleOpenAtLoginUseCase: ToggleOpenAtLogin
    private let badgePresenter: DisplayBadgePresenter
    private var selectedAppIds: Set<AppId> = []
    private let logger = Logger(subsystem: "com.movetoscreen", category: "menu")

    init(
        accessibility: AccessibilityClient,
        displayClient: DisplayClient,
        loginItem: LoginItemClient
    ) {
        self.accessibility = accessibility
        self.displayClient = displayClient
        self.loginItem = loginItem
        self.moveAppWindows = MoveAppWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )
        self.moveAppsUseCase = MoveAppsWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )
        self.toggleOpenAtLoginUseCase = ToggleOpenAtLogin(loginItem: loginItem)
        self.badgePresenter = DisplayBadgePresenter()
    }

    func startHoverIndicator(for display: DisplayInfo) {
        badgePresenter.show(display)
    }

    func dismissAllHoverIndicators() {
        badgePresenter.hideAll()
    }

    func runningApps() -> [AppDescription] {
        do {
            return try accessibility.runningAppsWithEligibleWindows()
        } catch {
            logFailure("runningAppsWithEligibleWindows", error)
            return []
        }
    }

    func connectedDisplays() -> [DisplayInfo] {
        return displayClient.connectedDisplays()
    }

    func isOpenAtLoginEnabled() -> Bool {
        return loginItem.isEnabled()
    }

    func toggleOpenAtLogin() {
        do {
            try toggleOpenAtLoginUseCase.execute()
        } catch {
            logFailure("toggleOpenAtLogin", error)
        }
    }

    func move(app: AppId, to display: DisplayId) {
        badgePresenter.hideAll()
        do {
            let result = try moveAppWindows.move(app: app, to: display)
            logger.info("moved \(result.moved); skipped \(result.skipped.count)")
        } catch {
            logFailure("move", error)
        }
    }

    func moveAllWindows(to display: DisplayId) {
        badgePresenter.hideAll()
        let apps = runningApps().map(\.id)
        do {
            let result = try moveAppsUseCase.move(apps: apps, to: display)
            logger.info("moved \(result.moved); skipped \(result.skipped.count)")
        } catch {
            logFailure("moveAllWindows", error)
        }
    }

    // MARK: - Selection

    func isSelected(_ app: AppId) -> Bool {
        return selectedAppIds.contains(app)
    }

    func hasMultipleSelections() -> Bool {
        return selectedAppIds.count >= 2
    }

    func toggleSelection(_ app: AppId) {
        if selectedAppIds.contains(app) {
            selectedAppIds.remove(app)
        } else {
            selectedAppIds.insert(app)
        }
    }

    func clearSelection() {
        selectedAppIds.removeAll()
    }

    func moveSelected(to display: DisplayId) {
        badgePresenter.hideAll()
        let apps = Array(selectedAppIds)
        do {
            let result = try moveAppsUseCase.move(apps: apps, to: display)
            logger.info("moved \(result.moved); skipped \(result.skipped.count)")
            selectedAppIds.removeAll()
        } catch {
            logFailure("moveSelected", error)
        }
    }

    private func logFailure(_ context: String, _ error: Error) {
        logger.error("\(context) failed: \(String(describing: error))")
    }
}
