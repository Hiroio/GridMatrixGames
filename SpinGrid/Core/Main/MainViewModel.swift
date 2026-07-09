//
//  MainViewModel.swift
//  SpinGrid
//

import Foundation

struct MainRecentSession {
  let title: String
  let subtitle: String
  let scoreText: String
}

@MainActor
@Observable
final class MainViewModel {
  var gridScore: Int { GridScoreEngine.score() }
  var gridCaption: String { GridScoreEngine.caption(for: gridScore) }
  var streak: Int { SessionManager.shared.currentStreak }
  var testsLeft: Int { SessionManager.shared.testsLeftToday }
  var gamesLeft: Int { SessionManager.shared.gamesLeftToday }

  var sessionsThisWeek: Int {
    let calendar = Calendar.current
    return SwiftDataManager.shared.trainingResults.filter {
      guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now) else { return false }
      return $0.date >= weekAgo
    }.count
  }

  var recentSession: MainRecentSession? {
    guard let last = SwiftDataManager.shared.trainingResults.first else { return nil }
    let title = activityTitle(for: last.activityType)
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    let when = formatter.localizedString(for: last.date, relativeTo: .now)
    return MainRecentSession(
      title: title,
      subtitle: when,
      scoreText: "\(last.score)%"
    )
  }

  private func activityTitle(for rawValue: String) -> String {
    if let test = TestType(rawValue: rawValue) {
      return test.title.replacingOccurrences(of: " Test", with: "")
    }
    if let game = GameType(rawValue: rawValue) {
      return game.title
    }
    return rawValue
  }
}
