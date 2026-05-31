import Foundation

final class EnvironmentHealthService: EnvironmentHealthServiceProtocol, Sendable {

    private let fileSystem: FileSystemService
    private let simulatorService: any SimulatorServiceProtocol

    init(
        fileSystem: FileSystemService = FileSystemService(),
        simulatorService: any SimulatorServiceProtocol = SimulatorService(),
        nodeModulesService: any NodeModulesServiceProtocol = NodeModulesService()
    ) {
        self.fileSystem = fileSystem
        self.simulatorService = simulatorService
        self.nodeModulesService = nodeModulesService
    }

    private let nodeModulesService: any NodeModulesServiceProtocol

    // Runs all five section analyses concurrently and assembles the final report.
    func generateReport() async -> EnvironmentHealthReport {
        async let dd   = analyzeDerivedData()
        async let sim  = analyzeSimulators()
        async let caches = analyzeCaches()
        async let arch = analyzeArchives()
        async let nm   = analyzeNodeModules()

        let sections = await [dd, sim, caches, arch, nm]
        let overallScore = HealthScoring.weightedScore(sections: sections)
        let recommendations = prioritizedRecommendations(from: sections)

        return EnvironmentHealthReport(
            overallScore: overallScore,
            status: HealthScoring.severity(for: overallScore),
            generatedAt: Date(),
            sections: sections,
            recommendations: recommendations
        )
    }

    // MARK: - Section Analysers

    private func analyzeDerivedData() async -> EnvironmentHealthSection {
        guard fileSystem.exists(at: FileSystemService.derivedDataPath) else {
            return section(.derivedData, score: 100, issues: [], summary: "No DerivedData found")
        }

        let size = await fileSystem.size(at: FileSystemService.derivedDataPath)
        let score = HealthScoring.scoreSize(size, warning: HealthThresholds.derivedDataWarning, critical: HealthThresholds.derivedDataCritical)
        var issues: [EnvironmentIssue] = []

        if size >= HealthThresholds.derivedDataWarning {
            issues.append(EnvironmentIssue(
                title: "Stale DerivedData detected",
                description: "DerivedData is \(size.formattedBytes). Stale build artefacts accumulate across Xcode version upgrades and scheme changes.",
                severity: HealthScoring.severity(for: score),
                recommendation: "Clean DerivedData from the Clean Up tab. Xcode rebuilds it automatically.",
                affectedStorage: size,
                category: .derivedData
            ))
        }

        let summary = issues.isEmpty
            ? "Within normal range (\(size.formattedBytes))"
            : "\(size.formattedBytes) accumulated — above threshold"
        return section(.derivedData, score: score, issues: issues, summary: summary)
    }

