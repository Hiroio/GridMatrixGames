//
//  DeductionRowsGameViewModel.swift
//  SlayGem
//

import Foundation

enum DeductionCellMark: Equatable {
  case empty
  case filled
  case marked
}

enum DeductionRowsPhase: Equatable {
  case idle
  case playing
  case summary
}

@MainActor
@Observable
final class DeductionRowsGameViewModel {
  var session = GridRoundSession()
  var timer = SessionTimer()
  var phase: DeductionRowsPhase = .idle
  var challenge: DeductionRowsChallenge?
  var cells: [DeductionCellMark] = []
  var mistakes = 0
  var selectedDifficulty: GridDifficulty = .easy

  var gridSize: Int { challenge?.size ?? 3 }
  var isRunning: Bool { phase == .playing }
  var answerFlash: AnswerFlashKind? { session.answerFlash }
  var finalScore: Int { session.sessionScore }

  var statusText: String {
    switch phase {
    case .idle: "Fill cells using row and column clues"
    case .playing: "Tap to fill · long press to mark"
    case .summary: "Puzzle solved"
    }
  }

  func start(difficulty: GridDifficulty) {
    guard SessionManager.shared.tryStartGame() else { return }
    SessionManager.shared.consumeGameSession()
    selectedDifficulty = GridChallengeEngine.resolvedDifficulty(
      difficulty,
      premium: StoreKitManager.shared.isPremium
    )
    guard let challenge = GridChallengeEngine.deductionRowsChallenge(
      premium: StoreKitManager.shared.isPremium,
      difficulty: selectedDifficulty
    ) else { return }

    self.challenge = challenge
    cells = Array(repeating: .empty, count: challenge.size * challenge.size)
    mistakes = 0
    session.begin(roundCount: 1)
    phase = .playing
    timer.start()
  }

  func reset() {
    timer.reset()
    session.reset()
    phase = .idle
    challenge = nil
    cells = []
    mistakes = 0
  }

  func toggleFill(at index: Int) {
    guard phase == .playing, cells.indices.contains(index) else { return }
    switch cells[index] {
    case .empty: cells[index] = .filled
    case .filled: cells[index] = .empty
    case .marked: cells[index] = .filled
    }
    SoundManager.playTap()
    HapticManager.light()
  }

  func toggleMark(at index: Int) {
    guard phase == .playing, cells.indices.contains(index) else { return }
    switch cells[index] {
    case .empty, .filled: cells[index] = .marked
    case .marked: cells[index] = .empty
    }
    HapticManager.medium()
  }

  func checkSolution() {
    guard phase == .playing, let challenge else { return }
    let target = challenge.solution
    var wrong = 0
    for index in cells.indices {
      let shouldFill = target[index] == 1
      let isFilled = cells[index] == .filled
      if shouldFill != isFilled { wrong += 1 }
    }

    if wrong == 0 {
      finish()
    } else {
      mistakes += 1
      session.flash(.wrong)
      SoundManager.playWrong()
      HapticManager.error()
    }
  }

  func gridCellState(at index: Int) -> GridCellState {
    switch cells[safe: index] ?? .empty {
    case .empty: .off
    case .filled: .on
    case .marked: .mark
    }
  }

  private func finish() {
    timer.stop()
    let score = GridScoreEngine.deductionRowsScore(elapsedMs: timer.elapsedMs, mistakes: mistakes)
    session.sessionScore = score
    session.primaryMetric = Double(timer.elapsedMs)
    phase = .summary
    session.phase = .summary
    SoundManager.playSuccess()
    HapticManager.success()
    SessionFinisher.finish(
      activityType: GameType.deductionRows.rawValue,
      score: score,
      primaryMetric: Double(timer.elapsedMs),
      secondaryMetric: Double(mistakes)
    )
  }
}

private extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
