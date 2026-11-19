import SwiftUI

struct MobileBrowserSidebarLayout: View {
    let configuration: MobileBrowserSidebarContentConfiguration

    var body: some View {
        // The sidebar composites its layers as one card, so its tiles and
        // field stand on translucent fills over the Space gradient rather
        // than on a material that cannot sample it.
        chrome.environment(\.sidebarTranslucentSurfaces, true)
    }

    private var chrome: some View {
        MobileBrowserSidebarBottomChromeLayout(configuration: configuration) {
            MobileBrowserSidebarPager(configuration: configuration)
        }
    }
}
