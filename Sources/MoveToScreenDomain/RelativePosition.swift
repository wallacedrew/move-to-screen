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
    let relativeX = (window.origin.x - sourceDisplay.origin.x) / sourceDisplay.size.width
    let newX = destinationDisplay.origin.x + relativeX * destinationDisplay.size.width
    return Frame(
        x: newX,
        y: window.origin.y,
        width: window.size.width,
        height: window.size.height
    )
}
