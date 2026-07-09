//
//  NavigationManager.swift
//  SpinGrid
//

import Foundation

@MainActor
@Observable
final class NavigationManager {
  static let shared = NavigationManager()

  var mainScreen: MainScreensEnum = .main
  var secondaryScreen: SecondaryScreensEnum?
  var activeTest: TestType?
  var activeGame: GameType?

  private init() {}

  var activityOverlayToken: String {
    if let activeGame { return "game-\(activeGame.rawValue)" }
    if let activeTest { return "test-\(activeTest.rawValue)" }
    if let secondaryScreen { return "secondary-\(secondaryScreen.id)" }
    return "none"
  }

  func selectTab(_ screen: MainScreensEnum) {
    mainScreen = screen
  }

  func openSecondary(_ screen: SecondaryScreensEnum) {
    secondaryScreen = screen
  }

  func closeSecondary() {
    secondaryScreen = nil
  }

  func openStats() {
    selectTab(.stats)
  }

  func openTest(_ type: TestType) {
    activeGame = nil
    activeTest = type
  }

  func closeTest() {
    activeTest = nil
  }

  func openGame(_ type: GameType) {
    activeTest = nil
    activeGame = type
  }

  func closeGame() {
    activeGame = nil
  }
}
