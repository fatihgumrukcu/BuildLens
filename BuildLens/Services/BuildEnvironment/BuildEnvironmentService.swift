import Foundation

final class BuildEnvironmentService: BuildEnvironmentServiceProtocol, Sendable {

    private let shell: any ShellServiceProtocol

    init(shell: any ShellServiceProtocol = ShellService()) {
        self.shell = shell
    }

    // MARK: - Tool definitions: (id, name, category, command, minimumVersion)

    private static let shellTools: [(String, String, BuildToolCategory, String, String?)] = [
        ("xcode",       "Xcode",       .xcode,      "xcodebuild -version",                    "15.0"),
        ("cocoapods",   "CocoaPods",   .xcode,      "pod --version",                          "1.12.0"),
        ("ruby",        "Ruby",        .xcode,      "ruby --version",                         "3.0.0"),
        ("fastlane",    "Fastlane",    .xcode,      "fastlane --version 2>&1 | head -1",      nil),
        ("node",        "Node.js",     .javascript, "node --version",                         "18.0.0"),
        ("npm",         "npm",         .javascript, "npm --version",                          "9.0.0"),
        ("yarn",        "Yarn",        .javascript, "yarn --version",                         nil),
        ("pnpm",        "pnpm",        .javascript, "pnpm --version",                         nil),
        ("watchman",    "Watchman",    .javascript, "watchman --version 2>&1 | head -1",      nil),
        ("java",        "Java",        .android,    "java -version 2>&1 | head -1",           "11.0"),
        ("gradle",      "Gradle",      .android,    "gradle --version 2>&1 | grep 'Gradle '", nil),
        ("homebrew",    "Homebrew",    .system,     "brew --version | head -1",               nil),
    ]

    // MARK: - Public API

    func scan() async throws -> BuildEnvironmentSummary {
        var tools: [BuildTool] = []

        await withTaskGroup(of: BuildTool.self) { group in
            for (id, name, category, command, minimum) in Self.shellTools {
                group.addTask {
                    await self.probeShellTool(id: id, name: name, category: category,
                                             command: command, minimumVersion: minimum)
                }
            }
            group.addTask { await self.probeAndroidSDK() }
            group.addTask { await self.probeAndroidStudio() }
            for await tool in group { tools.append(tool) }
        }

        let sorted = tools.sorted { $0.category.rawValue < $1.category.rawValue || ($0.category == $1.category && $0.name < $1.name) }
        return BuildEnvironmentSummary(tools: sorted)
    }

    // MARK: - Shell probing

    private func probeShellTool(id: String, name: String, category: BuildToolCategory,
                                command: String, minimumVersion: String?) async -> BuildTool {
        do {
            let raw = try await shell.run(command)
            let version = extractVersion(from: raw)
            let rawPath = ((try? await shell.run("which \(id) 2>/dev/null")) ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let path: String? = rawPath.isEmpty ? nil : rawPath
            let outdated = isOutdated(version, minimum: minimumVersion)
            let status: BuildToolStatus = outdated ? .outdated : .installed
            let issues = makeIssues(name: name, status: status, version: version, minimum: minimumVersion)
            return BuildTool(id: id, name: name, category: category, status: status,
                            version: version, path: path, issues: issues)
        } catch {
            let issue = BuildToolIssue(
                title: "\(name) not found",
                description: "\(name) is not installed or not on PATH.",
                severity: .warning,
                recommendation: "Install \(name) using Homebrew or the official installer."
            )
            return BuildTool(id: id, name: name, category: category, status: .missing,
                            version: nil, path: nil, issues: [issue])
        }
    }

    // MARK: - Filesystem probing

    private func probeAndroidSDK() async -> BuildTool {
        let env = ProcessInfo.processInfo.environment
        let candidates = [
            env["ANDROID_HOME"],
            env["ANDROID_SDK_ROOT"],
            "\(NSHomeDirectory())/Library/Android/sdk",
        ].compactMap { $0 }

        let fm = FileManager()
        for path in candidates where fm.fileExists(atPath: path) {
            return BuildTool(id: "android-sdk", name: "Android SDK", category: .android,
                            status: .installed, version: nil, path: path, issues: [])
        }
        return BuildTool(id: "android-sdk", name: "Android SDK", category: .android,
                        status: .missing, version: nil, path: nil, issues: [
            BuildToolIssue(title: "Android SDK not found",
                          description: "No Android SDK detected at $ANDROID_HOME or ~/Library/Android/sdk.",
                          severity: .warning,
                          recommendation: "Install Android Studio — it bundles the SDK and configures ANDROID_HOME automatically.")
        ])
    }

    private func probeAndroidStudio() async -> BuildTool {
        let appPath = "/Applications/Android Studio.app"
        let fm = FileManager()
        guard fm.fileExists(atPath: appPath) else {
            return BuildTool(id: "android-studio", name: "Android Studio", category: .android,
                            status: .missing, version: nil, path: nil, issues: [
                BuildToolIssue(title: "Android Studio not installed",
                              description: "Android Studio is the primary IDE for Android development.",
                              severity: .warning,
                              recommendation: "Download from developer.android.com/studio")
            ])
        }
        let plist = NSDictionary(contentsOf: URL(fileURLWithPath: "\(appPath)/Contents/Info.plist"))
        let version = plist?["CFBundleShortVersionString"] as? String
        return BuildTool(id: "android-studio", name: "Android Studio", category: .android,
                        status: .installed, version: version, path: appPath, issues: [])
    }

    // MARK: - Helpers

    private func extractVersion(from raw: String) -> String? {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let match = text.firstMatch(of: /\d+\.\d+(?:\.\d+)?/) {
            return String(match.output)
        }
        return text.components(separatedBy: .newlines).first.map { String($0.prefix(80)) }
    }

    private func isOutdated(_ version: String?, minimum: String?) -> Bool {
        guard let v = version, let min = minimum else { return false }
        let vParts = versionParts(v)
        let mParts = versionParts(min)
        guard !vParts.isEmpty else { return false }
        for i in 0..<max(vParts.count, mParts.count) {
            let d = i < vParts.count ? vParts[i] : 0
            let m = i < mParts.count ? mParts[i] : 0
            if d < m { return true }
            if d > m { return false }
        }
        return false
    }

    private func versionParts(_ raw: String) -> [Int] {
        guard let match = raw.firstMatch(of: /\d+(?:\.\d+)*/) else { return [] }
        return String(match.output).components(separatedBy: ".").compactMap(Int.init)
    }

    private func makeIssues(name: String, status: BuildToolStatus,
                            version: String?, minimum: String?) -> [BuildToolIssue] {
        guard status == .outdated, let min = minimum else { return [] }
        return [BuildToolIssue(
            title: "\(name) is below recommended version \(min)",
            description: "Running an outdated \(name) can cause build failures or compatibility issues.",
            severity: .warning,
            recommendation: "Update \(name) to \(min) or newer."
        )]
    }
}

