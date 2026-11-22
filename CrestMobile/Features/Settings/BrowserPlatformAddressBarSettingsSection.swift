import SwiftUI

/// Where the tablet shows a page's address, as one preview button for each
/// place: in the sidebar, or in a bar across the window's top. The phone keeps
/// the address where its compact layout puts it, so it offers no choice.
struct BrowserPlatformAddressBarSettingsSection: View {
    // MARK: - Variables

    @Bindable private var appearance = BrowserDeviceAppearanceStore.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            picker
        }
    }

    private var picker: some View {
        let placement = CrestSettingValue(
            $appearance.addressBarPlacement, default: BrowserLookAndFeelDefaults.addressBarPlacement)
        let resettable = CrestResettableSetting(title: "Address bar", isDefault: placement.isDefault) {
            choose(BrowserLookAndFeelDefaults.addressBarPlacement)
        }
        return CrestSettingsGroup("Address bar", settings: [resettable]) {
            HStack(alignment: .top, spacing: BrowserAppearancePreviewMetrics.spacing) {
                ForEach(BrowserAddressBarPlacement.all) { candidate in
                    CrestPreviewButton(
                        title: Text(candidate.title), isSelected: candidate == appearance.addressBarPlacement,
                        previewSize: BrowserAppearancePreviewMetrics.previewSize
                    ) {
                        choose(candidate)
                    } preview: {
                        BrowserOnboardingWindowPreview(
                            branding: look.previewBranding, symbol: look.previewSymbol,
                            name: String(localized: "Personal"),
                            spaceIcons: appearance.spaceIcons,
                            companionLook: look,
                            addressBarPlacement: candidate
                        ) {
                            EmptyView()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("address-bar-placement")
            Picker("Size", selection: $appearance.compactAddressBar) {
                Text("Large").tag(false)
                Text("Small").tag(true)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("address-bar-size")
        }
    }

    /// The look both previews wear: a house's, as a new Space's is.
    private var look: SetupLook { .heraldic }

    // MARK: - Actions - Choice

    private func choose(_ placement: BrowserAddressBarPlacement) {
        withAnimation(CrestMotion.chrome.unlessReducingMotion(reduceMotion)) {
            appearance.addressBarPlacement = placement
        }
    }
}
