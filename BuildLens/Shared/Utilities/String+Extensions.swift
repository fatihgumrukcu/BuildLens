import Foundation

extension String {
    // Collapses the home directory prefix to "~" for compact display.
    var abbreviatedPath: String {
        let home = NSHomeDirectory()
        guard hasPrefix(home) else { return self }
        return "~" + dropFirst(home.count)
    }
}
