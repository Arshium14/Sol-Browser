import ImageIO
import SwiftUI

/// A Space's chosen wallpaper, drawn full-bleed behind its windows with the
/// blur the person set over it. The image decodes once per choice, so a drag
/// of the blur never re-reads the photo.
struct BrowserSpaceWallpaper: View {
    let spaceID: UUID?
    @State private var image: CGImage?

    private var appearance: BrowserDeviceAppearanceStore { .shared }
    private var data: Data? { spaceID.flatMap { appearance.spaceWallpapers[$0] } }

    var body: some View {
        content
            .task(id: data) { image = data.flatMap(BrowserSpaceWallpaperImage.decode) }
    }

    @ViewBuilder
    private var content: some View {
        if let spaceID, let image {
            Image(decorative: image, scale: 1, orientation: .up)
                .resizable()
                .scaledToFill()
                .blur(radius: appearance.spaceWallpaperBlur[spaceID] ?? 0)
                .overlay { CrestColor.windowBackground.opacity(0.2) }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        }
    }
}

/// Reading and writing wallpaper pixels without either platform's image
/// class, so the backdrop and its settings share one path.
enum BrowserSpaceWallpaperImage {
    /// The stored image drawn down to a wallpaper's worth of pixels.
    static func decode(_ data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 2048,
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }

    static func png(_ image: CGImage) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, "public.png" as CFString, 1, nil)
        else { return nil }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}
