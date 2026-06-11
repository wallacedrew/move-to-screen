import MoveToScreenDomain
import MoveToScreenPorts

/// In-memory `AccessibilityClient` for use-case tests. Stages a fixed
/// app + window scene and records every mutating call so tests can
/// assert what the use case did (and in what order).
public final class InMemoryAccessibilityClient: AccessibilityClient {

    public var appsWithEligibleWindows: [AppDescription] = []
    public var windowsByApp: [AppId: [WindowSnapshot]] = [:]
    public var grantedPermission: Bool = true
    public var moveErrorByWindow: [WindowId: Error] = [:]
    public var unminimizeErrorByWindow: [WindowId: Error] = [:]

    public private(set) var moveCalls: [MoveCall] = []
    public private(set) var unminimizeCalls: [WindowId] = []

    public struct MoveCall: Hashable {
        public let window: WindowId
        public let frame: Frame

        public init(window: WindowId, frame: Frame) {
            self.window = window
            self.frame = frame
        }
    }

    public init() {}

    public func runningAppsWithEligibleWindows() throws -> [AppDescription] {
        return appsWithEligibleWindows
    }

    public func windows(for app: AppId) throws -> [WindowSnapshot] {
        return windowsByApp[app] ?? []
    }

    public func move(window: WindowId, to frame: Frame) throws {
        if let error = moveErrorByWindow[window] {
            throw error
        }
        moveCalls.append(MoveCall(window: window, frame: frame))
    }

    public func unminimize(window: WindowId) throws {
        if let error = unminimizeErrorByWindow[window] {
            throw error
        }
        unminimizeCalls.append(window)
    }

    public func isAccessibilityGranted() -> Bool {
        return grantedPermission
    }
}
