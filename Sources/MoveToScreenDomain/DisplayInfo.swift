public struct DisplayInfo: Hashable, Sendable {
    public let id: DisplayId
    public let name: String
    public let frame: Frame

    public init(id: DisplayId, name: String, frame: Frame) {
        self.id = id
        self.name = name
        self.frame = frame
    }
}
