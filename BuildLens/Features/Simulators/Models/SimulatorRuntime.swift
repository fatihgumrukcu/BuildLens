import Foundation

struct SimulatorRuntime: Identifiable, Hashable, Sendable {
    let id: String              // = identifier
    let identifier: String      // e.g. "com.apple.CoreSimulator.SimRuntime.iOS-17-5"
    let displayName: String     // e.g. "iOS 17.5"
    let version: String         // e.g. "17.5"
    let isAvailable: Bool
    let devices: [SimulatorDevice]

    // MARK: - Derived

    var deviceCount: Int              { devices.count }
    var unavailableDeviceCount: Int   { devices.filter { !$0.isAvailable }.count }
    var runningDeviceCount: Int       { devices.filter { $0.state.isRunning }.count }
    var totalStorageUsage: Int64      { devices.reduce(0) { $0 + $1.storageSize } }

    // Human-readable health summary shown in section header
    var healthSummary: String {
        if !isAvailable            { return "Runtime unavailable" }
        if unavailableDeviceCount > 0 { return "\(unavailableDeviceCount) unavailable" }
        if runningDeviceCount > 0  { return "\(runningDeviceCount) running" }
        return "All shutdown"
    }
}
