import Foundation

final class WorkspaceService: WorkspaceServiceProtocol, Sendable {

    private let fileSystem: FileSystemService

    init(fileSystem: FileSystemService = FileSystemService()) {
        self.fileSystem = fileSystem
    }

    // MARK: - Discovery Roots

    // Directories searched for developer projects (existence-checked before scanning).
    static let discoveryRoots: [String] = [
        "\(NSHomeDirectory())/Desktop",
        "\(NSHomeDirectory())/Developer",
        "\(NSHomeDirectory())/Documents",
        "\(NSHomeDirectory())/Code",
        "\(NSHomeDirectory())/Projects",
        "\(NSHomeDirectory())/Workspace",
        "\(NSHomeDirectory())/dev",
        "\(NSHomeDirectory())/repos",
    ]

    // Directory names that are never project roots — skip them during DFS.
    private static let skipNames: Set<String> = [
        "node_modules", "Pods", ".build", "build", "dist", "out",
        ".git", "DerivedData", ".gradle", ".dart_tool", "__pycache__",
        "Library", "Applications",
    ]

    // MARK: - Public API

    func scanProjects() async throws -> [WorkspaceProject] {
        let fm = FileManager()
        var candidates: [URL] = []

        for root in Self.discoveryRoots where fm.fileExists(atPath: root) {
            let found = discoverCandidates(in: URL(fileURLWithPath: root), depth: 0)
            candidates.append(contentsOf: found)
        }

        var seen = Set<URL>()
        let unique = candidates.filter { seen.insert($0).inserted }

        return await withTaskGroup(of: WorkspaceProject?.self, returning: [WorkspaceProject].self) { group in
            for url in unique {
                group.addTask { await self.analyzeProject(at: url) }
            }
            var results: [WorkspaceProject] = []
            for await project in group {
                if let p = project { results.append(p) }
            }
            return results.sorted { $0.totalSize > $1.totalSize }
        }
    }

    // MARK: - Discovery (synchronous DFS, max depth 2)

