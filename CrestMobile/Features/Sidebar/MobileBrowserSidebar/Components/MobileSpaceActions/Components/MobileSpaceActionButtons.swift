import SwiftUI

/// The Space's own controls, laid out by whoever holds them: the floating
/// capsule, or the system toolbar where the controls move out of the chrome.
struct MobileSpaceActionButtons: View {
    /// Which of the Space's controls a holder draws: the whole run, the run
    /// without the archive, or the archive alone beside the Space switcher.
    enum Subset {
        case all, withoutArchive, archiveOnly
    }

    let browser: BrowserStore
    let pages: MobileBrowserPageStore
    let utilityPresentationStyle: MobileBrowserSidebarUtilityPresentationStyle
    let configuration: MobileSpaceActionsConfiguration
    var subset: Subset = .all

    var body: some View {
        if subset != .archiveOnly {
            privateBrowsingButton
        }
        if subset != .withoutArchive {
            archiveButton
        }
        if utilityPresentationStyle == .sheet, subset != .archiveOnly {
            downloadsButton
        }
        if subset != .archiveOnly {
            settingsButton
        }
    }

    /// The controls as items of a system toolbar at `placement`, each folding
    /// into the bar's overflow menu at its own rank as the bar runs out of room.
    @ToolbarContentBuilder
    func toolbarItems(placement: ToolbarItemPlacement) -> some ToolbarContent {
        ToolbarItem(placement: placement) { privateBrowsingButton }
            .collapsing(at: .privateBrowsing)
        ToolbarItem(placement: placement) { archiveButton }
            .collapsing(at: .commonLists)
        if utilityPresentationStyle == .sheet {
            ToolbarItem(placement: placement) { downloadsButton }
                .collapsing(at: .downloads)
        }
        ToolbarItem(placement: placement) { settingsButton }
            .collapsing(at: .settings)
    }

    private var privateBrowsingButton: some View {
        MobileSpacePrivateBrowsingButton(
            isPrivateBrowsing: browser.isPrivateBrowsing,
            accentColor: selectedAccentColor,
            action: configuration.togglePrivateBrowsing
        )
    }

    private var archiveButton: some View {
        MobileSpaceArchiveButton(
            utilityPresentationStyle: utilityPresentationStyle,
            archivedTabCount: browser.shownSpace?.archive.entries.count ?? 0,
            commonListsAreExpanded: configuration.commonListsAreExpanded,
            downloads: downloads,
            newDownloads: newDownloads,
            badgeColor: downloadBadgeColor,
            showArchive: configuration.showArchive,
            toggleCommonLists: configuration.toggleCommonLists,
            recordCommonListsTriggerFrame: configuration.recordCommonListsTriggerFrame
        )
    }

    private var downloadsButton: some View {
        MobileSpaceDownloadsButton(
            downloads: downloads,
            newDownloads: newDownloads,
            badgeColor: downloadBadgeColor,
            action: configuration.showDownloads
        )
    }

    private var settingsButton: some View {
        MobileSpaceSettingsButton(action: configuration.showSettings)
    }

    private var downloads: [DownloadState] {
        guard let profileID = browser.shownSpace?.profileID else { return [] }
        return pages.downloadCenter.items(for: profileID)
    }

    private var newDownloads: [DownloadState] {
        guard let profileID = browser.shownSpace?.profileID else { return [] }
        return pages.downloadCenter.unacknowledgedItems(for: profileID)
    }

    private var selectedAccentColor: Color {
        browser.shownSpace.map(\.settings.look)?.colors.first?.color ?? .accentColor
    }

    private var downloadBadgeColor: Color {
        downloads.badgeTint(otherwise: selectedAccentColor)
    }
}
