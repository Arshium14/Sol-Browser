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
                        Image(systemName: CloudSyncConfiguration.configured(in: .main) == nil ? "icloud.slash" : "icloud.fill")
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

    private var bringTitle: LocalizedStringKey {
        if CloudSyncConfiguration.configured(in: .main) == nil {
            return "Set up Spaces on this device"
        }
        return "Bring tabs in with Crest on your Mac"
    }

    private var bringBody: LocalizedStringKey {
        if CloudSyncConfiguration.configured(in: .main) == nil {
            return "This build does not sync with iCloud, so tabs cannot come over from a Mac. Make and name Spaces here instead."
        }
        return "A Mac can read the browsers installed on it. Bring their Spaces and tabs into Crest there, and iCloud brings them here."
    }
}

enum MobileSetupBringPageMetrics {
    static let symbolSize: CGFloat = 36
}
