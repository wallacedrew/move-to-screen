/// Display-facing record for a running app. Identity is `AppId`;
/// the rest is for rendering in the menu (Apps with displayName, sorted, etc.).
public struct AppDescription: Hashable, Sendable {
    public let id: AppId
    public let displayName: String
    public let bundleIdentifier: String?

    public init(id: AppId, displayName: String, bundleIdentifier: String?) {
        self.id = id
        self.displayName = displayName
        self.bundleIdentifier = bundleIdentifier
    }
}
