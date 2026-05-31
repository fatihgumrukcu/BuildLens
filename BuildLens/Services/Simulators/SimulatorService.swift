import Foundation

final class SimulatorService: SimulatorServiceProtocol, Sendable {

    private let shell: ShellServiceProtocol
    private let fileSystem: FileSystemServiceProtocol

    init(
        shell: ShellServiceProtocol = ShellService(),
        fileSystem: FileSystemServiceProtocol = FileSystemService()
    ) {
        self.shell = shell
        self.fileSystem = fileSystem
    }

    func fetchRuntimes() async throws -> [SimulatorRuntime] {
        // Both simctl commands run concurrently — neither waits for the other.
        async let devicesOutput  = shell.run("xcrun simctl list devices --json")
        async let runtimesOutput = shell.run("xcrun simctl list runtimes --json")
        let (rawDevices, rawRuntimes) = try await (devicesOutput, runtimesOutput)

        guard let devicesData  = rawDevices.data(using: .utf8),
              let runtimesData = rawRuntimes.data(using: .utf8) else {
            throw SimulatorError.invalidOutput
        }

        let decoder = JSONDecoder()
        let devicesResponse  = try decoder.decode(SimctlDevicesResponse.self,  from: devicesData)
        let runtimesResponse = try decoder.decode(SimctlRuntimesResponse.self, from: runtimesData)

        let runtimeLookup = Dictionary(
            uniqueKeysWithValues: runtimesResponse.runtimes.map { ($0.identifier, $0) }
        )

        return await buildRuntimes(from: devicesResponse.devices, runtimeLookup: runtimeLookup)
    }

    // MARK: - Private: assembly

    private func buildRuntimes(
        from devicesByRuntime: [String: [SimctlDevice]],
        runtimeLookup: [String: SimctlRuntime]
    ) async -> [SimulatorRuntime] {

        // Flatten once so the TaskGroup has a flat list to iterate.
        let pairs: [(runtimeId: String, raw: SimctlDevice)] = devicesByRuntime.flatMap { id, devices in
            devices.map { (runtimeId: id, raw: $0) }
        }

        // Resolve storage size for every device in parallel.
        // Strategy: use dataPathSize from simctl when present (instant, no I/O).
        // Fall back to FileSystemService for available devices with unknown size.
        let fileSystem = self.fileSystem
        typealias SizeEntry = (udid: String, size: Int64, lastBootedAt: Date?)

        let entries: [SizeEntry] = await withTaskGroup(of: SizeEntry.self, returning: [SizeEntry].self) { group in
            for pair in pairs {
                let raw = pair.raw
                group.addTask {
                    var size = raw.dataPathSize ?? 0
                    if size == 0, raw.isAvailable, let dataPath = raw.dataPath {
                        size = await fileSystem.size(at: dataPath)
                    }
                    return await (udid: raw.udid, size: size, lastBootedAt: Self.parseISO8601(raw.lastBootedAt))
                }
            }
            var acc: [SizeEntry] = []
            for await entry in group { acc.append(entry) }
            return acc
        }

        let sizeMap = Dictionary(uniqueKeysWithValues: entries.map { ($0.udid, ($0.size, $0.lastBootedAt)) })

        // Build domain models
        var runtimes: [SimulatorRuntime] = []
        for (runtimeId, rawDevices) in devicesByRuntime {
            let info = runtimeLookup[runtimeId]

            let devices: [SimulatorDevice] = rawDevices
                .map { raw in
                    let (size, date) = sizeMap[raw.udid] ?? (0, nil)
                    return SimulatorDevice(
                        id:                   raw.udid,
                        udid:                 raw.udid,
                        name:                 raw.name,
                        runtimeIdentifier:    runtimeId,
                        runtimeVersion:       info?.version ?? Self.versionFromIdentifier(runtimeId),
                        deviceTypeIdentifier: raw.deviceTypeIdentifier,
                        state:                .init(raw: raw.state),
                        isAvailable:          raw.isAvailable,
                        dataPath:             raw.dataPath,
                        storageSize:          size,
                        lastBootedAt:         date
                    )
                }
                .sorted { $0.name < $1.name }

            runtimes.append(SimulatorRuntime(
                id:          runtimeId,
                identifier:  runtimeId,
                displayName: info?.name ?? Self.displayNameFromIdentifier(runtimeId),
                version:     info?.version ?? "",
                isAvailable: info?.isAvailable ?? false,
                devices:     devices
            ))
        }

        // Newest iOS version first, then alphabetical for other platforms
        return runtimes
            .filter { !$0.devices.isEmpty }
            .sorted { $0.displayName > $1.displayName }
    }

    // MARK: - Private: helpers

    // Handles "2024-03-15T12:00:00.000Z" and "2024-03-15T12:00:00Z"
    private static func parseISO8601(_ string: String?) -> Date? {
        guard let string else { return nil }
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: string) { return d }
        f.formatOptions = .withInternetDateTime
        return f.date(from: string)
    }

    // "com.apple.CoreSimulator.SimRuntime.iOS-17-5" → "iOS 17.5"
    private static func displayNameFromIdentifier(_ id: String) -> String {
        guard let last = id.components(separatedBy: ".").last else { return id }
        let parts = last.components(separatedBy: "-")
        guard parts.count >= 2 else { return last }
        return "\(parts[0]) \(parts.dropFirst().joined(separator: "."))"
    }

    // "com.apple.CoreSimulator.SimRuntime.iOS-17-5" → "17.5"
    private static func versionFromIdentifier(_ id: String) -> String {
        guard let last = id.components(separatedBy: ".").last else { return "" }
        let parts = last.components(separatedBy: "-")
        guard parts.count >= 2 else { return "" }
        return parts.dropFirst().joined(separator: ".")
    }
}

// MARK: - Errors

enum SimulatorError: LocalizedError {
    case invalidOutput
    case simctlUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidOutput:      return "Could not parse simulator data from Xcode tools"
        case .simctlUnavailable:  return "xcrun simctl not found — is Xcode installed and selected?"
        }
    }
}

// MARK: - Raw Codable types (private — never leave this file)

private struct SimctlDevicesResponse: Decodable {
    let devices: [String: [SimctlDevice]]
}

private struct SimctlDevice: Decodable {
    let udid: String
    let name: String
    let state: String
    let isAvailable: Bool
    let deviceTypeIdentifier: String
    let dataPath: String?
    let dataPathSize: Int64?
    let lastBootedAt: String?
}

private struct SimctlRuntimesResponse: Decodable {
    let runtimes: [SimctlRuntime]
}

private struct SimctlRuntime: Decodable {
    let identifier: String
    let name: String
    let version: String
    let isAvailable: Bool
    let platform: String?
}
