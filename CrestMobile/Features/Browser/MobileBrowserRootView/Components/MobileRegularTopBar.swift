import SwiftUI

/// The regular shell's address bar across the window's top, as Arc and Zen
/// offer it: navigation at the leading end, the address field centered, and
/// the page's actions at the trailing end. The sidebar leaves out its own
/// navigation strip and address field while this stands.
struct MobileRegularTopBar: View {
    let browser: BrowserStore
    let pages: MobileBrowserPageStore
    let spaceAccess: BrowserSpaceAccessController
    @Binding var address: String
    @Binding var isAddressEditing: Bool
    let activateAddress: (() -> Void)?
    let submitAddress: () -> Void
    let compactChromeNamespace: Namespace.ID
    let commandPaletteHandoff: BrowserCommandPaletteHandoff
    let showHistory: () -> Void
    let toggleSidebar: () -> Void
    let showSettings: () -> Void
    let togglePrivateBrowsing: () -> Void

    private var capabilities: BrowserInteractionCapabilities {
        BrowserInteractionCapabilities(supportsHover: true, supportsTouch: true)
    }

    var body: some View {
        HStack(spacing: 8) {
            Button(action: toggleSidebar) {
                Image(
                    systemName: BrowserDeviceAppearanceStore.shared.sidebarOnRight
                        ? "sidebar.right" : "sidebar.left"
                )
                .font(.system(size: 17, weight: .regular))
            }
            .buttonStyle(CrestChromeButtonStyle())
            .accessibilityLabel("Hide Sidebar")
            .accessibilityIdentifier("browser-sidebar-toggle")

            BrowserSidebarNavigationControls(
                port: navigationPort,
                capabilities: capabilities,
                besideWindowControls: false
            )
            .frame(width: 180)

            BrowserSidebarAddressField(
                configuration: addressConfiguration,
                fieldContextMenu: {
                    if let pageActions = selectedPageActions,
                        pageActions.isAvailable,
                        !isAddressEditing
                    {
                        MobilePageActionsContent(
                            browser: browser,
                            pages: pageActions,
                            showSettings: showSettings,
                            togglePrivateBrowsing: togglePrivateBrowsing
                        )
                        .tint(.primary)
                    }
                }
            )
            .modifier(SurfaceToneAppearance())
            .frame(maxWidth: .infinity)

            pageActionsMenu
        }
        .labelStyle(.iconOnly)
        .padding(.horizontal, BrowserSidebarMetrics.layerInset)
        .padding(.vertical, 6)
        .modifier(
            SpaceForegroundBlend(
                spaces: browser.availableSpaces,
                selectedSpaceID: browser.shownSpace?.id)
        )
        // The bar stands over the Space gradient the window draws, so its
        // surfaces wear translucent fills over it, as the sidebar's do.
        .environment(\.sidebarTranslucentSurfaces, true)
    }

    @ViewBuilder
    private var pageActionsMenu: some View {
        if let pageActions = selectedPageActions, pageActions.isAvailable {
            MobilePageActionsMenu(
                browser: browser,
                pages: pageActions,
                systemImage: "ellipsis.circle",
                isToolbarItem: false,
                showSettings: showSettings,
                togglePrivateBrowsing: togglePrivateBrowsing
            )
            .font(.system(size: 17, weight: .medium))
        } else {
            Button(action: {}) {
                BrowserPageActionsMenuIcon()
            }
            .accessibilityLabel("Page Actions")
            .disabled(true)
            .font(.system(size: 17, weight: .medium))
        }
    }

    private var navigationPort: BrowserSidebarNavigationPort {
        BrowserSidebarNavigationPort(pageActions: selectedPageActions, showHistory: showHistory)
    }

    private var addressConfiguration: BrowserSidebarAddressFieldConfiguration {
        BrowserSidebarAddressFieldConfiguration(
            text: $address,
            isEditing: $isAddressEditing,
            isSecure: displayedURL?.scheme?.lowercased() == "https",
            progress: selectedPageActions?.activePage?.estimatedProgress ?? 0,
            isLoading: selectedPageActions?.activePage?.live.isLoading == true,
            hasResidentPage: false,
            capabilities: capabilities,
            activate: activateAddress,
            submit: submitAddress,
            morphNamespace: compactChromeNamespace,
            spaceID: selectedSpaceID,
            spaceHasAddress: spaceHasAddress,
            commandPaletteHandoff: commandPaletteHandoff,
            branding: browser.shownSpace.map(\.settings.look)
        )
    }

    private var selectedPageActions: MobileSelectedPageActionPort? {
        MobileSelectedPageActionPort(browser: browser, pages: pages, spaceAccess: spaceAccess)
    }

    private var spaceHasAddress: Bool {
        guard let tabID = browser.selectedTabID(in: selectedSpaceID) else { return false }
        return browser.spaceModel(selectedSpaceID)?.shownTab(tabID)?.url?.isEmpty == false
    }

    private var displayedURL: URL? {
        selectedPageActions?.activeURL
            ?? browser.shownTab?.url.flatMap(URL.init(string:))
    }

    private var selectedSpaceID: UUID {
        browser.selectedSpaceID
    }
}
