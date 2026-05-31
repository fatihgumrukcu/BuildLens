import Foundation

final class CleanupService: CleanupServiceProtocol, Sendable {

    private let fileSystem: FileSystemService
    private let validator: CleanupValidator

    init(
        fileSystem: FileSystemService = FileSystemService(),
        validator: CleanupValidator = CleanupValidator()
    ) {
        self.fileSystem = fileSystem
        self.validator = validator
    }

    func buildPreview() async throws -> CleanupPreview {
        async let derivedData = scanDerivedData()
        async let simulators  = scanSimulators()
        async let archives    = scanArchives()
        async let cocoapods   = scanSingle(path: FileSystemService.cocoapodsCachePath, category: .cocoapods, name: "CocoaPods Cache")
        async let metro       = scanSingle(path: FileSystemService.metroCachePath,     category: .metroCache, name: "Metro Cache")
        async let gradle      = scanSingle(path: FileSystemService.gradleCachePath,    category: .gradleCache, name: "Gradle Caches")
        async let watchman    = scanSingle(path: FileSystemService.watchmanCachePath,  category: .watchman,   name: "Watchman State")

        let all = try await derivedData + simulators + archives + cocoapods + metro + gradle + watchman
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

    // Xcode names DerivedData folders "ProjectName-<20+ char hash>"; strip the hash for display.
    private func strippedProjectName(from rawName: String) -> String {
        let parts = rawName.components(separatedBy: "-")
        guard parts.count >= 2, let last = parts.last else { return rawName }
        let isHash = last.count >= 20 && last.allSatisfy { $0.isLowercase || $0.isNumber }
        return isHash ? parts.dropLast().joined(separator: "-") : rawName
    }
}
