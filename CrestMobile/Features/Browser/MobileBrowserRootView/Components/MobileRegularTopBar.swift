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
    var toggleSplit: () -> Void = {}
    @State private var barWidth: CGFloat = 0

    private var capabilities: BrowserInteractionCapabilities {
        BrowserInteractionCapabilities(supportsHover: true, supportsTouch: true)
    }

    var body: some View {
        barContent
            .labelStyle(.iconOnly)
            .onGeometryChange(for: CGFloat.self, of: \.size.width) { barWidth = $0 }
            .padding(.horizontal, BrowserSidebarMetrics.layerInset)
            .padding(.vertical, 3)
            // The band rides in the status bar's own strip, so the chrome
            // costs the page nothing above it; the controls keep clear of the
            // clock and the battery the system draws at either corner.
            .padding(.leading, 52)
            .padding(.trailing, 68)
            .ignoresSafeArea(.container, edges: .top)
            .modifier(
                SpaceForegroundBlend(
                    spaces: browser.availableSpaces,
                    selectedSpaceID: browser.shownSpace?.id)
            )
            // The bar stands over the Space gradient the window draws, so its
            // surfaces wear translucent fills over it, as the sidebar's do.
            .environment(\.sidebarTranslucentSurfaces, true)
    }

    /// A window wide enough to fill the screen centers the field over the
    /// page, clear of both clusters; a narrower one, as Split View leaves,
    /// lets the field fill the gap between them instead.
    @ViewBuilder
    private var barContent: some View {
        if barWidth >= 700 {
            ZStack {
                HStack(spacing: 8) {
                    sidebarToggle
                    splitToggle
                    navigationControls
                    Spacer(minLength: 0)
                    pageActionsMenu
                }
                addressField
                    .frame(maxWidth: min(centeredFieldWidth, barWidth - 520))
            }
        } else {
            HStack(spacing: 8) {
                sidebarToggle
                splitToggle
                navigationControls
                addressField
                    .frame(maxWidth: .infinity)
                pageActionsMenu
            }
        }
    }

    private var centeredFieldWidth: CGFloat {
        BrowserDeviceAppearanceStore.shared.compactAddressBar ? 400 : 520
    }

    private var splitToggle: some View {
        Button(action: toggleSplit) {
            Image(systemName: "rectangle.split.2x1")
                .font(.system(size: 15, weight: .regular))
        }
        .buttonStyle(CrestChromeButtonStyle())
        .accessibilityLabel("Split View")
        .accessibilityIdentifier("browser-split-toggle")
    }

    private var sidebarToggle: some View {
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
    }

    private var navigationControls: some View {
        BrowserSidebarNavigationControls(
            port: navigationPort,
            capabilities: capabilities,
            besideWindowControls: false
        )
        .frame(width: 180)
    }

    private var addressField: some View {
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
            branding: browser.shownSpace.map(\.settings.look),
            metricsOverride: BrowserDeviceAppearanceStore.shared.compactAddressBar
                ? .topBarCompact : .topBar
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
