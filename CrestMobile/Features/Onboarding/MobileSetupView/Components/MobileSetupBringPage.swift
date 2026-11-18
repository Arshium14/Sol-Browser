import SwiftUI

/// Bringing tabs on iPhone and iPad, which cannot read other browsers: Crest
/// on a Mac brings them in, and iCloud brings the Spaces here.
struct MobileSetupBringPage: View {
    // MARK: - Actions - Drawing

    var body: some View {
        Form {
            Section {
                VStack(spacing: CrestSpacing.large) {
                    HStack(spacing: CrestSpacing.large) {
                        Image(systemName: "laptopcomputer")
                        Image(systemName: cloudSymbol)
                            .foregroundStyle(.tint)
                        Image(systemName: "iphone")
                    }
                    .font(.system(size: MobileSetupBringPageMetrics.symbolSize, weight: .light))
                    .accessibilityHidden(true)
                    Text(bringTitle)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                    Text(bringBody)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, CrestSpacing.medium)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("setup-bring-on-mac")
            } footer: {
                Text("You can still make and name Spaces on this device.")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private var cloudSymbol: String {
        BrowserCloudSyncConfiguration.configured(in: .main) == nil ? "icloud.slash" : "icloud.fill"
    }

    private var bringTitle: LocalizedStringKey {
        if BrowserCloudSyncConfiguration.configured(in: .main) == nil {
            return "Set up Spaces on this device"
        }
        return "Bring tabs in with Crest on your Mac"
    }

    private var bringBody: LocalizedStringKey {
        if BrowserCloudSyncConfiguration.configured(in: .main) == nil {
            return "This build does not sync with iCloud. Make and name Spaces on this device instead."
        }
        return "Bring Spaces and tabs into Crest on your Mac, and iCloud brings them here."
    }
}

enum MobileSetupBringPageMetrics {
    static let symbolSize: CGFloat = 36
}
