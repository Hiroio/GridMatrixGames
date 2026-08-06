//
//  GridSearchTestViewModel.swift
//  SlayGem
//

import Foundation

enum GridSearchPhase: Equatable {
  case idle
  case preview
  case playing
  case summary
}

@MainActor
@Observable
final class GridSearchTestViewModel {
  private let gridSize = 4

  var session = GridRoundSession()
  var phase: GridSearchPhase = .idle
  var numbers: [Int] = []
  var nextTarget = 1
  var clearTimeMs = 0
  private var startTime: Date?
  private var previewTask: Task<Void, Never>?

  var isRunning: Bool { phase == .preview || phase == .playing }
  var answerFlash: AnswerFlashKind? { session.answerFlash }
  var finalScore: Int { session.sessionScore }

  var statusText: String {
    switch phase {
    case .idle: "Tap numbers from 1 to 16 as fast as you can"
    case .preview: "Remember where 1 is"
    case .playing: "Find the next number"
    case .summary: "Session complete"
    }
  }

  var cellStates: [GridCellState] {
    (0..<(gridSize * gridSize)).map { index in
      let value = numbers[safe: index] ?? 0
      if value < nextTarget { return .done }
      if value == nextTarget && phase != .idle { return .target }
      return .off
    }
  }

  var cellLabels: [String?] {
    numbers.map { "\($0)" }
  }

  func start() {
    guard SessionManager.shared.tryStartTest() else { return }
    SessionManager.shared.consumeTestSession()

    numbers = Array(1...16).shuffled()
    nextTarget = 1
    clearTimeMs = 0
    session.begin(roundCount: 1)
    phase = .preview

    previewTask?.cancel()
    previewTask = Task {
      try? await Task.sleep(for: .milliseconds(500))
      guard !Task.isCancelled else { return }
      startTimer()
      phase = .playing
    }
  }

  func reset() {
    previewTask?.cancel()
    session.reset()
    phase = .idle
    numbers = []
    nextTarget = 1
    clearTimeMs = 0
    startTime = nil
  }

  func handleTap(at index: Int) {
    guard phase == .playing, index < numbers.count else { return }
    let value = numbers[index]

    if value == nextTarget {
      SoundManager.playTap()
      HapticManager.light()
      nextTarget += 1

      if nextTarget > gridSize * gridSize {
        finish()
      }
    } else {
      session.flash(.wrong)
      HapticManager.medium()
      SoundManager.playWrong()
    }
  }

  private func startTimer() {
    startTime = .now
  }

  private func finish() {
    if let startTime {
      clearTimeMs = Int(Date().timeIntervalSince(startTime) * 1000)
    }
    let score = GridScoreEngine.gridSearchScore(clearTimeMs: clearTimeMs)
    session.sessionScore = score
    session.primaryMetric = Double(clearTimeMs)
    phase = .summary
    session.phase = .summary
    SoundManager.playSuccess()
    HapticManager.success()
    SessionFinisher.finish(
      activityType: TestType.gridSearch.rawValue,
      score: score,
      primaryMetric: Double(clearTimeMs)
    )
  }
}

private extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
