//
//  SessionSupport.swift
//  SlayGem
//

import Foundation

enum GridSessionPhase: Equatable {
  case idle
  case playing
  case summary
}

enum AnswerFlashKind: Equatable {
  case correct
  case wrong
}

@MainActor
@Observable
final class GridRoundSession {
  var phase: GridSessionPhase = .idle
  var roundIndex = 0
  var roundCount = 1
  var sessionScore = 0
  var primaryMetric: Double = 0
  var answerFlash: AnswerFlashKind?

  func begin(roundCount: Int = 1) {
    phase = .playing
    roundIndex = 0
    self.roundCount = roundCount
    sessionScore = 0
    primaryMetric = 0
    answerFlash = nil
  }

  func reset() {
    phase = .idle
    roundIndex = 0
    roundCount = 1
    sessionScore = 0
    primaryMetric = 0
    answerFlash = nil
  }

  func flash(_ kind: AnswerFlashKind) {
    answerFlash = kind
    Task {
      try? await Task.sleep(for: .milliseconds(180))
      answerFlash = nil
    }
  }
}

enum SessionFinisher {
  @MainActor
  static func finish(
    activityType: String,
    score: Int,
    primaryMetric: Double,
    secondaryMetric: Double? = nil
  ) {
    SwiftDataManager.shared.saveTrainingResult(
      activityType: activityType,
      score: score,
      primaryMetric: primaryMetric,
      secondaryMetric: secondaryMetric
    )
    SoundManager.playGameComplete()
  }
}

struct SummaryMetric: Identifiable {
  let id = UUID()
  let label: String
  let value: String
  var isHighlight = false
}
