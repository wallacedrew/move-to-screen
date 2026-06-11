import MoveToScreenDomain
import MoveToScreenPorts

/// In-memory `DisplayClient` for use-case tests. Returns a fixed list
/// of `DisplayInfo` set up by the test.
public final class InMemoryDisplayClient: DisplayClient {

    public var displays: [DisplayInfo]

    public init(displays: [DisplayInfo] = []) {
        self.displays = displays
    }

    public func connectedDisplays() -> [DisplayInfo] {
        return displays
    }
}
