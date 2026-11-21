import PhotosUI
import SwiftUI
import UIKit

/// The image wearing the button that opens a page's actions, in place of the
/// system's ellipsis: a mark of the person's own, the way Arc's logo wears
/// theirs. The Mac twin offers nothing: its chrome draws the system glyph.
struct BrowserPlatformMenuIconSettingsSection: View {
    private var appearance: BrowserDeviceAppearanceStore { .shared }
    @State private var selection: PhotosPickerItem?

    var body: some View {
        let resettable = CrestResettableSetting(title: "Menu Icon", isDefault: appearance.menuIcon == nil) {
            appearance.menuIcon = nil
        }
        CrestSettingsGroup("Menu Icon", settings: [resettable]) {
            HStack(spacing: BrowserAppearancePreviewMetrics.spacing) {
                preview
                PhotosPicker("Choose Image", selection: $selection, matching: .images)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("menu-icon")
        }
        .onChange(of: selection) { _, item in
            guard let item else { return }
            Task { await adopt(item) }
        }
    }

    private var preview: some View {
        Group {
            if let data = appearance.menuIcon, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
            } else {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20, weight: .semibold))
            }
        }
        .foregroundStyle(.primary)
        .frame(width: 44, height: 44)
        .background(
            Color.primary.opacity(0.08),
            in: RoundedRectangle(cornerRadius: CrestRadius.compact, style: .continuous)
        )
    }

    /// Stores the chosen image drawn down to a glyph's worth of pixels, so a
    /// photo from the library never sits in the defaults at full size.
    private func adopt(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
            let image = UIImage(data: data)
        else { return }
        let side = max(image.size.width, image.size.height)
        guard side > 0 else { return }
        let scale = min(1, 192 / side)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let drawn = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        appearance.menuIcon = drawn.pngData()
        selection = nil
    }
}
