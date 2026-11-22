import PhotosUI
import SwiftUI

/// One Space's wallpaper: the image behind its windows and how far it is
/// blurred. Both stay on this device, never in the Space's own record.
struct BrowserSpaceWallpaperSection: View {
    let space: SpaceModel
    @State private var selection: PhotosPickerItem?
    @State private var preview: CGImage?

    private var appearance: BrowserDeviceAppearanceStore { .shared }
    private var data: Data? { appearance.spaceWallpapers[space.id] }

    var body: some View {
        let resettable = CrestResettableSetting(title: "Wallpaper", isDefault: data == nil) {
            appearance.spaceWallpapers[space.id] = nil
            appearance.spaceWallpaperBlur[space.id] = nil
        }
        CrestSettingsGroup("Wallpaper", settings: [resettable]) {
            HStack(spacing: BrowserAppearancePreviewMetrics.spacing) {
                thumbnail
                PhotosPicker("Choose Image", selection: $selection, matching: .images)
            }
            .frame(maxWidth: .infinity)
            if data != nil {
                CrestSettingSlider(
                    "Blur",
                    value: CrestSettingValue(blurFraction, default: 0),
                    readout: .percent(zero: "Sharp", full: "Soft")
                )
            }
        }
        .onChange(of: selection) { _, item in
            guard let item else { return }
            Task { await adopt(item) }
        }
        .task(id: data) { preview = data.flatMap(BrowserSpaceWallpaperImage.decode) }
    }

    private var blurFraction: Binding<Double> {
        Binding(
            get: { (appearance.spaceWallpaperBlur[space.id] ?? 0) / 30 },
            set: { appearance.spaceWallpaperBlur[space.id] = $0 * 30 }
        )
    }

    private var thumbnail: some View {
        Group {
            if let preview {
                Image(decorative: preview, scale: 1, orientation: .up)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 18, weight: .medium))
            }
        }
        .foregroundStyle(.primary)
        .frame(width: 64, height: 44)
        .background(
            Color.primary.opacity(0.08),
            in: RoundedRectangle(cornerRadius: CrestRadius.compact, style: .continuous)
        )
        .clipShape(RoundedRectangle(cornerRadius: CrestRadius.compact, style: .continuous))
    }

    /// Stores the chosen image drawn down to a wallpaper's worth of pixels,
    /// so a photo from the library never sits in the defaults at full size.
    private func adopt(_ item: PhotosPickerItem) async {
        guard let raw = try? await item.loadTransferable(type: Data.self),
            let image = BrowserSpaceWallpaperImage.decode(raw),
            let png = BrowserSpaceWallpaperImage.png(image)
        else { return }
        appearance.spaceWallpapers[space.id] = png
        selection = nil
    }
}
