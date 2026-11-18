import SwiftUI

struct BrowserPlatformAppIconSettingsSection: View {
    var body: some View {
        CrestSettingsGroup("App icon") {
            HStack(spacing: 16) {
                BrowserPlatformAppIcon(name: nil)
                    .frame(width: 58, height: 58)
                    .clipShape(.rect(cornerRadius: 13))
                Text(ProductIdentity.name)
                    .font(.body.weight(.medium))
            }
            .padding(.vertical, 8)
        }
    }
}
