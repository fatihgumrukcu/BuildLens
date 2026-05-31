import Foundation

// Persists health score snapshots across sessions using UserDefaults.
// One snapshot per calendar day (latest scan wins). Keeps up to 90 entries.
struct HealthHistoryService: Sendable {

    private static let defaultsKey = "buildlens.health.history"
    private static let maxEntries  = 90

    static func append(score: Int, status: EnvironmentSeverity) {
        var history = load()
        history.append(HealthSnapshot(score: score, status: status))
        history = deduplicated(history)
        if history.count > maxEntries {
            history = Array(history.suffix(maxEntries))
        }
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    static func load() -> [HealthSnapshot] {
        guard
            let data  = UserDefaults.standard.data(forKey: defaultsKey),
            let items = try? JSONDecoder().decode([HealthSnapshot].self, from: data)
        else { return [] }
        return items.sorted { $0.date < $1.date }
    }

    // Keeps only the latest snapshot per calendar day.
    private static func deduplicated(_ items: [HealthSnapshot]) -> [HealthSnapshot] {
        let cal = Calendar.current
        var byDay: [DateComponents: HealthSnapshot] = [:]
        for item in items {
            let key = cal.dateComponents([.year, .month, .day], from: item.date)
            if let existing = byDay[key] {
                byDay[key] = item.date > existing.date ? item : existing
            } else {
                byDay[key] = item
            }
        }
        return byDay.values.sorted { $0.date < $1.date }
    }
}
