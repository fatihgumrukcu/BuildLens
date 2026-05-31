import Foundation
import Observation

// @MainActor: all published state mutations happen on the main thread.
// Heavy work (shell probes, directory walks) escapes via Task.detached inside the services.
@Observable
@MainActor
final class DashboardViewModel {
    var summary   = DashboardSummary()
    var isLoading = false
    var loadError: String?

    private let fileSystem: FileSystemServiceProtocol
    private let shell: ShellServiceProtocol

    init(
        fileSystem: FileSystemServiceProtocol,
        shell: ShellServiceProtocol
    ) {
        self.fileSystem = fileSystem
        self.shell = shell
    }

    @MainActor
    convenience init() {
        self.init(fileSystem: FileSystemService(), shell: ShellService())
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        // All four probes run concurrently via async let
        async let tools      = scanEnvironmentTools()
        async let derivedData = fileSystem.size(at: FileSystemService.derivedDataPath)
        async let npmCache    = fileSystem.size(at: FileSystemService.npmCachePath)
        async let gradleCache = fileSystem.size(at: FileSystemService.gradleCachePath)

        let (resolvedTools, dd, npm, gc) = await (tools, derivedData, npmCache, gradleCache)

        summary = DashboardSummary(
            environmentTools: resolvedTools,
            derivedDataSize:   dd,
            npmCacheSize:      npm,
            gradleCacheSize:   gc,
            isLoaded: true
        )
    }

    func reload() async {
        summary = DashboardSummary()
        await load()
    }

    // MARK: - Private

    private func scanEnvironmentTools() async -> [EnvironmentTool] {
        // (name, version-command) pairs — order here becomes the sorted fallback
        let toolDefs: [(String, String)] = [
            ("Xcode",       "xcode-select -p"),
            ("Node.js",     "node --version"),
            ("npm",         "npm --version"),
            ("Yarn",        "yarn --version"),
            ("pnpm",        "pnpm --version"),
            ("CocoaPods",   "pod --version"),
            ("Watchman",    "watchman --version"),
            ("Java",        "java -version 2>&1 | head -1"),
            ("Fastlane",    "fastlane --version | head -1"),
            ("Ruby",        "ruby --version"),
        ]

        let shell = self.shell
        return await withTaskGroup(of: EnvironmentTool.self, returning: [EnvironmentTool].self) { group in
            for (name, command) in toolDefs {
                group.addTask {
                    do {
                        let raw = try await shell.run(command)
                        let version = raw
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .components(separatedBy: .newlines).first ?? raw
                        return EnvironmentTool(
                            id: name,
                            name: name,
                            status: .installed,
                            version: version.isEmpty ? nil : String(version.prefix(80))
                        )
                    } catch {
                        return EnvironmentTool(id: name, name: name, status: .missing, version: nil)
                    }
                }
            }

            var results: [EnvironmentTool] = []
            for await tool in group { results.append(tool) }
            return results.sorted { $0.name < $1.name }
        }
    }
}
