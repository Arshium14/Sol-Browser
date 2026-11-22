import SwiftUI
import UIKit

/// The charge readout that stands where a desktop shell's window buttons
/// would: the one status an iPad window has no other home for.
struct MobileTopBarBatteryIndicator: View {
    @State private var level = UIDevice.current.batteryLevel
    @State private var state = UIDevice.current.batteryState

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: symbol)
            Text(percent)
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(.secondary)
        .monospacedDigit()
        .accessibilityLabel("Battery \(Text(percent))")
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            level = UIDevice.current.batteryLevel
            state = UIDevice.current.batteryState
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)
        ) { _ in
            level = UIDevice.current.batteryLevel
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)
        ) { _ in
            state = UIDevice.current.batteryState
        }
    }

    private var percent: String {
        level < 0 ? "--%" : "\(Int((level * 100).rounded()))%"
    }

    private var symbol: String {
        let base: String
        switch Int((level * 100).rounded()) {
        case ..<10: base = "battery.0"
        case ..<35: base = "battery.25"
        case ..<65: base = "battery.50"
        case ..<95: base = "battery.75"
        default: base = "battery.100"
        }
        guard state == .charging || state == .full else { return base }
        return "\(base).bolt"
    }
}
