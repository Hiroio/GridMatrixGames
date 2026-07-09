//
//  SessionManager.swift
//  SpinGrid
//

import Foundation

@MainActor
@Observable
final class SessionManager {
  static let shared = SessionManager()

  private let storageKey = "spingrid.dailySessions.v1"
  private let store = StoreKitManager.shared

  private init() {}

  var gamesPlayedToday: Int { dailyRecord().gameCount }
  var testsPlayedToday: Int { dailyRecord().testCount }
  var gamesLeftToday: Int { max(0, AppLimits.freeGamesPerDay - gamesPlayedToday) }
  var testsLeftToday: Int { max(0, AppLimits.freeTestsPerDay - testsPlayedToday) }
  var currentStreak: Int { ProfileActivityEngine.currentStreak() }

  func canStartGame() -> Bool {
    store.isPremium || gamesPlayedToday < AppLimits.freeGamesPerDay
  }

  func canStartTest() -> Bool {
    store.isPremium || testsPlayedToday < AppLimits.freeTestsPerDay
  }

  @discardableResult
  func tryStartGame() -> Bool {
    guard canStartGame() else {
      SoundManager.playLimitBlocked()
      store.statusMessage = "You've used today's free game sessions. Upgrade for unlimited play."
      store.presentPaywall()
      return false
    }
    return true
  }

  @discardableResult
  func tryStartTest() -> Bool {
    guard canStartTest() else {
      SoundManager.playLimitBlocked()
      store.statusMessage = "You've used today's free test sessions. Upgrade for unlimited play."
      store.presentPaywall()
      return false
    }
    return true
  }

  func consumeGameSession() {
    guard !store.isPremium else { return }
    var record = dailyRecord()
    record.gameCount += 1
    saveDailyRecord(record)
  }

  func consumeTestSession() {
    guard !store.isPremium else { return }
    var record = dailyRecord()
    record.testCount += 1
    saveDailyRecord(record)
  }

  private struct DailyRecord: Codable {
    var dayKey: String
    var gameCount: Int
    var testCount: Int
  }

  private func dailyRecord() -> DailyRecord {
    let todayKey = Self.dayKey(for: .now)
    guard
      let data = UserDefaults.standard.data(forKey: storageKey),
      let decoded = try? JSONDecoder().decode(DailyRecord.self, from: data),
      decoded.dayKey == todayKey
    else {
      return DailyRecord(dayKey: todayKey, gameCount: 0, testCount: 0)
    }
    return decoded
  }

  private func saveDailyRecord(_ record: DailyRecord) {
    guard let data = try? JSONEncoder().encode(record) else { return }
    UserDefaults.standard.set(data, forKey: storageKey)
  }

  private static func dayKey(for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar.current
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
}
