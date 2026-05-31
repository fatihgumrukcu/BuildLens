import Foundation

struct SimulatorSummary: Sendable {
    let totalDevices: Int
    let unavailableDevices: Int
    let totalStorageUsage: Int64
    let activeRuntimeCount: Int
    let runningDeviceCount: Int

    static let empty = SimulatorSummary(
        totalDevices: 0,
        unavailableDevices: 0,
        totalStorageUsage: 0,
        activeRuntimeCount: 0,
        runningDeviceCount: 0
    )
}
