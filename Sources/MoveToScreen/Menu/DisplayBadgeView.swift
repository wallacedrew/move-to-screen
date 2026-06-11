import SwiftUI

/// The dumb badge content rendered inside the floating identification
/// panel. Just text, no logic.
struct DisplayBadgeView: View {

    let displayName: String

    var body: some View {
        Text(displayName)
            .font(.system(size: 72, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 56)
            .padding(.vertical, 36)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 6)
    }
}
