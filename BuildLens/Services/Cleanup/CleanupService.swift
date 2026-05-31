import Foundation

final class CleanupService: CleanupServiceProtocol, Sendable {

    private let fileSystem: FileSystemService
    private let validator: CleanupValidator
    private let shell: any ShellServiceProtocol

    init(
        fileSystem: FileSystemService = FileSystemService(),
        validator: CleanupValidator = CleanupValidator(),
        shell: any ShellServiceProtocol = ShellService()
    ) {
        self.fileSystem = fileSystem
        self.validator = validator
        self.shell = shell
    }

    func buildPreview() async throws -> CleanupPreview {
        async let derivedData    = scanDerivedData()
        async let simulators     = scanSimulators()
        async let archives       = scanArchives()
        async let androidOutputs = scanAndroidBuildOutputs()
        async let cocoapods      = scanSingle(path: FileSystemService.cocoapodsCachePath, category: .cocoapods, name: "CocoaPods Cache")
        async let metro          = scanSingle(path: FileSystemService.metroCachePath,     category: .metroCache, name: "Metro Cache")
        async let gradle         = scanSingle(path: FileSystemService.gradleCachePath,    category: .gradleCache, name: "Gradle Caches")
        async let watchman       = scanSingle(path: FileSystemService.watchmanCachePath,  category: .watchman,   name: "Watchman State")

        let all = try await derivedData + simulators + archives + androidOutputs + cocoapods + metro + gradle + watchman
        return CleanupPreview(items: all, scannedAt: Date())
    }

    func executeCleanup(items: [CleanupItem]) async throws -> CleanupResult {
        var deleted: [CleanupItem] = []
        var failed: [(item: CleanupItem, error: String)] = []
        var freed: Int64 = 0

        await withTaskGroup(of: (CleanupItem, Result<Void, Error>).self) { group in
            for item in items {
                group.addTask {
                    do {
                        try await self.validator.validate(item.url)
                        try FileManager().removeItem(at: item.url)
                        return (item, .success(()))
                    } catch {
                        return (item, .failure(error))
                    }
                }
            }
            for await (item, result) in group {
                switch result {
                case .success:
                    deleted.append(item)
                    freed += item.size
                case .failure(let error):
                    failed.append((item: item, error: error.localizedDescription))
                }
            }
        }

        return CleanupResult(
            deletedItems: deleted,
            failedItems: failed,
            freedBytes: freed,
            completedAt: Date()
        )
    }

    // MARK: - Private Scanners

    private func scanDerivedData() async throws -> [CleanupItem] {
        let dirs = try await fileSystem.scanDirectory(at: FileSystemService.derivedDataPath)
        return dirs.map { dir in
            CleanupItem(
                category: .derivedData,
                url: dir.url,
                name: strippedProjectName(from: dir.name),
                size: dir.size,
                riskLevel: .safe
            )
        }
    }

    private func scanSimulators() async throws -> [CleanupItem] {
        let dirs = try await fileSystem.scanDirectory(at: FileSystemService.simulatorsPath)
        return dirs.map { dir in
            CleanupItem(
                category: .simulators,
                url: dir.url,
                name: dir.name,
                size: dir.size,
                detail: "Simulator Device",
                riskLevel: .moderate,
                isSelected: false
            )
        }
    }

    private func scanArchives() async throws -> [CleanupItem] {
        // Archives sit under year subdirectories; scan one level deeper
        let yearDirs = try await fileSystem.scanDirectory(at: FileSystemService.xcodeArchivesPath)
        var results: [CleanupItem] = []
        for yearDir in yearDirs {
            let inner = try await fileSystem.scanDirectory(at: yearDir.url.path)
            let items = inner.map { dir in
                CleanupItem(
                    category: .archives,
                    url: dir.url,
                    name: dir.name,
                    size: dir.size,
                    detail: yearDir.name,
                    riskLevel: .caution,
                    isSelected: false
                )
            }
            results.append(contentsOf: items)
        }
        return results
    }

    private func scanSingle(path: String, category: CleanupCategory, name: String) async -> [CleanupItem] {
        guard fileSystem.exists(at: path) else { return [] }
        let size = await fileSystem.size(at: path)
        guard size > 0 else { return [] }
        return [CleanupItem(
            category: category,
            url: URL(fileURLWithPath: path),
            name: name,
            size: size
        )]
    }

    // Scans common project parent directories for Android app/build/ folders and reports
    // outputs/ and intermediates/ as separate CleanupItems. Uses `find` for reliability
    // across arbitrary project layouts; errors are silently swallowed so a missing dir
    // or permission error never blocks the rest of the scan.
    private func scanAndroidBuildOutputs() async -> [CleanupItem] {
        let home = NSHomeDirectory()
        let candidates = [
            "\(home)/Documents", "\(home)/Desktop", "\(home)/Developer",
            "\(home)/Projects",  "\(home)/Code",    "\(home)/Workspace",
            "\(home)/repos",     "\(home)/src",     "\(home)/GitHub",
        ]
        let quotedExisting = candidates
            .filter { fileSystem.exists(at: $0) }
            .map { "\"\($0)\"" }
            .joined(separator: " ")
        guard !quotedExisting.isEmpty else { return [] }

        let cmd = "find \(quotedExisting) -maxdepth 6 -type d -name 'build' -path '*/android/app/build' 2>/dev/null | head -40"
        guard let raw = try? await shell.run(cmd) else { return [] }

        let buildPaths = raw
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        var results: [CleanupItem] = []
        for buildPath in buildPaths {
            let projectURL = URL(fileURLWithPath: buildPath)
                .deletingLastPathComponent()   // app
                .deletingLastPathComponent()   // android
                .deletingLastPathComponent()   // project root
            let projectName = projectURL.lastPathComponent

            let subfolders: [(path: String, label: String, detail: String)] = [
                ("\(buildPath)/outputs",       "\(projectName) – Build Outputs",       "APKs, AABs, native .so libraries"),
                ("\(buildPath)/intermediates", "\(projectName) – Build Intermediates", "Compiled classes, dex, object files"),
            ]
            for sub in subfolders {
                guard fileSystem.exists(at: sub.path) else { continue }
                let size = await fileSystem.size(at: sub.path)
                guard size > 0 else { continue }
                results.append(CleanupItem(
                    category: .androidBuildOutputs,
                    url: URL(fileURLWithPath: sub.path),
                    name: sub.label,
                    size: size,
                    detail: sub.detail,
                    riskLevel: .safe
                ))
            }
        }
        return results
    }

    // Xcode names DerivedData folders "ProjectName-<20+ char hash>"; strip the hash for display.
    private func strippedProjectName(from rawName: String) -> String {
        let parts = rawName.components(separatedBy: "-")
        guard parts.count >= 2, let last = parts.last else { return rawName }
        let isHash = last.count >= 20 && last.allSatisfy { $0.isLowercase || $0.isNumber }
        return isHash ? parts.dropLast().joined(separator: "-") : rawName
    }
}
