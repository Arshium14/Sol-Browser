import SwiftUI

struct MobileBrowserSidebarChrome: View {
    @Environment(BrowserSidebarInteractionState.self) private var sidebarInteraction

    let configuration: MobileBrowserSidebarContentConfiguration

    var body: some View {
        BrowserSpaceSwitcher(
            browser: configuration.context.browser,
            downloadCenter: configuration.context.pageAccess.downloadCenter,
            capabilities: configuration.context.capabilities,
            selectSpace: configuration.context.selectSpace
        )
        .modifier(
            SpaceForegroundBlend(
                spaces: configuration.context.availableSpaces,
                selectedSpaceID: configuration.context.browser.shownSpace?.id)
        )
        // The picker needs its own system drop feed for cross-Space tab drops.
        .modifier(
            MobileBrowserReorderDropFeed(
                browser: configuration.context.browser,
                spaceAccess: configuration.context.spaceAccess
            )
        )
        .overlay(alignment: configuration.utilityPresentationStyle == .inline ? .top : .bottom) {
            if let message = sidebarInteraction.sidebarReorderState.constraintMessage {
                Label(message, systemImage: "nosign")
                    .font(CrestTypography.metadata)
                    .padding(CrestSpacing.small)
                    .frame(maxWidth: 280, alignment: .leading)
                    .background {
                        CrestSurfaceLayer(shape: .rect(cornerRadius: BrowserSidebarMetrics.layerCornerRadius(depth: 0)))
                    }
                    .alignmentGuide(.bottom) { $0[.top] - CrestSpacing.small }
                    .alignmentGuide(.top) { $0[.bottom] + CrestSpacing.small }
                    .allowsHitTesting(false)
            }
        }
    }
}