    private func analyzeSimulators() async -> EnvironmentHealthSection {
        let runtimes: [SimulatorRuntime]
        do { runtimes = try await simulatorService.fetchRuntimes() } catch {
            let fallback = EnvironmentIssue(
                title: "Simulator data unavailable",
                description: "Could not read simulator state: \(error.localizedDescription)",
                severity: .warning,
                recommendation: "Ensure Xcode is installed and command-line tools are selected in Xcode → Settings → Locations.",
                category: .simulators
            )
            return section(.simulators, score: 75, issues: [fallback], summary: "Scan failed — Xcode may not be installed")
        }

        var issues: [EnvironmentIssue] = []
        let allDevices      = runtimes.flatMap(\.devices)
        let unavailableDevs = allDevices.filter { !$0.isAvailable }
        let unavailableRTs  = runtimes.filter { !$0.isAvailable }
        let totalStorage    = allDevices.reduce(0) { $0 + $1.storageSize }

        let devScore  = HealthScoring.scoreCount(unavailableDevs.count, warning: HealthThresholds.unavailableSimsWarning, critical: HealthThresholds.unavailableSimsCritical)
        let rtScore   = HealthScoring.scoreCount(unavailableRTs.count, warning: HealthThresholds.unavailableRuntimesWarning, critical: HealthThresholds.unavailableRuntimesCritical)
        let stgScore  = HealthScoring.scoreSize(totalStorage, warning: HealthThresholds.simulatorStorageWarning, critical: HealthThresholds.simulatorStorageCritical)
        let sectionScore = (devScore + rtScore + stgScore) / 3

        if !unavailableDevs.isEmpty {
            let storage = unavailableDevs.reduce(0) { $0 + $1.storageSize }
            issues.append(EnvironmentIssue(
                title: "\(unavailableDevs.count) unavailable simulator device\(unavailableDevs.count == 1 ? "" : "s")",
                description: "Unavailable devices cannot be launched. Their data still occupies \(storage.formattedBytes) on disk.",
                severity: HealthScoring.severity(for: devScore),
                recommendation: "Review and remove unavailable simulators from the Simulators tab.",
                affectedStorage: storage,
                category: .simulators
            ))
        }
        if !unavailableRTs.isEmpty {
            issues.append(EnvironmentIssue(
                title: "\(unavailableRTs.count) unavailable simulator runtime\(unavailableRTs.count == 1 ? "" : "s")",
                description: "Runtimes \(unavailableRTs.map(\.displayName).joined(separator: ", ")) are marked unavailable by CoreSimulator.",
                severity: HealthScoring.severity(for: rtScore),
                recommendation: "Open Xcode → Settings → Platforms to re-download or remove unavailable runtimes.",
                category: .simulators
            ))
        }
        if totalStorage >= HealthThresholds.simulatorStorageWarning {
            issues.append(EnvironmentIssue(
                title: "High simulator storage usage",
                description: "All simulator devices are using \(totalStorage.formattedBytes) combined.",
                severity: HealthScoring.severity(for: stgScore),
                recommendation: "Remove unused simulator devices and runtimes from the Simulators tab.",
                affectedStorage: totalStorage,
                category: .simulators
            ))
        }

        let summary = issues.isEmpty
            ? "\(allDevices.count) device\(allDevices.count == 1 ? "" : "s") across \(runtimes.count) runtimes — all healthy"
            : "\(issues.count) issue\(issues.count == 1 ? "" : "s") detected across \(runtimes.count) runtimes"
        return section(.simulators, score: sectionScore, issues: issues, summary: summary)
    }

    private func analyzeCaches() async -> EnvironmentHealthSection {
        async let metro    = fileSystem.size(at: FileSystemService.metroCachePath)
        async let gradle   = fileSystem.size(at: FileSystemService.gradleCachePath)
        async let pods     = fileSystem.size(at: FileSystemService.cocoapodsCachePath)
        async let watchman = fileSystem.size(at: FileSystemService.watchmanCachePath)
        let (m, g, p, w) = await (metro, gradle, pods, watchman)

        var issues: [EnvironmentIssue] = []
        var scores: [Int] = []

        func check(_ size: Int64, name: String, hint: String, warning: Int64, critical: Int64, category: EnvironmentHealthCategory = .caches) {
            guard size > 0 else { return }
            let s = HealthScoring.scoreSize(size, warning: warning, critical: critical)
            scores.append(s)
            if size >= warning {
                issues.append(EnvironmentIssue(
                    title: "\(name) is large",
                    description: "\(name) is using \(size.formattedBytes). \(hint)",
                    severity: HealthScoring.severity(for: s),
                    recommendation: "Clear \(name) from the Clean Up tab.",
                    affectedStorage: size,
                    category: category
                ))
            }
        }

        check(m, name: "Metro Cache",      hint: "Rebuilt automatically on next `npx react-native start`.",          warning: HealthThresholds.metroCacheWarning,      critical: HealthThresholds.metroCacheCritical)
        check(g, name: "Gradle Cache",     hint: "Dependencies re-downloaded on the next Android build.",            warning: HealthThresholds.gradleCacheWarning,     critical: HealthThresholds.gradleCacheCritical)
        check(p, name: "CocoaPods Cache",  hint: "Re-downloaded on the next `pod install` run.",                     warning: HealthThresholds.cocoapodsCacheWarning,  critical: HealthThresholds.cocoapodsCacheCritical)
        check(w, name: "Watchman Cache",   hint: "File-watch state rebuilt automatically when Watchman restarts.",   warning: HealthThresholds.watchmanCacheWarning,   critical: HealthThresholds.watchmanCacheCritical)

        let sectionScore = scores.isEmpty ? 100 : scores.reduce(0, +) / scores.count
        let total = m + g + p + w
        let summary = issues.isEmpty
            ? (total > 0 ? "All caches within normal range (\(total.formattedBytes) total)" : "No developer caches found")
            : "\(issues.count) cache\(issues.count == 1 ? "" : "s") above threshold"
        return section(.caches, score: sectionScore, issues: issues, summary: summary)
    }

