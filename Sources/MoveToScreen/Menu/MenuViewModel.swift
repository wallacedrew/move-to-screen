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
    private let moveAppWindows: MoveAppWindowsToDisplay
    private let badgePresenter: DisplayBadgePresenter
    private let logger = Logger(subsystem: "com.movetoscreen", category: "menu")

    init(accessibility: AccessibilityClient, displayClient: DisplayClient) {
        self.accessibility = accessibility
        self.displayClient = displayClient
        self.moveAppWindows = MoveAppWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )
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

    func move(app: AppId, to display: DisplayId) {
        badgePresenter.hideAll()
        do {
            let result = try moveAppWindows.execute(app: app, destination: display)
            logger.info("moved \(result.moved); skipped \(result.skipped.count)")
        } catch {
            logFailure("move", error)
        }
    }

    private func logFailure(_ context: String, _ error: Error) {
        logger.error("\(context) failed: \(String(describing: error))")
    }
}
