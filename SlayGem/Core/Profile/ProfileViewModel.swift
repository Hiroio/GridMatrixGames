//
//  ProfileViewModel.swift
//  SlayGem
//

import Foundation

@MainActor
@Observable
final class ProfileViewModel {
  var testsPlayed: Int {
    TestType.allCases.reduce(0) { partial, test in
      partial + SwiftDataManager.shared.results(for: test.rawValue).count
    }
  }

  var gamesPlayed: Int {
    GameType.allCases.reduce(0) { partial, game in
      partial + SwiftDataManager.shared.results(for: game.rawValue).count
    }
  }

  var todayStreak: Int {
    SessionManager.shared.currentStreak
  }
}
