import Foundation

final class ShellService: ShellServiceProtocol, Sendable {

    func run(_ command: String) async throws -> String {
        // Task.detached escapes any actor isolation (including @MainActor from callers)
        // so the Process spawn runs on a background thread.
        try await Task.detached(priority: .utility) {
            let process = Process()
            let stdoutPipe = Pipe()

            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            // -l loads the user's login shell profile so PATH includes Homebrew, rbenv, etc.
            process.arguments = ["-l", "-c", command]
            process.standardOutput = stdoutPipe
            process.standardError = Pipe() // suppress stderr noise
            process.environment = ProcessInfo.processInfo.environment

            try process.run()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                throw ShellError.nonZeroExit(code: process.terminationStatus)
            }

            let data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            return String(decoding: data, as: UTF8.self)
        }.value
    }

    func which(_ tool: String) async throws -> String {
        try await run("which \(tool)")
    }
}

enum ShellError: LocalizedError {
    case nonZeroExit(code: Int32)

    var errorDescription: String? {
        switch self {
        case .nonZeroExit(let code): return "Command exited with status \(code)"
        }
    }
}
