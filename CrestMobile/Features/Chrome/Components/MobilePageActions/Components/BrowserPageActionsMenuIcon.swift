import SwiftUI
import UIKit

/// The page actions menu's glyph: an image the person chose in Settings, or
/// the system's ellipsis where they chose none.
struct BrowserPageActionsMenuIcon: View {
    var systemImage: String = "ellipsis.circle"

    var body: some View {
        if let custom = customImage {
            Image(uiImage: custom)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
        } else {
            Image(systemName: systemImage)
        }
    }

    private var customImage: UIImage? {
        BrowserDeviceAppearanceStore.shared.menuIcon.flatMap(UIImage.init(data:))
    }
}
