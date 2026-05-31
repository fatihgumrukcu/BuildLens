import Foundation

final class FileSystemService: FileSystemServiceProtocol, Sendable {

    // Canonical developer paths. All features reference these — no magic strings in feature code.
    static let derivedDataPath       = "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData"
    static let simulatorsPath        = "\(NSHomeDirectory())/Library/Developer/CoreSimulator/Devices"
    static let xcodeArchivesPath     = "\(NSHomeDirectory())/Library/Developer/Xcode/Archives"
    static let cocoapodsCachePath    = "\(NSHomeDirectory())/Library/Caches/CocoaPods"
    static let metroCachePath        = "\(NSHomeDirectory())/Library/Caches/Metro"
    static let npmCachePath          = "\(NSHomeDirectory())/.npm"
    static let gradleCachePath        = "\(NSHomeDirectory())/.gradle/caches"
    static let watchmanCachePath      = "\(NSHomeDirectory())/Library/Caches/com.github.facebook.watchman"

    func size(at path: String) async -> Int64 {
        await Task.detached(priority: .utility) {
            let url = URL(fileURLWithPath: path)
            // Use a local FileManager instance — not .default — for thread safety
            let fm = FileManager()
            return await (try? fm.allocatedSizeOfDirectory(at: url)) ?? 0
        }.value
    }

    func exists(at path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }

    func contents(of directory: String) async throws -> [URL] {
        let url = URL(fileURLWithPath: directory)
        return try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .creationDateKey, .isDirectoryKey],
            options: .skipsHiddenFiles
        )
    }

    // Scans one directory level. Each child's size is calculated concurrently via TaskGroup —
    // no main-thread blocking, and N entries get N parallel directory walks on the thread pool.
    func scanDirectory(at path: String) async throws -> [DirectoryItem] {
        let url = URL(fileURLWithPath: path)
        let fm = FileManager()

        guard fm.fileExists(atPath: path) else { return [] }

        let subdirectories = try fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
            options: .skipsHiddenFiles
        )
        .filter {
            (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        }

        return await withTaskGroup(of: DirectoryItem.self, returning: [DirectoryItem].self) { group in
            for entryURL in subdirectories {
                group.addTask {
                    let localFm = FileManager()
                    let size = await (try? localFm.allocatedSizeOfDirectory(at: entryURL)) ?? 0
                    let modDate = (try? entryURL
                        .resourceValues(forKeys: [.contentModificationDateKey])
                        .contentModificationDate) ?? Date.distantPast
                    return DirectoryItem(
                        id: entryURL,
                        url: entryURL,
                        name: entryURL.lastPathComponent,
                        size: size,
                        lastModified: modDate
                    )
                }
            }
            var results: [DirectoryItem] = []
            for await item in group { results.append(item) }
            return results
        }
    }
}

extension FileManager {
    // Walks an entire directory tree and sums allocated (on-disk) file sizes.
    func allocatedSizeOfDirectory(at url: URL) throws -> Int64 {
        let resourceKeys: Set<URLResourceKey> = [.totalFileAllocatedSizeKey, .isDirectoryKey]
        guard let enumerator = enumerator(
            at: url,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [],
            errorHandler: nil
        ) else { return 0 }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: resourceKeys)
            if values.isDirectory == false {
                total += Int64(values.totalFileAllocatedSize ?? 0)
            }
        }
        return total
    }
}
