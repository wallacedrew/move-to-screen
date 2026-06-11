/// Maps a window's frame from a source display onto a destination display,
/// preserving the window's proportional position. Window size is kept;
/// the position is clamped to keep the window within the destination bounds.
///
/// Driven by microtests in RelativePositionTests.
public func relativePosition(
    window: Frame,
    sourceDisplay: Frame,
    destinationDisplay: Frame
) -> Frame {
    let x = project(
        window: window.xSegment,
        source: sourceDisplay.xSegment,
        destination: destinationDisplay.xSegment
    )
    let y = project(
        window: window.ySegment,
        source: sourceDisplay.ySegment,
        destination: destinationDisplay.ySegment
    )
    return Frame(x: x.origin, y: y.origin, width: x.extent, height: y.extent)
}

private func project(
    window: Segment,
    source: Segment,
    destination: Segment
) -> Segment {
    let relative = (window.origin - source.origin) / source.extent
    let proportional = destination.origin + relative * destination.extent
    let extent = min(window.extent, destination.extent)
    let maxOrigin = destination.origin + destination.extent - extent
    let clamped = max(destination.origin, min(proportional, maxOrigin))
    return Segment(origin: clamped, extent: extent)
}
