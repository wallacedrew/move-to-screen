/// Identity of a running application.
/// Wraps the OS process id (`pid_t`); modeled as `Int32` so the Domain
/// layer stays free of Darwin/POSIX imports.
public struct AppId: Hashable, Sendable {
    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
}
