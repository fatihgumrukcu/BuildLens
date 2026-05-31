import Foundation

final class NodeModulesService: NodeModulesServiceProtocol, Sendable {

    private let fileSystem: FileSystemService

    init(fileSystem: FileSystemService = FileSystemService()) {
        self.fileSystem = fileSystem
    }

    // MARK: - Public API

    func scanProjects() async throws -> [NodeModulesProject] {
        let fm = FileManager()
        var candidates: [URL] = []

        for root in WorkspaceService.discoveryRoots where fm.fileExists(atPath: root) {
            let found = findPackageRoots(in: URL(fileURLWithPath: root), depth: 0)
            candidates.append(contentsOf: found)
        }

        var seen = Set<URL>()
        let unique = candidates.filter { seen.insert($0).inserted }

        return await withTaskGroup(of: NodeModulesProject?.self, returning: [NodeModulesProject].self) { group in
            for url in unique {
                group.addTask { await self.analyzeProject(at: url) }
            }
            var results: [NodeModulesProject] = []
            for await project in group {
                if let p = project { results.append(p) }
            }
            return results.sorted { $0.nodeModulesSize > $1.nodeModulesSize }
        }
    }

    // MARK: - Discovery (DFS, max depth 3 to handle monorepos)

    // Directories we never descend into.
    private static let skipNames: Set<String> = [
        "node_modules", "Pods", ".build", "build", "dist", "out", ".git",
        "DerivedData", ".gradle", ".dart_tool", "__pycache__",
        "Library", "Applications", ".Trash"
    ]

    private func findPackageRoots(in url: URL, depth: Int) -> [URL] {
        guard depth <= 3 else { return [] }
        let fm = FileManager()
        guard let children = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        let names = Set(children.map { $0.lastPathComponent })
        var results: [URL] = []

        if names.contains("package.json") && names.contains("node_modules") {
            results.append(url)
            // Still recurse — monorepos have packages/ with nested node_modules.
        }

        for child in children {
            guard (try? child.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else { continue }
            guard !Self.skipNames.contains(child.lastPathComponent) else { continue }
            results.append(contentsOf: findPackageRoots(in: child, depth: depth + 1))
        }
        return results
    }

    // MARK: - Per-project Analysis

    private func analyzeProject(at url: URL) async -> NodeModulesProject? {
        let fm = FileManager()
        let nodeModulesURL = url.appendingPathComponent("node_modules")
        guard fm.fileExists(atPath: nodeModulesURL.path) else { return nil }
        guard let raw = try? fm.contentsOfDirectory(atPath: url.path) else { return nil }

        let contents = Set(raw)
        guard let projectType = classifyProject(contents) else { return nil }

        async let nmSize = fileSystem.size(at: nodeModulesURL.path)
        async let pkgCount = estimatePackageCount(at: nodeModulesURL)
        let (size, count) = await (nmSize, pkgCount)

        let modDate = (try? nodeModulesURL
            .resourceValues(forKeys: [.contentModificationDateKey])
            .contentModificationDate) ?? Date.distantPast

        let staleThreshold = Calendar.current.date(
            byAdding: .day, value: -NodeModulesThresholds.staleDays, to: Date()
        ) ?? Date()
        let isStale = modDate < staleThreshold

        let issues = generateIssues(
            size: size, lastModified: modDate, isStale: isStale, projectName: url.lastPathComponent
        )

        return NodeModulesProject(
            id: url,
            projectName: url.lastPathComponent,
            projectPath: url,
            nodeModulesPath: nodeModulesURL,
            nodeModulesSize: size,
            packageCount: count,
            lastModifiedDate: modDate,
            projectType: projectType,
            isStale: isStale,
            issues: issues
        )
    }

    // MARK: - Helpers

    // Counts top-level packages; @scope directories are expanded by one level.
    // Fast: reads only one directory level, no recursive walking.
    private func estimatePackageCount(at url: URL) async -> Int {
        await Task.detached(priority: .utility) {
            let fm = FileManager()
            guard let entries = try? fm.contentsOfDirectory(atPath: url.path) else { return 0 }
            var count = 0
            for entry in entries {
                if entry.hasPrefix("@") {
                    let scopeURL = url.appendingPathComponent(entry)
                    count += (try? fm.contentsOfDirectory(atPath: scopeURL.path).count) ?? 0
                } else {
                    count += 1
                }
            }
            return count
        }.value
    }

    private func classifyProject(_ contents: Set<String>) -> NodeModulesProjectType? {
        let hasIos     = contents.contains("ios")
        let hasAndroid = contents.contains("android")
        if contents.contains("package.json") && hasIos && hasAndroid { return .reactNative }
        if contents.contains("app.json")
            || contents.contains("app.config.js")
            || contents.contains("app.config.ts") { return .expo }
        if contents.contains("next.config.js")
            || contents.contains("next.config.mjs")
            || contents.contains("next.config.ts") { return .nextjs }
        if contents.contains("package.json") { return .node }
        return nil
    }

    private func generateIssues(
        size: Int64, lastModified: Date, isStale: Bool, projectName: String
    ) -> [NodeModulesIssue] {
        var issues: [NodeModulesIssue] = []
        let T = NodeModulesThresholds.self

        if size >= T.projectSizeWarning {
            issues.append(NodeModulesIssue(
                title: "Oversized node_modules (\(size.formattedBytes))",
                description: "\(projectName) has \(size.formattedBytes) in node_modules, above the \(T.projectSizeWarning.formattedBytes) threshold.",
                severity: size >= T.projectSizeCritical ? .critical : .warning,
                affectedStorage: size,
                recommendation: "Run `rm -rf node_modules && npm install` to reinstall from package.json."
            ))
        }

        let days = Calendar.current.dateComponents([.day], from: lastModified, to: Date()).day ?? 0
        if days >= T.abandonedDays && size >= T.abandonedSizeThreshold {
            issues.append(NodeModulesIssue(
                title: "Abandoned project with \(size.formattedBytes) in node_modules",
                description: "\(projectName) has not been modified in \(days) days but retains a large node_modules directory.",
                severity: .critical,
                affectedStorage: size,
                recommendation: "Archive or delete this project's node_modules if it is no longer active."
            ))
        } else if isStale && size >= T.abandonedSizeThreshold {
            issues.append(NodeModulesIssue(
                title: "Stale project (\(days) days) — \(size.formattedBytes) in node_modules",
                description: "\(projectName) has not changed in \(days) days but has \(size.formattedBytes) in node_modules.",
                severity: .warning,
                affectedStorage: size,
                recommendation: "Verify if this project is still active. Delete node_modules if not needed."
            ))
        }

        return issues
    }
}
