import Foundation

final class DiagnosticsService: DiagnosticsServiceProtocol, Sendable {

    private let healthService:    any EnvironmentHealthServiceProtocol
    private let buildEnvService:  any BuildEnvironmentServiceProtocol
    private let nmService:        any NodeModulesServiceProtocol
    private let metroCacheService: any MetroCacheServiceProtocol
    private let gradleService:    any GradleCacheServiceProtocol
    private let archivesService:  any ArchivesServiceProtocol
    private let fileSystem:       FileSystemService

    init(
        healthService:     any EnvironmentHealthServiceProtocol = EnvironmentHealthService(),
        buildEnvService:   any BuildEnvironmentServiceProtocol  = BuildEnvironmentService(),
        nmService:         any NodeModulesServiceProtocol       = NodeModulesService(),
        metroCacheService: any MetroCacheServiceProtocol        = MetroCacheService(),
        gradleService:     any GradleCacheServiceProtocol       = GradleCacheService(),
        archivesService:   any ArchivesServiceProtocol          = ArchivesService(),
        fileSystem:        FileSystemService                     = FileSystemService()
    ) {
        self.healthService     = healthService
        self.buildEnvService   = buildEnvService
        self.nmService         = nmService
        self.metroCacheService = metroCacheService
        self.gradleService     = gradleService
        self.archivesService   = archivesService
        self.fileSystem        = fileSystem
    }

    // MARK: - Public API

    func generateReport() async throws -> DiagnosticSummary {
        async let health      = healthService.generateReport()
        async let buildEnv    = buildEnvService.scan()
        async let nmProjects  = (try? nmService.scanProjects())      ?? []
        async let metroItems  = (try? metroCacheService.scanEntries()) ?? []
        async let gradleItems = (try? gradleService.scanEntries())    ?? []
        async let archItems   = (try? archivesService.scanArchives()) ?? []

        let (h, env, nm, metro, gradle, arch) = await (health, buildEnv, nmProjects, metroItems, gradleItems, archItems)

        var issues: [DiagnosticIssue] = []
        issues += fromHealth(h)
        issues += fromBuildEnv(env)
        issues += fromNodeModules(NodeModulesSummary.build(from: nm))
        issues += fromMetro(MetroCacheSummary.build(from: metro))
        issues += fromGradle(GradleCacheSummary.build(from: gradle))
        issues += fromArchives(ArchiveSummary.build(from: arch))
        issues += healthyItems(h, env)

        return DiagnosticSummary.build(from: issues)
    }

    // MARK: - Conversion: EnvironmentHealth

    private func fromHealth(_ report: EnvironmentHealthReport) -> [DiagnosticIssue] {
        report.allIssues.map { issue in
            DiagnosticIssue(
                title: issue.title,
                description: issue.description,
                severity: issue.severity,
                affectedStorage: issue.affectedStorage,
                recommendation: issue.recommendation,
                category: categoryForHealthCategory(issue.category),
                source: issue.category.rawValue
            )
        }
    }

    // MARK: - Conversion: Build Environment

    private func fromBuildEnv(_ summary: BuildEnvironmentSummary) -> [DiagnosticIssue] {
        summary.allIssues.map { issue in
            DiagnosticIssue(
                title: issue.title,
                description: issue.description,
                severity: issue.severity,
                recommendation: issue.recommendation,
                category: .environment,
                source: "Build Environment"
            )
        }
    }

    // MARK: - Conversion: Node Modules

    private func fromNodeModules(_ summary: NodeModulesSummary) -> [DiagnosticIssue] {
        summary.topIssues.map { issue in
            DiagnosticIssue(
                title: issue.title,
                description: issue.description,
                severity: issue.severity,
                affectedStorage: issue.affectedStorage,
                recommendation: issue.recommendation,
                category: .javascript,
                source: "Node Modules"
            )
        }
    }

    // MARK: - Conversion: Metro Cache

    private func fromMetro(_ summary: MetroCacheSummary) -> [DiagnosticIssue] {
        summary.issues.map { issue in
            DiagnosticIssue(
                title: issue.title,
                description: issue.description,
                severity: issue.severity,
                affectedStorage: issue.affectedStorage,
                recommendation: issue.recommendation,
                category: .javascript,
                source: "Metro Cache"
            )
        }
    }

    // MARK: - Conversion: Gradle Cache

    private func fromGradle(_ summary: GradleCacheSummary) -> [DiagnosticIssue] {
        summary.issues.map { issue in
            DiagnosticIssue(
                title: issue.title,
                description: issue.description,
                severity: issue.severity,
                affectedStorage: issue.affectedStorage,
                recommendation: issue.recommendation,
                category: .android,
                source: "Gradle Cache"
            )
        }
    }

    // MARK: - Conversion: Archives

    private func fromArchives(_ summary: ArchiveSummary) -> [DiagnosticIssue] {
        summary.issues.map { issue in
            DiagnosticIssue(
                title: issue.title,
                description: issue.description,
                severity: issue.severity,
                affectedStorage: issue.affectedStorage,
                recommendation: issue.recommendation,
                category: .xcode,
                source: "Archives"
            )
        }
    }

    // MARK: - Healthy items

    private func healthyItems(_ health: EnvironmentHealthReport, _ env: BuildEnvironmentSummary) -> [DiagnosticIssue] {
        var items: [DiagnosticIssue] = []

        if health.overallScore >= 75 {
            items.append(DiagnosticIssue(
                title: "Xcode environment is healthy",
                description: "DerivedData, Simulators, Caches, and Archives are all within normal ranges.",
                severity: .healthy, recommendation: "",
                category: .xcode, source: "Environment Health"
            ))
        }
        if env.missingCount == 0 {
            items.append(DiagnosticIssue(
                title: "All developer tools installed",
                description: "All \(env.installedCount) probed tools are present on this machine.",
                severity: .healthy, recommendation: "",
                category: .environment, source: "Build Environment"
            ))
        }
        return items
    }

    // MARK: - Category mapping

    private func categoryForHealthCategory(_ cat: EnvironmentHealthCategory) -> DiagnosticCategory {
        switch cat {
        case .derivedData, .simulators, .archives: return .xcode
        case .caches:                              return .javascript
        case .nodeModules:                         return .javascript
        }
    }
}
