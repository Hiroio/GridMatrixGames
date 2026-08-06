//
//  MemoryBlitzTestViewModel.swift
//  SlayGem
//

import Foundation

enum MemoryBlitzPhase: Equatable {
  case idle
  case flash
  case recall
  case summary
}

@MainActor
@Observable
final class MemoryBlitzTestViewModel {
  private let gridSize = 4

  var session = GridRoundSession()
  var phase: MemoryBlitzPhase = .idle
  var pattern: Set<Int> = []
  var selected: Set<Int> = []
  var patternSize = 0
  var correctCount = 0
  private var flashTask: Task<Void, Never>?

  var isRunning: Bool { phase == .flash || phase == .recall }
  var answerFlash: AnswerFlashKind? { session.answerFlash }
  var finalScore: Int { session.sessionScore }

  var statusText: String {
    switch phase {
    case .idle: "Memorize the lit cells, then reproduce them"
    case .flash: "Watch the pattern…"
    case .recall: "Tap the cells you remember"
    case .summary: "Recall complete"
    }
  }

  func cellStates() -> [GridCellState] {
    (0..<(gridSize * gridSize)).map { index in
      switch phase {
      case .flash:
        return pattern.contains(index) ? .on : .off
      case .recall:
        if selected.contains(index) { return .selected }
        return .off
      case .summary:
        if pattern.contains(index) && selected.contains(index) { return .on }
        if pattern.contains(index) { return .path }
        if selected.contains(index) { return .wrongPick }
        return .off
      default:
        return .off
      }
    }
  }

  func start() async {
    guard SessionManager.shared.tryStartTest() else { return }
    await GridDataManager.shared.ensureLoaded()
    SessionManager.shared.consumeTestSession()

    if let challenge = GridChallengeEngine.memoryBlitzChallenge() {
      pattern = Set(challenge.patternIndices)
    } else {
      pattern = Set([1, 4, 6, 9].shuffled())
    }
    patternSize = pattern.count
    selected = []
    correctCount = 0
    session.begin(roundCount: 1)
    phase = .flash

    flashTask?.cancel()
    flashTask = Task {
      try? await Task.sleep(for: .milliseconds(1000))
      guard !Task.isCancelled else { return }
      phase = .recall
    }
  }

  func reset() {
    flashTask?.cancel()
    session.reset()
    phase = .idle
    pattern = []
    selected = []
    patternSize = 0
    correctCount = 0
  }

  func handleTap(at index: Int) {
    guard phase == .recall else { return }

    if selected.contains(index) {
      selected.remove(index)
    } else if selected.count < patternSize {
      selected.insert(index)
      SoundManager.playTap()
      HapticManager.light()
    }

    if selected.count == patternSize {
      finish()
    }
  }

  func confirmSelection() {
    guard phase == .recall, !selected.isEmpty else { return }
    finish()
  }

  private func finish() {
    correctCount = selected.intersection(pattern).count
    let score = GridScoreEngine.memoryBlitzScore(correctCount: correctCount, patternSize: patternSize)
    session.sessionScore = score
    session.primaryMetric = Double(correctCount)
    phase = .summary
    session.phase = .summary

    if score >= 70 {
      session.flash(.correct)
      SoundManager.playSuccess()
      HapticManager.success()
    } else {
      session.flash(.wrong)
      SoundManager.playWrong()
    }

    SessionFinisher.finish(
      activityType: TestType.memoryBlitz.rawValue,
      score: score,
      primaryMetric: Double(correctCount),
      secondaryMetric: Double(patternSize)
    )
  }
}
