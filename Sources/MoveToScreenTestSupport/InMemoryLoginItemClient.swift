import MoveToScreenPorts

/// In-memory `LoginItemClient` for ATDD tests. Records register and
/// unregister calls in order so tests can assert what the menu toggle
/// actually requested.
public final class InMemoryLoginItemClient: LoginItemClient {

    public enum Call: Hashable {
        case register
        case unregister
    }

    public private(set) var enabled: Bool
    public private(set) var recordedCalls: [Call] = []
    public var registerError: Error?
    public var unregisterError: Error?

    public init(enabled: Bool = false) {
        self.enabled = enabled
    }

    public func isEnabled() -> Bool {
        return enabled
    }

    public func register() throws {
        if let registerError {
            throw registerError
        }
        recordedCalls.append(.register)
        enabled = true
    }

    public func unregister() throws {
        if let unregisterError {
            throw unregisterError
        }
        recordedCalls.append(.unregister)
        enabled = false
    }
}
