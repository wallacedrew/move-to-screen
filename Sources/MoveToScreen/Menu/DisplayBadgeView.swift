import SwiftUI

/// The dumb badge content rendered inside the floating identification
/// panel. Just text, no logic.
struct DisplayBadgeView: View {

    let displayName: String

    var body: some View {
        Text(displayName)
            .font(.system(size: 144, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 112)
            .padding(.vertical, 72)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 56, style: .continuous))
            .shadow(color: .black.opacity(0.35), radius: 36, x: 0, y: 12)
    }
}
