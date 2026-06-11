import SwiftUI

/// The display-identifier badge. Clinical brutalism: only #000 and #fff,
/// Arial Black 900 for chrome, hard 6px border, zero radius, no shadow,
/// no material, no gradient. Hierarchy comes from scale.
struct DisplayBadgeView: View {

    let displayName: String
    let maxWidth: CGFloat

    private static let horizontalPadding: CGFloat = 56
    private static let verticalPadding: CGFloat = 40

    var body: some View {
        Text(displayName.uppercased())
            .font(.custom("Arial Black", size: 120))
            .foregroundStyle(Color.black)
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .frame(width: maxWidth - Self.horizontalPadding * 2, alignment: .center)
            .padding(.horizontal, Self.horizontalPadding)
            .padding(.vertical, Self.verticalPadding)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .strokeBorder(Color.black, lineWidth: 6)
            )
    }
}
