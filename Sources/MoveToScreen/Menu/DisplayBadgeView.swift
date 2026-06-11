import SwiftUI

/// The display-identifier badge. Clinical brutalism: only #000 and #fff,
/// Arial Black 900 for chrome, hard 6px border, zero radius, no shadow,
/// no material, no gradient. Hierarchy comes from scale.
struct DisplayBadgeView: View {

    let displayName: String

    var body: some View {
        Text(displayName.uppercased())
            .font(.custom("Arial Black", size: 120))
            .foregroundStyle(Color.black)
            .lineLimit(1)
            .minimumScaleFactor(0.35)
            .padding(.horizontal, 56)
            .padding(.vertical, 40)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .strokeBorder(Color.black, lineWidth: 6)
            )
    }
}
