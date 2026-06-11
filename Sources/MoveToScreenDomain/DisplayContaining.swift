/// Returns the connected display whose frame contains the centre of
/// the given window frame, or nil if no display does (e.g. a window
/// hidden off-screen after a display disconnect).
///
/// Used by MoveAppWindowsToDisplay to identify each window's source
/// display so it can compute a proportional destination frame.
public func displayContaining(frame: Frame, in displays: [DisplayInfo]) -> DisplayInfo? {
    let centreX = frame.origin.x + frame.size.width / 2
    let centreY = frame.origin.y + frame.size.height / 2
    return displays.first { display in
        let f = display.frame
        let withinX = centreX >= f.origin.x && centreX < f.origin.x + f.size.width
        let withinY = centreY >= f.origin.y && centreY < f.origin.y + f.size.height
        return withinX && withinY
    }
}
