import Foundation

final class MetroCacheService: MetroCacheServiceProtocol, Sendable {

    private let fileSystem: FileSystemService

    init(fileSystem: FileSystemService = FileSystemService()) {
        self.fileSystem = fileSystem
    }

    // MARK: - Public API

    func scanEntries() async throws -> [MetroCacheEntry] {
        async let main = scanMainCache()
        async let tmp  = scanTemporaryLocations()
        let (mainEntries, tmpEntries) = await (main, tmp)

        var seen = Set<URL>()
        let all = (mainEntries + tmpEntries).filter { seen.insert($0.path).inserted }
        return all.sorted { $0.size > $1.size }
    }

    // MARK: - Main Cache (~Library/Caches/Metro)

    private func scanMainCache() async -> [MetroCacheEntry] {
        let cacheURL = URL(fileURLWithPath: FileSystemService.metroCachePath)
        let fm = FileManager()
        guard fm.fileExists(atPath: cacheURL.path) else { return [] }

        // List top-level subdirectories — each is an independent cache bucket.
        let subdirs = (try? fm.contentsOfDirectory(
            at: cacheURL,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ))?.filter {
            (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        } ?? []

        // Flat cache (no subdirs) → treat the whole cache dir as one entry.
        if subdirs.isEmpty {
            return await singleEntry(at: cacheURL, source: .mainCache)
        }

        return await withTaskGroup(of: MetroCacheEntry?.self, returning: [MetroCacheEntry].self) { group in
            for dir in subdirs {
                group.addTask { await self.analyzeEntry(at: dir, source: .mainCache) }
            }
            var results: [MetroCacheEntry] = []
            for await entry in group {
                if let e = entry { results.append(e) }
            }
            return results
        }
    }

    // MARK: - Temporary Locations (/tmp and user-temp)

    // Scans /tmp and the user's NSTemporaryDirectory for Metro-tagged artifacts.
    // Uses FileManager.default.temporaryDirectory to resolve the user's
    // /private/var/folders/…/T/ path without scanning the full var/folders tree.
    private func scanTemporaryLocations() async -> [MetroCacheEntry] {
        let locations: [URL] = [
            URL(fileURLWithPath: "/tmp"),
            FileManager.default.temporaryDirectory,
        ]

        return await withTaskGroup(of: [MetroCacheEntry].self, returning: [MetroCacheEntry].self) { group in
            for location in locations {
                group.addTask { await self.scanTmpDirectory(location) }
            }
            var all: [MetroCacheEntry] = []
            for await entries in group { all.append(contentsOf: entries) }
            return all
        }
    }

    private func scanTmpDirectory(_ url: URL) async -> [MetroCacheEntry] {
        await Task.detached(priority: .utility) {
            let fm = FileManager()
            guard let items = try? fm.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
                options: [.skipsHiddenFiles]
            ) else { return [] }

            let candidates = items.filter {
                let n = $0.lastPathComponent.lowercased()
                return n.hasPrefix("metro") || n.hasPrefix("react-native-packager-cache")
            }

            var results: [MetroCacheEntry] = []
            for candidate in candidates {
                let fm2 = FileManager()
                let size = (try? fm2.allocatedSizeOfDirectory(at: candidate)) ?? 0
                guard size > 0 else { continue }
                let modDate = (try? candidate
                    .resourceValues(forKeys: [.contentModificationDateKey])
                    .contentModificationDate) ?? Date.distantPast
                results.append(MetroCacheEntry(
                    id: candidate,
                    path: candidate,
                    size: size,
                    lastModifiedDate: modDate,
                    source: .tmpArtifact
                ))
            }
            return results
        }.value
    }

    // MARK: - Helpers

    private func analyzeEntry(at url: URL, source: MetroCacheSource) async -> MetroCacheEntry? {
        let size = await fileSystem.size(at: url.path)
        guard size > 0 else { return nil }
        let modDate = (try? url
            .resourceValues(forKeys: [.contentModificationDateKey])
            .contentModificationDate) ?? Date.distantPast
        return MetroCacheEntry(id: url, path: url, size: size, lastModifiedDate: modDate, source: source)
    }

    private func singleEntry(at url: URL, source: MetroCacheSource) async -> [MetroCacheEntry] {
        guard let entry = await analyzeEntry(at: url, source: source) else { return [] }
        return [entry]
    }
}
