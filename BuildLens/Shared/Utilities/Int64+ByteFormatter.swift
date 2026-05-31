import Foundation

extension Int64 {
    // Human-readable file size (e.g. "4.2 GB", "312 MB").
    // Uses .file count style so it matches Finder's display convention.
    var formattedBytes: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.includesActualByteCount = false
        return formatter.string(fromByteCount: self)
    }
}
