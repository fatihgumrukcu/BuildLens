import Foundation

final class ArchivesService: ArchivesServiceProtocol, Sendable {

    private let fileSystem: FileSystemService

    init(fileSystem: FileSystemService = FileSystemService()) {
        self.fileSystem = fileSystem
    }

    // MARK: - Public API

    func scanArchives() async throws -> [ArchiveItem] {
        let root = URL(fileURLWithPath: FileSystemService.xcodeArchivesPath)
        let fm = FileManager()
        guard fm.fileExists(atPath: root.path) else { return [] }

        let dateDirs = (try? fm.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: .skipsHiddenFiles
        ))?.filter {
            (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        } ?? []

        return await withTaskGroup(of: [ArchiveItem].self, returning: [ArchiveItem].self) { group in
            for dateDir in dateDirs {
                group.addTask { await self.scanDateGroup(dateDir) }
            }
            var all: [ArchiveItem] = []
            for await batch in group { all.append(contentsOf: batch) }
            return all.sorted { $0.creationDate > $1.creationDate }
        }
    }

    // MARK: - Date Group Scanner

    private func scanDateGroup(_ dateDir: URL) async -> [ArchiveItem] {
        let fm = FileManager()
        let archives = (try? fm.contentsOfDirectory(
            at: dateDir,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
            options: .skipsHiddenFiles
        ))?.filter { $0.pathExtension == "xcarchive" } ?? []

        return await withTaskGroup(of: ArchiveItem?.self, returning: [ArchiveItem].self) { group in
            for archiveURL in archives {
                group.addTask {
                    await self.analyzeArchive(archiveURL, dateGroup: dateDir.lastPathComponent)
                }
            }
            var results: [ArchiveItem] = []
            for await item in group { if let i = item { results.append(i) } }
            return results
        }
    }

    // MARK: - Archive Analysis

    private func analyzeArchive(_ url: URL, dateGroup: String) async -> ArchiveItem? {
        let size = await fileSystem.size(at: url.path)
        guard size > 0 else { return nil }

        let modDate = (try? url
            .resourceValues(forKeys: [.contentModificationDateKey])
            .contentModificationDate) ?? Date.distantPast

        let plist = readInfoPlist(at: url)
        let projectName = plist?["Name"] as? String
            ?? extractProjectName(from: url.deletingPathExtension().lastPathComponent)
        let creationDate = plist?["CreationDate"] as? Date ?? modDate
        let appProps = plist?["ApplicationProperties"] as? [String: Any]
        let version = appProps?["CFBundleShortVersionString"] as? String ?? ""
        let uploadDest = (plist?["Distributions"] as? [[String: Any]])?.first?["uploadDestination"] as? String

        return ArchiveItem(
            id: url,
            name: url.deletingPathExtension().lastPathComponent,
            path: url,
            size: size,
            creationDate: creationDate,
            modificationDate: modDate,
            projectName: projectName,
            archiveVersion: version,
            dateGroup: dateGroup,
            uploadDestination: uploadDest
        )
    }

    // MARK: - Helpers

    private func readInfoPlist(at archiveURL: URL) -> [String: Any]? {
        let plistURL = archiveURL.appendingPathComponent("Info.plist")
        guard let data = try? Data(contentsOf: plistURL) else { return nil }
        return try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
    }

    // Extracts project name from Xcode's archive filename.
    // Format: "ProjectName D.MM.YYYY, HH.MM[ N]"
    private func extractProjectName(from rawName: String) -> String {
        // Match " D.MM.YYYY," — the space + date pattern marks where the project name ends
        if let range = rawName.range(of: #"\s+\d{1,2}\.\d{2}\.\d{4},"#, options: .regularExpression) {
            return String(rawName[..<range.lowerBound])
        }
        return rawName
    }
}
