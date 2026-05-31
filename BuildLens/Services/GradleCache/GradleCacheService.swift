import Foundation

final class GradleCacheService: GradleCacheServiceProtocol, Sendable {

    private let fileSystem: FileSystemService
    static let gradleHome = "\(NSHomeDirectory())/.gradle"

    init(fileSystem: FileSystemService = FileSystemService()) {
        self.fileSystem = fileSystem
    }

    // MARK: - Public API

    func scanEntries() async throws -> [GradleCacheEntry] {
        // wrapper/dists is scanned instead of wrapper/ — each dist is one Gradle version.
        let scanTargets: [(GradleCacheCategory, String)] = [
            (.caches,  "\(Self.gradleHome)/caches"),
            (.wrapper, "\(Self.gradleHome)/wrapper/dists"),
            (.daemon,  "\(Self.gradleHome)/daemon"),
            (.native,  "\(Self.gradleHome)/native"),
            (.jdks,    "\(Self.gradleHome)/jdks"),
        ]

        return await withTaskGroup(of: [GradleCacheEntry].self, returning: [GradleCacheEntry].self) { group in
            for (category, path) in scanTargets {
                group.addTask { await self.scanCategory(category, at: URL(fileURLWithPath: path)) }
            }
            var all: [GradleCacheEntry] = []
            for await entries in group { all.append(contentsOf: entries) }
            return all.sorted { $0.size > $1.size }
        }
    }

    // MARK: - Category Scanner

    private func scanCategory(_ category: GradleCacheCategory, at url: URL) async -> [GradleCacheEntry] {
        let fm = FileManager()
        guard fm.fileExists(atPath: url.path) else { return [] }

        let subdirs = (try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
            options: .skipsHiddenFiles
        ))?.filter {
            (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        } ?? []

        // No subdirectories → treat the whole path as a single entry.
        if subdirs.isEmpty {
            return await singleEntry(at: url, category: category)
        }

        return await withTaskGroup(of: GradleCacheEntry?.self, returning: [GradleCacheEntry].self) { group in
            for dir in subdirs {
                group.addTask { await self.analyzeEntry(at: dir, category: category) }
            }
            var results: [GradleCacheEntry] = []
            for await entry in group {
                if let e = entry { results.append(e) }
            }
            return results
        }
    }

    // MARK: - Entry Analysis

    private func analyzeEntry(at url: URL, category: GradleCacheCategory) async -> GradleCacheEntry? {
        let size = await fileSystem.size(at: url.path)
        guard size > 0 else { return nil }
        let modDate = modificationDate(of: url)
        return GradleCacheEntry(
            id: url, path: url, category: category,
            size: size, lastModifiedDate: modDate
        )
    }

    private func singleEntry(at url: URL, category: GradleCacheCategory) async -> [GradleCacheEntry] {
        let size = await fileSystem.size(at: url.path)
        guard size > 0 else { return [] }
        let modDate = modificationDate(of: url)
        return [GradleCacheEntry(
            id: url, path: url, category: category,
            size: size, lastModifiedDate: modDate
        )]
    }

    private func modificationDate(of url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate)
            ?? Date.distantPast
    }
}
