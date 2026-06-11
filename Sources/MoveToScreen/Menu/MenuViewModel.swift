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
    private let logger = Logger(subsystem: "com.movetoscreen", category: "menu")

    init(accessibility: AccessibilityClient, displayClient: DisplayClient) {
        self.accessibility = accessibility
        self.displayClient = displayClient
        self.moveAppWindows = MoveAppWindowsToDisplay(
            accessibility: accessibility,
            displayClient: displayClient
        )
    }

    func runningApps() -> [AppDescription] {
        do {
            return try accessibility.runningAppsWithEligibleWindows()
        } catch {
            logger.error("runningAppsWithEligibleWindows failed: \(String(describing: error))")
            return []
        }
    }

    func connectedDisplays() -> [DisplayInfo] {
        return displayClient.connectedDisplays()
    }

    func move(app: AppId, to display: DisplayId) {
        do {
            let result = try moveAppWindows.execute(app: app, destination: display)
            logger.info("moved \(result.moved); skipped \(result.skipped.count)")
        } catch {
            logger.error("move failed: \(String(describing: error))")
        }
    }
}