    private func discoverCandidates(in url: URL, depth: Int) -> [URL] {
        guard depth <= 2 else { return [] }
        let fm = FileManager()
        guard let children = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        var results: [URL] = []
        for child in children {
            guard (try? child.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else { continue }
            guard !Self.skipNames.contains(child.lastPathComponent) else { continue }
            let contents = Set((try? fm.contentsOfDirectory(atPath: child.path)) ?? [])
            if isProjectRoot(contents) {
                results.append(child)
            } else if depth < 2 {
                results.append(contentsOf: discoverCandidates(in: child, depth: depth + 1))
            }
        }
        return results
    }

    private func isProjectRoot(_ contents: Set<String>) -> Bool {
        contents.contains("package.json")  ||
        contents.contains("Podfile")       ||
        contents.contains("Package.swift") ||
        contents.contains("pubspec.yaml")  ||
        contents.contains("gradlew")       ||
        contents.contains(".git")          ||
        contents.contains("Cartfile")      ||
        contents.first(where: { $0.hasSuffix(".xcodeproj") }) != nil
    }

    // MARK: - Per-Project Analysis

    private func analyzeProject(at url: URL) async -> WorkspaceProject? {
        let fm = FileManager()
        guard let raw = try? fm.contentsOfDirectory(atPath: url.path) else { return nil }
        let contents = Set(raw)
        guard let type = classifyProject(contents) else { return nil }

        async let nm    = sizeIfExists(url.appendingPathComponent("node_modules"))
        async let pods  = sizeIfExists(url.appendingPathComponent("Pods"))
        async let swb   = sizeIfExists(url.appendingPathComponent(".build"))
        async let ab    = sizeIfExists(url.appendingPathComponent("build"))
        async let dart  = sizeIfExists(url.appendingPathComponent(".dart_tool"))
        let (nodeModulesSize, podsSize, s, a, d) = await (nm, pods, swb, ab, dart)
        let buildSize = s + a + d
        let totalSize = await fileSystem.size(at: url.path)
        let modDate   = (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast

        let issues = generateIssues(nm: nodeModulesSize, pods: podsSize, build: buildSize,
                                    lastModified: modDate, total: totalSize)
        return WorkspaceProject(
            id: url, url: url, name: url.lastPathComponent, projectType: type,
            totalSize: totalSize, nodeModulesSize: nodeModulesSize, podsSize: podsSize,
            derivedDataEstimate: buildSize, lastModified: modDate,
            isGitRepository: contents.contains(".git"), issues: issues
        )
    }

    private func classifyProject(_ contents: Set<String>) -> WorkspaceProjectType? {
        let hasPkg = contents.contains("package.json")
        let hasIos = contents.contains("ios")
        let hasAndroid = contents.contains("android")

        if contents.contains("pubspec.yaml") { return .flutter }
        if hasPkg && hasIos && hasAndroid    { return .reactNative }
        if hasPkg && (contents.contains("app.json") || contents.contains("app.config.js")) { return .expo }
        if hasPkg && (contents.contains("next.config.js") || contents.contains("next.config.mjs")) { return .nextjs }
        if contents.first(where: { $0.hasSuffix(".xcodeproj") }) != nil || contents.contains("Podfile") { return .ios }
        if hasAndroid && contents.contains("gradlew") { return .android }
        if contents.contains("Package.swift") { return .swift }
        if hasPkg { return .node }
        if contents.contains(".git") { return .unknown }
        return nil
    }

    // MARK: - Issue Generation

    private func generateIssues(nm: Int64, pods: Int64, build: Int64, lastModified: Date, total: Int64) -> [WorkspaceIssue] {
        var issues: [WorkspaceIssue] = []
        let T = WorkspaceThresholds.self

        if nm >= T.nodeModulesWarning {
            issues.append(WorkspaceIssue(
                title: "Large node_modules (\(nm.formattedBytes))",
                description: "node_modules is \(nm.formattedBytes). All packages can be reinstalled from package.json.",
                severity: nm >= T.nodeModulesCritical ? .critical : .warning,
                affectedStorage: nm,
                recommendation: "Delete node_modules and run `npm install` or `yarn` to reinstall."
            ))
        }
        if pods >= T.podsWarning {
            issues.append(WorkspaceIssue(
                title: "Large Pods directory (\(pods.formattedBytes))",
                description: "CocoaPods install directory is \(pods.formattedBytes). Re-runnable from Podfile.",
                severity: pods >= T.podsCritical ? .critical : .warning,
                affectedStorage: pods,
                recommendation: "Run `pod deintegrate && pod install` to rebuild."
            ))
        }
        if build >= T.buildArtifactsWarning {
            issues.append(WorkspaceIssue(
                title: "Stale build artefacts (\(build.formattedBytes))",
                description: "Local build output directories total \(build.formattedBytes).",
                severity: .warning, affectedStorage: build,
                recommendation: "Delete .build/ or build/ directories, or use Xcode → Product → Clean Build Folder."
            ))
        }
        let days = Calendar.current.dateComponents([.day], from: lastModified, to: Date()).day ?? 0
        if days > T.staleCriticalDays {
            issues.append(WorkspaceIssue(title: "Project appears abandoned",
                description: "No file changes in \(days) days.",
                severity: .critical, affectedStorage: total,
                recommendation: "Archive or delete this project if it is no longer needed."))
        } else if days > T.staleWarningDays {
            issues.append(WorkspaceIssue(title: "Project may be stale",
                description: "No file changes in \(days) days.",
                severity: .warning,
                recommendation: "Verify whether this project is still active."))
        }
        return issues
    }

    private func sizeIfExists(_ url: URL) async -> Int64 {
        guard FileManager().fileExists(atPath: url.path) else { return 0 }
        return await fileSystem.size(at: url.path)
    }
}
