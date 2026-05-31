import Foundation

struct SimulatorDevice: Identifiable, Hashable, Sendable {
    let id: String              // = udid
    let udid: String
    let name: String
    let runtimeIdentifier: String
    let runtimeVersion: String
    let deviceTypeIdentifier: String
    let state: DeviceState
    let isAvailable: Bool
    let dataPath: String?
    let storageSize: Int64
    let lastBootedAt: Date?

    // MARK: - Device state

    enum DeviceState: String, Hashable, Sendable {
        case booted       = "Booted"
        case shutdown     = "Shutdown"
        case creating     = "Creating"
        case shuttingDown = "Shutting Down"
        case unknown

        init(raw: String) {
            self = DeviceState(rawValue: raw) ?? .unknown
        }

        var isRunning: Bool { self == .booted }

        var displayLabel: String {
            switch self {
            case .booted:       return "Running"
            case .shutdown:     return "Shutdown"
            case .creating:     return "Creating"
            case .shuttingDown: return "Shutting Down"
            case .unknown:      return "Unknown"
            }
        }
    }

    // MARK: - Display helpers

    // Maps CoreSimulator device type identifiers to SF Symbols.
    // Identifier format: "com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro"
    var symbolName: String {
        let lower = deviceTypeIdentifier.lowercased()
        if lower.contains("iphone")             { return "iphone" }
        if lower.contains("ipad")               { return "ipad" }
        if lower.contains("appletv")            { return "tv" }
        if lower.contains("watch")              { return "applewatch" }
        if lower.contains("vision") || lower.contains("xr") { return "visionpro" }
        return "desktopcomputer"
    }
}
