//
//  SlideFusionGameViewModel.swift
//  SpinGrid
//

import Foundation
import SwiftUI

enum SlideFusionPhase: Equatable {
  case idle
  case playing
  case summary
}

@MainActor
@Observable
final class SlideFusionGameViewModel {
  var session = GridRoundSession()
  var phase: SlideFusionPhase = .idle
  var challenge: SlideFusionChallenge?
  var tiles: [Int] = []
  var moves = 0
  var reachedGoal = false
  var selectedDifficulty: GridDifficulty = .easy

  var gridSize: Int { challenge?.size ?? SlideFusionEngine.gridSize(for: selectedDifficulty) }
  var blocked: Set<Int> { Set(challenge?.blockedIndices ?? []) }
  var isRunning: Bool { phase == .playing }
  var answerFlash: AnswerFlashKind? { session.answerFlash }
  var finalScore: Int { session.sessionScore }

  var highestValue: Int {
    SlideFusionEngine.highestValue(in: tiles, blocked: blocked)
  }

  var goalValue: Int {
    challenge?.goalValue ?? SlideFusionEngine.defaultGoal
  }

  var statusText: String {
    switch phase {
    case .idle: "Swipe to merge tiles like 2048"
    case .playing:
      if reachedGoal {
        "You reached \(goalValue) — keep going!"
      } else if !SlideFusionEngine.hasMoves(tiles: tiles, blocked: blocked, size: gridSize) {
        "No moves left — end session when ready"
      } else {
        "Merge matching numbers"
      }
    case .summary:
      reachedGoal ? "You reached \(goalValue)!" : "Session complete"
    }
  }

  var summaryMetricText: String {
    if reachedGoal {
      "Reached \(goalValue) in \(moves) moves"
    } else {
      "Best tile \(highestValue) · \(moves) moves"
    }
  }

  func start(difficulty: GridDifficulty) {
    guard StoreKitManager.shared.requirePremium() else { return }
    guard SessionManager.shared.tryStartGame() else { return }
    SessionManager.shared.consumeGameSession()
    selectedDifficulty = difficulty
    guard let challenge = GridChallengeEngine.slideFusionChallenge(
      premium: StoreKitManager.shared.isPremium,
      difficulty: selectedDifficulty
    ) else { return }

    self.challenge = challenge
    let count = challenge.size * challenge.size
    tiles = Array(repeating: 0, count: count)
    moves = 0
    reachedGoal = false
    session.begin(roundCount: 1)
    phase = .playing
    SlideFusionEngine.spawn(into: &tiles, blocked: blocked)
    SlideFusionEngine.spawn(into: &tiles, blocked: blocked)
  }

  func reset() {
    session.reset()
    phase = .idle
    challenge = nil
    tiles = []
    moves = 0
    reachedGoal = false
  }

  @discardableResult
  func swipe(_ direction: SlideDirection) -> Bool {
    guard phase == .playing, let challenge else { return false }
    var copy = tiles
    guard SlideFusionEngine.move(tiles: &copy, blocked: blocked, size: challenge.size, direction: direction) else {
      HapticManager.medium()
      return false
    }

    withAnimation(AppDesign.gridCellSpring) {
      tiles = copy
      moves += 1
      SlideFusionEngine.spawn(into: &tiles, blocked: blocked)
    }
    SoundManager.playTap()
    HapticManager.light()

    if !reachedGoal, SlideFusionEngine.isWin(tiles: tiles, goalValue: challenge.goalValue) {
      reachedGoal = true
      session.flash(.correct)
      SoundManager.playSuccess()
      HapticManager.success()
    }

    return true
  }

  func endSession() {
    guard phase == .playing, let challenge else { return }

    let score = GridScoreEngine.slideFusionScore(
      highest: highestValue,
      goal: challenge.goalValue,
      moves: moves,
      won: reachedGoal
    )
    session.sessionScore = score
    session.primaryMetric = Double(highestValue)
    phase = .summary
    session.phase = .summary

    if reachedGoal {
      SoundManager.playSuccess()
      HapticManager.success()
    } else {
      HapticManager.light()
    }

    SessionFinisher.finish(
      activityType: GameType.slideFusion.rawValue,
      score: score,
      primaryMetric: Double(highestValue),
      secondaryMetric: Double(moves)
    )
  }

  func cellState(at index: Int) -> GridCellState {
    if blocked.contains(index) { return .blocked }
    guard tiles.indices.contains(index) else { return .off }
    return tiles[index] > 0 ? .on : .off
  }

  func cellLabel(at index: Int) -> String? {
    if blocked.contains(index) { return nil }
    guard tiles.indices.contains(index) else { return nil }
    let value = tiles[index]
    return value > 0 ? "\(value)" : nil
  }

  var isBoardReady: Bool {
    let count = gridSize * gridSize
    return count > 0 && tiles.count == count
  }
}
