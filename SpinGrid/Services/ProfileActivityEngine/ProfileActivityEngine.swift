//
//  ProfileActivityEngine.swift
//  SpinGrid
//

import Foundation

enum ProfileActivityEngine {
  private static let storageKey = "spingrid.activityDays.v1"

  static func recordSession(on date: Date = .now) {
    var days = loadDays()
    let key = dayKey(for: date)
    if !days.contains(key) {
      days.append(key)
      days.sort()
      saveDays(days)
    }
  }

  static func currentStreak(reference: Date = .now) -> Int {
    let days = Set(loadDays())
    guard !days.isEmpty else { return 0 }

    let calendar = Calendar.current
    var streak = 0
    var cursor = calendar.startOfDay(for: reference)

    while days.contains(dayKey(for: cursor)) {
      streak += 1
      guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
      cursor = previous
    }
    return streak
  }

  static func bestGridSearchMsToday() -> Int? {
    let calendar = Calendar.current
    let results = SwiftDataManager.shared.results(for: TestType.gridSearch.rawValue)
      .filter { calendar.isDateInToday($0.date) }
    guard let best = results.map(\.primaryMetric).min() else { return nil }
    return Int(best)
  }

  private static func loadDays() -> [String] {
    UserDefaults.standard.stringArray(forKey: storageKey) ?? []
  }

  private static func saveDays(_ days: [String]) {
    UserDefaults.standard.set(days, forKey: storageKey)
  }

  private static func dayKey(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar.current
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
}
