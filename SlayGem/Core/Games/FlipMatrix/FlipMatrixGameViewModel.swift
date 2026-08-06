//
//  FlipMatrixGameViewModel.swift
//  SlayGem
//

import Foundation
import SwiftUI

enum FlipMatrixPhase: Equatable {
  case idle
  case playing
  case summary
}

@MainActor
@Observable
final class FlipMatrixGameViewModel {
  var session = GridRoundSession()
  var timer = SessionTimer()
  var phase: FlipMatrixPhase = .idle
  var challenge: FlipMatrixChallenge?
  var cellStates: [Bool] = []
  var moves = 0
  var won = false
  var selectedDifficulty: GridDifficulty = .easy

  var gridSize: Int { challenge?.size ?? 3 }
  var isRunning: Bool { phase == .playing }
  var answerFlash: AnswerFlashKind? { session.answerFlash }
  var finalScore: Int { session.sessionScore }

  var statusText: String {
    switch phase {
    case .idle: "Tap cells to toggle lights and neighbors"
    case .playing: won ? "All lights out!" : "Extinguish every yellow cell"
    case .summary: "Puzzle complete"
    }
  }

  var displayStates: [GridCellState] {
    cellStates.map { $0 ? .on : .off }
  }

  func start(difficulty: GridDifficulty) {
    guard SessionManager.shared.tryStartGame() else { return }
    SessionManager.shared.consumeGameSession()
    selectedDifficulty = GridChallengeEngine.resolvedDifficulty(
      difficulty,
      premium: StoreKitManager.shared.isPremium
    )

    guard let challenge = GridChallengeEngine.flipMatrixChallenge(
      premium: StoreKitManager.shared.isPremium,
      difficulty: selectedDifficulty
    ) else { return }

    self.challenge = challenge
    let count = challenge.size * challenge.size
    cellStates = (0..<count).map { challenge.initialOn.contains($0) }
    moves = 0
    won = false
    session.begin(roundCount: 1)
    phase = .playing
    timer.start()
  }

  func reset() {
    timer.reset()
    session.reset()
    phase = .idle
    challenge = nil
    cellStates = []
    moves = 0
    won = false
  }

  func handleTap(at index: Int) {
    guard phase == .playing, let challenge else { return }
    withAnimation(AppDesign.gridCellSpring) {
      GridIndexMath.toggleLights(at: index, size: challenge.size, states: &cellStates)
      moves += 1
    }
    SoundManager.playTap()
    HapticManager.light()

    if cellStates.allSatisfy({ !$0 }) {
      won = true
      finish()
    } else if let maxMoves = maxMovesAllowed, moves >= maxMoves {
      fail()
    }
  }

  var movesRemaining: Int? {
    guard let maxMoves = maxMovesAllowed else { return nil }
    return max(0, maxMoves - moves)
  }

  private var maxMovesAllowed: Int? {
    FlipMatrixEngine.maxMoves(for: selectedDifficulty)
  }

  private func finish() {
    timer.stop()
    guard let challenge else { return }
    let score = GridScoreEngine.flipMatrixScore(moves: moves, parMoves: challenge.parMoves, won: true)
    session.sessionScore = score
    session.primaryMetric = Double(moves)
    phase = .summary
    session.phase = .summary
    SoundManager.playSuccess()
    HapticManager.success()
    SessionFinisher.finish(
      activityType: GameType.flipMatrix.rawValue,
      score: score,
      primaryMetric: Double(moves),
      secondaryMetric: Double(challenge.parMoves)
    )
  }

  private func fail() {
    timer.stop()
    session.sessionScore = 0
    session.primaryMetric = Double(moves)
    phase = .summary
    session.phase = .summary
    session.flash(.wrong)
    SoundManager.playWrong()
    SessionFinisher.finish(
      activityType: GameType.flipMatrix.rawValue,
      score: 0,
      primaryMetric: Double(moves)
    )
  }
}
