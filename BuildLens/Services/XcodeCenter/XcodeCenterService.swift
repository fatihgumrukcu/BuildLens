import Foundation

final class XcodeCenterService: XcodeCenterServiceProtocol, Sendable {

    private let fileSystem: FileSystemService
    private let shell: any ShellServiceProtocol

    static let deviceSupportPath     = "\(NSHomeDirectory())/Library/Developer/Xcode/iOS DeviceSupport"
    static let documentationCachePath = "\(NSHomeDirectory())/Library/Developer/Xcode/DocumentationCache"

    init(
        fileSystem: FileSystemService = FileSystemService(),
        shell: any ShellServiceProtocol = ShellService()
    ) {
        self.fileSystem = fileSystem
        self.shell = shell
    }

    // MARK: - Public API

    func generateSummary() async throws -> XcodeInfrastructureSummary {
        async let installation  = fetchInstallation()
        async let derivedData   = analyzeSection(.derivedData,  at: FileSystemService.derivedDataPath)
        async let archives      = analyzeArchives()
        async let simulators    = analyzeSection(.simulators,   at: FileSystemService.simulatorsPath)
        async let deviceSupport = analyzeDeviceSupport()
        async let docCache      = analyzeSection(.documentationCache, at: Self.documentationCachePath)

        let (inst, dd, (archSection, archEntries), sim, (dsSection, dsEntries), doc) =
            await (installation, derivedData, archives, simulators, deviceSupport, docCache)

        let sections = [dd, archSection, sim, dsSection, doc].compactMap { $0 }

        return XcodeInfrastructureSummary.build(
            installation: inst,
            sections: sections,
            archiveEntries: archEntries,
            deviceSupportEntries: dsEntries
        )
    }

    // MARK: - Xcode Version

    private func fetchInstallation() async -> XcodeInstallation? {
        let versionOutput = (try? await shell.run("xcodebuild -version")) ?? ""
        let selectPath    = (try? await shell.run("xcode-select -p"))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let lines = versionOutput.split(separator: "\n").map(String.init)
        guard let firstLine = lines.first else { return nil }

        let version      = firstLine.replacingOccurrences(of: "Xcode ", with: "").trimmingCharacters(in: .whitespaces)
        let buildVersion = lines.first(where: { $0.hasPrefix("Build version") })?
            .replacingOccurrences(of: "Build version ", with: "")
            .trimmingCharacters(in: .whitespaces) ?? ""

        return XcodeInstallation(
            version: version, buildVersion: buildVersion,
            developerPath: selectPath, isActive: true, installationSize: nil
        )
    }

    // MARK: - Generic Section Scanner

    // Returns nil if the path doesn't exist or is empty.
    private func analyzeSection(_ category: XcodeStorageCategory, at path: String) async -> XcodeStorageSection? {
        let fm = FileManager()
        guard fm.fileExists(atPath: path) else { return nil }
        async let size  = fileSystem.size(at: path)
        async let count = countTopLevelItems(at: path)
        let (s, c) = await (size, count)
        guard s > 0 else { return nil }
        // DerivedData and documentation cache are fully reclaimable; others depend on usage.
        let reclaimable: Int64 = (category == .derivedData || category == .documentationCache) ? s : 0
        return XcodeStorageSection(category: category, size: s, itemCount: c, reclaimableStorage: reclaimable)
    }

    // MARK: - Archives

    private func analyzeArchives() async -> (section: XcodeStorageSection?, entries: [XcodeArchiveEntry]) {
        let path = FileSystemService.xcodeArchivesPath
        let fm = FileManager()
        guard fm.fileExists(atPath: path) else { return (nil, []) }

        let dateGroups = (try? fm.contentsOfDirectory(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.isDirectoryKey],
            options: .skipsHiddenFiles
        ))?.filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true } ?? []

        var entries: [XcodeArchiveEntry] = []

        await withTaskGroup(of: [XcodeArchiveEntry].self) { group in
            for dateDir in dateGroups {
                group.addTask { await self.scanArchiveDateGroup(dateDir) }
            }
            for await batch in group { entries.append(contentsOf: batch) }
        }

        guard !entries.isEmpty else { return (nil, []) }
        let totalSize = entries.reduce(0) { $0 + $1.size }
        let staleStorage = entries.filter(\.isStale).reduce(0) { $0 + $1.size }
        let section = XcodeStorageSection(
            category: .archives, size: totalSize,
            itemCount: entries.count, reclaimableStorage: staleStorage
        )
        return (section, entries)
    }

    private func scanArchiveDateGroup(_ dateDir: URL) async -> [XcodeArchiveEntry] {
        let fm = FileManager()
        let items = (try? fm.contentsOfDirectory(
            at: dateDir,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
            options: .skipsHiddenFiles
        ))?.filter { $0.pathExtension == "xcarchive" } ?? []

        var results: [XcodeArchiveEntry] = []
        for item in items {
            let size = await fileSystem.size(at: item.path)
            guard size > 0 else { continue }
            let modDate = (try? item.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            results.append(XcodeArchiveEntry(
                id: item, path: item,
                name: item.lastPathComponent,
                size: size,
                dateGroup: dateDir.lastPathComponent,
                modifiedDate: modDate
            ))
        }
        return results
    }

    // MARK: - Device Support

    private func analyzeDeviceSupport() async -> (section: XcodeStorageSection?, entries: [XcodeDeviceSupportEntry]) {
        let path = Self.deviceSupportPath
        let fm = FileManager()
        guard fm.fileExists(atPath: path) else { return (nil, []) }

        let versionDirs = (try? fm.contentsOfDirectory(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
            options: .skipsHiddenFiles
        ))?.filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true } ?? []

        var entries: [XcodeDeviceSupportEntry] = []
        await withTaskGroup(of: XcodeDeviceSupportEntry?.self) { group in
            for dir in versionDirs {
                group.addTask {
                    let size = await self.fileSystem.size(at: dir.path)
                    guard size > 0 else { return nil }
                    let modDate = (try? dir.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
                    return XcodeDeviceSupportEntry(id: dir, path: dir, rawName: dir.lastPathComponent, size: size, modifiedDate: modDate)
                }
            }
            for await entry in group { if let e = entry { entries.append(e) } }
        }

        guard !entries.isEmpty else { return (nil, []) }
        let totalSize = entries.reduce(0) { $0 + $1.size }
        let section = XcodeStorageSection(
            category: .deviceSupport, size: totalSize,
            itemCount: entries.count, reclaimableStorage: 0
        )
        return (section, entries)
    }

    // MARK: - Helpers

    private func countTopLevelItems(at path: String) async -> Int {
        await Task.detached(priority: .utility) {
            let fm = FileManager()
            return (try? fm.contentsOfDirectory(atPath: path).count) ?? 0
        }.value
    }
}
