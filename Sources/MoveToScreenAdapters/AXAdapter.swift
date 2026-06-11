import AppKit
import ApplicationServices
import CoreGraphics
import MoveToScreenDomain
import MoveToScreenPorts

/// Real `AccessibilityClient`, backed by `AXUIElement` for window
/// queries / mutations and `NSRunningApplication` for the running-app
/// list. All AX bridging goes through `AXBoundary` so this file stays
/// focused on orchestration.
public final class AXAdapter: AccessibilityClient {

    public init() {}

    // MARK: - Permission

    public func isAccessibilityGranted() -> Bool {
        return AXIsProcessTrusted()
    }

    // MARK: - Reads

    public func runningAppsWithEligibleWindows() throws -> [AppDescription] {
        let onScreenIds = currentSpaceWindowIds()
        let regularApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }

        var descriptions: [AppDescription] = []
        for runningApp in regularApps {
            let appId = AppId(rawValue: runningApp.processIdentifier)
            let windows = (try? snapshots(for: appId, onScreenIds: onScreenIds)) ?? []
            if windows.contains(where: isEligible) {
                descriptions.append(makeDescription(runningApp))
            }
        }
        return descriptions
    }

    public func windows(for app: AppId) throws -> [WindowSnapshot] {
        return try snapshots(for: app, onScreenIds: currentSpaceWindowIds())
    }

    // MARK: - Mutations

    public func move(window: WindowId, to frame: Frame) throws {
        guard let (element, _) = try locate(window) else {
            throw AXAdapterError.unexpectedShape(attribute: "window-not-found")
        }
        try AXBoundary.writePosition(element, CGPoint(x: frame.origin.x, y: frame.origin.y))
        try AXBoundary.writeSize(element, CGSize(width: frame.size.width, height: frame.size.height))
    }

    public func unminimize(window: WindowId) throws {
        guard let (element, _) = try locate(window) else {
            throw AXAdapterError.unexpectedShape(attribute: "window-not-found")
        }
        try AXBoundary.writeMinimized(element, false)
    }

    // MARK: - Private

    private func snapshots(for app: AppId, onScreenIds: Set<CGWindowID>) throws -> [WindowSnapshot] {
        let application = AXUIElementCreateApplication(pid_t(app.rawValue))
        let elements = (try? AXBoundary.readWindows(application)) ?? []
        return elements.compactMap { element in
            try? parse(element, ownerApp: app, onScreenIds: onScreenIds)
        }
    }

    private func parse(
        _ element: AXUIElement,
        ownerApp: AppId,
        onScreenIds: Set<CGWindowID>
    ) throws -> WindowSnapshot {
        let windowId = try AXBoundary.readWindowId(element)
        let position = try AXBoundary.readPosition(element)
        let size = try AXBoundary.readSize(element)
        let isMinimized = AXBoundary.readBool(element, kAXMinimizedAttribute as String)
        // `AXFullScreen` is not in the public CoreServices headers but has been
        // the de-facto attribute name since macOS 10.11; standard in Yabai, Rectangle.
        let isFullscreen = AXBoundary.readBool(element, "AXFullScreen")
        let isOnCurrentSpace = isMinimized || onScreenIds.contains(windowId.rawValue)
        return WindowSnapshot(
            id: windowId,
            ownerApp: ownerApp,
            frame: Frame(
                x: Double(position.x),
                y: Double(position.y),
                width: Double(size.width),
                height: Double(size.height)
            ),
            isMinimized: isMinimized,
            isFullscreen: isFullscreen,
            isOnCurrentSpace: isOnCurrentSpace
        )
    }

    private func locate(_ windowId: WindowId) throws -> (AXUIElement, AppId)? {
        for runningApp in NSWorkspace.shared.runningApplications
        where runningApp.activationPolicy == .regular {
            let appId = AppId(rawValue: runningApp.processIdentifier)
            let application = AXUIElementCreateApplication(pid_t(runningApp.processIdentifier))
            let elements = (try? AXBoundary.readWindows(application)) ?? []
            for element in elements {
                if (try? AXBoundary.readWindowId(element)) == windowId {
                    return (element, appId)
                }
            }
        }
        return nil
    }

    private func currentSpaceWindowIds() -> Set<CGWindowID> {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let info = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]]
        else { return [] }
        let ids = info.compactMap { entry -> CGWindowID? in
            guard let raw = entry[kCGWindowNumber as String] as? NSNumber else { return nil }
            return CGWindowID(raw.uint32Value)
        }
        return Set(ids)
    }

    private func makeDescription(_ app: NSRunningApplication) -> AppDescription {
        return AppDescription(
            id: AppId(rawValue: app.processIdentifier),
            displayName: app.localizedName ?? "Unknown",
            bundleIdentifier: app.bundleIdentifier
        )
    }
}
