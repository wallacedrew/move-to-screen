/// Outcome of a MoveAppWindowsToDisplay run. `moved` is how many windows
/// were repositioned; `skipped` records the windows that were intentionally
/// or unintentionally left untouched.
public struct MoveResult: Hashable, Sendable {
    public let moved: Int
    public let skipped: [SkipReason]

    public init(moved: Int, skipped: [SkipReason]) {
        self.moved = moved
        self.skipped = skipped
    }
}
