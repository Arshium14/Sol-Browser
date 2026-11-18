import SwiftUI

/// Crest's mark on its tile, as square as the space it is given allows,
/// under a rim one device pixel wide, so the rim stays even at every size
/// and display scale.
struct CrestStartPageMark: View {
    var body: some View {
        Image("SolPreview")
            .resizable()
            .scaledToFit()
            .clipShape(.rect(cornerRadius: 16))
            .accessibilityHidden(true)
    }
}
