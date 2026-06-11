/// One-dimensional slice of a Frame along a single axis. `origin` is the
/// leading edge along that axis; `extent` is the length. Used by the
/// placement math so x and y can be projected by the same algorithm
/// instead of two hand-unrolled copies.
public struct Segment: Hashable, Sendable {
    public let origin: Double
    public let extent: Double

    public init(origin: Double, extent: Double) {
        self.origin = origin
        self.extent = extent
    }
}

extension Frame {
    public var xSegment: Segment {
        Segment(origin: origin.x, extent: size.width)
    }

    public var ySegment: Segment {
        Segment(origin: origin.y, extent: size.height)
    }
}