    private func analyzeArchives() async -> EnvironmentHealthSection {
        guard fileSystem.exists(at: FileSystemService.xcodeArchivesPath) else {
            return section(.archives, score: 100, issues: [], summary: "No Xcode Archives found")
        }

        let size = await fileSystem.size(at: FileSystemService.xcodeArchivesPath)
        guard size > 0 else {
            return section(.archives, score: 100, issues: [], summary: "Archives folder is empty")
        }

        let score = HealthScoring.scoreSize(size, warning: HealthThresholds.archivesWarning, critical: HealthThresholds.archivesCritical)
        var issues: [EnvironmentIssue] = []

        if size >= HealthThresholds.archivesWarning {
            issues.append(EnvironmentIssue(
                title: "Large Xcode Archives folder",
                description: "Xcode Archives are using \(size.formattedBytes). Old archives accumulate after each distribution build.",
                severity: HealthScoring.severity(for: score),
                recommendation: "Review archives in Xcode Organizer. Delete builds you no longer need for re-signing or dSYM lookup.",
                affectedStorage: size,
                category: .archives
            ))
        }

        let summary = issues.isEmpty
            ? "Within normal range (\(size.formattedBytes))"
            : "\(size.formattedBytes) in archives — above threshold"
        return section(.archives, score: score, issues: issues, summary: summary)
    }

    private func analyzeNodeModules() async -> EnvironmentHealthSection {
        let projects: [NodeModulesProject]
        do { projects = try await nodeModulesService.scanProjects() } catch {
            return section(.nodeModules, score: 100, issues: [], summary: "Node Modules scan unavailable")
        }

        guard !projects.isEmpty else {
            return section(.nodeModules, score: 100, issues: [], summary: "No node_modules found")
        }

        let total     = projects.reduce(0) { $0 + $1.nodeModulesSize }
        let abandoned = projects.filter(\.isAbandoned).count
        let score     = HealthScoring.scoreSize(
            total,
            warning: HealthThresholds.nodeModulesWarning,
            critical: HealthThresholds.nodeModulesCritical
        )

        var issues: [EnvironmentIssue] = []

        if total >= HealthThresholds.nodeModulesWarning {
            issues.append(EnvironmentIssue(
                title: "Total node_modules is \(total.formattedBytes)",
                description: "\(projects.count) projects are using \(total.formattedBytes) in node_modules combined.",
                severity: HealthScoring.severity(for: score),
                recommendation: "Delete node_modules in inactive projects and reinstall on demand.",
                affectedStorage: total,
                category: .nodeModules
            ))
        }

        if abandoned >= 2 {
            let abandonedStorage = projects.filter(\.isAbandoned).reduce(0) { $0 + $1.nodeModulesSize }
            issues.append(EnvironmentIssue(
                title: "\(abandoned) abandoned projects with large node_modules",
                description: "Projects untouched for \(NodeModulesThresholds.abandonedDays)+ days collectively hold \(abandonedStorage.formattedBytes).",
                severity: .warning,
                recommendation: "Archive or delete node_modules in projects you are no longer developing.",
                affectedStorage: abandonedStorage,
                category: .nodeModules
            ))
        }

        let summary = issues.isEmpty
            ? "\(projects.count) project\(projects.count == 1 ? "" : "s") — \(total.formattedBytes) total"
            : "\(issues.count) issue\(issues.count == 1 ? "" : "s") — \(total.formattedBytes) across \(projects.count) projects"
        return section(.nodeModules, score: score, issues: issues, summary: summary)
    }

    // MARK: - Helpers

    private func section(_ category: EnvironmentHealthCategory, score: Int, issues: [EnvironmentIssue], summary: String) -> EnvironmentHealthSection {
        EnvironmentHealthSection(category: category, score: score, issues: issues, summary: summary, severity: HealthScoring.severity(for: score))
    }

    // Builds a deduplicated, severity-ordered recommendation list capped at 6 items.
    private func prioritizedRecommendations(from sections: [EnvironmentHealthSection]) -> [String] {
        var seen = Set<String>()
        return sections
            .flatMap(\.issues)
            .sorted { $0.severity > $1.severity }
            .map(\.recommendation)
            .filter { seen.insert($0).inserted }
            .prefix(6)
            .map { $0 }
    }
}
