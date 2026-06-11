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
    let relativeY = (window.origin.y - sourceDisplay.origin.y) / sourceDisplay.size.height
    let proportionalX = destinationDisplay.origin.x + relativeX * destinationDisplay.size.width
    let proportionalY = destinationDisplay.origin.y + relativeY * destinationDisplay.size.height
    let maxX = destinationDisplay.origin.x + destinationDisplay.size.width - window.size.width
    let maxY = destinationDisplay.origin.y + destinationDisplay.size.height - window.size.height
    let clampedX = min(proportionalX, maxX)
    let clampedY = min(proportionalY, maxY)
    return Frame(
        x: clampedX,
        y: clampedY,
        width: window.size.width,
        height: window.size.height
    )
}
