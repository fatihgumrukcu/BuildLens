import Foundation

// Pure, stateless scoring utilities. All functions are deterministic —
// same inputs always produce the same score, with no randomness or time dependency.
//
// Piecewise linear scale for both scoreSize and scoreCount:
//   [0, warning]             → [100, 75]   healthy zone
//   [warning, critical]      → [75,  30]   warning zone
//   [critical, 2× critical]  → [30,   0]   critical zone
//   beyond 2× critical       → clamped at 0
enum HealthScoring {

    // Maps a byte-size value to a 0-100 score using the piecewise thresholds.
    static func scoreSize(_ size: Int64, warning: Int64, critical: Int64) -> Int {
        guard size > 0, warning > 0, critical > warning else { return 100 }
        if size < warning {
            return Int(100.0 - Double(size) / Double(warning) * 25.0)
        } else if size < critical {
            let t = Double(size - warning) / Double(critical - warning)
            return Int(75.0 - t * 45.0)
        } else {
            let t = min(1.0, Double(size - critical) / Double(critical))
            return Int(30.0 - t * 30.0)
        }
    }

    // Maps an integer count to a 0-100 score using the same piecewise thresholds.
    static func scoreCount(_ count: Int, warning: Int, critical: Int) -> Int {
        guard count > 0, warning > 0, critical > warning else { return 100 }
        if count < warning {
            return Int(100.0 - Double(count) / Double(warning) * 25.0)
        } else if count < critical {
            let t = Double(count - warning) / Double(critical - warning)
            return Int(75.0 - t * 45.0)
        } else {
            let t = min(1.0, Double(count - critical) / Double(critical))
            return Int(30.0 - t * 30.0)
        }
    }

    // Converts a 0-100 score to a severity bucket.
    //   ≥ 75 → healthy   (green)
    //   ≥ 40 → warning   (orange)
    //   < 40 → critical  (red)
    static func severity(for score: Int) -> EnvironmentSeverity {
        if score >= 75 { return .healthy }
        if score >= 40 { return .warning }
        return .critical
    }

    // Weighted average of section scores. Uses each section's category weight from HealthThresholds.
    // Gracefully handles missing sections by normalizing against present weights only.
    static func weightedScore(sections: [EnvironmentHealthSection]) -> Int {
        var weightedSum = 0.0
        var totalWeight = 0.0
        for section in sections {
            let w = section.category.scoringWeight
            weightedSum += Double(section.score) * w
            totalWeight += w
        }
        guard totalWeight > 0 else { return 100 }
        return min(100, max(0, Int(weightedSum / totalWeight)))
    }

    // Returns the worst (highest) severity across an array of issues.
    static func aggregateSeverity(issues: [EnvironmentIssue]) -> EnvironmentSeverity {
        issues.map(\.severity).max() ?? .healthy
    }
}
