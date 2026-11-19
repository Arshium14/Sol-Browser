import SwiftUI

/// Appearance only; selection, promotion and drag owners remain on the row.
struct BrowserTabAppearanceSurface: ViewModifier {
    let appearance: BrowserTabAppearance
    let accent: Color
    let isPinned: Bool
    let isSelected: Bool
    let isHovering: Bool
    var selectionEmphasis = false
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.sidebarLayerDepth) private var depth
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.sidebarTranslucentSurfaces) private var translucentSurfaces

    func body(content: Content) -> some View {
        let radius = BrowserSidebarMetrics.layerCornerRadius(depth: depth)
        let selectedAccent = appearance.outlinesSelectedTabs
        let showsBorder = appearance.borders == .all || (isPinned && appearance.borders == .pinned)
        // Each choice is read only where it shows, so a drag of the pin fill
        // or the hover tint re-renders the pins or the hovered row alone.
        let fill = isPinned ? BrowserTabAppearance.intensity(appearance.pinFill) : 0
        let hover = isHovering ? BrowserTabAppearance.intensity(appearance.hoverFill) : 0
        let highContrast = reduceTransparency || contrast == .increased
        let selectedBorder: Color = highContrast ? .primary : (selectedAccent ? accent : .clear)
        content
            .modifier(
                CrestInteractiveSurfaceModifier(
                    isSelected: isSelected, selectionEmphasis: selectionEmphasis,
                    isHovering: isHovering, cornerRadius: radius, isPressed: false,
                    showsRestingSurface: isPinned,
                    selectedBorderColor: selectedBorder,
                    selectedBorderWidth: isPinned ? CrestLayout.pinnedAccentBorderWidth : 1,
                    customSelectedFill: reduceTransparency
                        ? nil
                        : (isPinned && fill > 0 ? accent.opacity(fill * 0.5) : selectionLift),
                    // Hover keeps its standard weight; the setting only decides how much of
                    // the accent is in it, from the neutral hover to the accent itself.
                    customHoverFill: hover > 0 && !reduceTransparency
                        ? Color.primary.mix(with: accent, by: hover).opacity(CrestOpacity.hover) : nil,
                    customRestingFill: isPinned && !reduceTransparency
                        ? (fill > 0 ? accent.opacity(fill * 0.2) : restingWhite)
                        : nil,
                    restingBorderColor: showsBorder ? accent : .clear)
            )
            .background {
                if isSelected, appearance.pinGlow > 0, !reduceTransparency {
                    BrowserTabSelectionGlow(
                        cornerRadius: radius,
                        color: accent.opacity(BrowserTabAppearance.intensity(appearance.pinGlow) * 0.6)
                    )
                }
            }
    }

    private var selectionLift: Color {
        Color.white.opacity(colorScheme == .dark ? 0.16 : 0.62)
    }

    /// Over the Space gradient alone the tile needs a touch more lift than
    /// over the device's material, which already lightens it.
    private var restingWhite: Color {
        Color.white.opacity(
            colorScheme == .dark
                ? (translucentSurfaces ? 0.12 : 0.08)
                : (translucentSurfaces ? 0.3 : 0.24))
    }
}
