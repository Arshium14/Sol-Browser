import SwiftUI

struct BrowserCommandPaletteShellMaterial: ViewModifier {
    let shape: RoundedRectangle
    let reduceTransparency: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if reduceTransparency {
            content.background(.background, in: shape)
        } else {
            content
                .background(.regularMaterial, in: shape)
                .overlay { shape.strokeBorder(.primary.opacity(0.08), lineWidth: 0.5) }
                .shadow(color: .black.opacity(0.18), radius: 28, y: 12)
        }
    }
}
