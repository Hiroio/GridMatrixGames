//
//  GridWeightsTestViewModel.swift
//  SlayGem
//

import Foundation

enum GridWeightsPhase: Equatable {
  case idle
  case preview
  case playing
  case reveal
  case summary
}

@MainActor
@Observable
final class GridWeightsTestViewModel {
  var session = GridRoundSession()
  var phase: GridWeightsPhase = .idle
  var challenge: GridWeightsChallenge?
  var pickedLeft: Bool?
  var wasCorrect = false
  var reactionMs = 0

  private var startTime: Date?
  private var previewTask: Task<Void, Never>?
  private var timerTask: Task<Void, Never>?
  private var tickTask: Task<Void, Never>?
  private var acceptsInput = false
  private var timerTick = 0

  private let previewDurationMs = 1_200
  private let timeLimitMs = 3_000

  var isRunning: Bool { phase == .preview || phase == .playing }
  var answerFlash: AnswerFlashKind? { session.answerFlash }
  var finalScore: Int { session.sessionScore }

  var timerProgress: CGFloat {
    _ = timerTick
    guard phase == .playing, let startTime else { return 0 }
    let elapsed = Date().timeIntervalSince(startTime)
    return min(1, CGFloat(elapsed / (Double(timeLimitMs) / 1000)))
  }

  var statusText: String {
    switch phase {
    case .idle: "Which side has more filled cells?"
    case .preview: "Study both sides…"
    case .playing: "Left or Right — \(remainingSecondsText)"
    case .reveal: "Here's the real weight"
    case .summary: wasCorrect ? "Correct side" : "Wrong side"
    }
  }

  private var remainingSecondsText: String {
    guard let startTime else { return TimeFormat.secondsLabel(ms: 4500) }
    let left = max(0, Double(timeLimitMs) / 1000 - Date().timeIntervalSince(startTime))
    return TimeFormat.secondsLabel(ms: Int((left * 1000).rounded()))
  }

  func leftStates() -> [GridCellState] {
    states(for: challenge?.leftFilled ?? [], size: 3)
  }

  func rightStates() -> [GridCellState] {
    states(for: challenge?.rightFilled ?? [], size: 3)
  }

  func start() async {
    guard SessionManager.shared.tryStartTest() else { return }
    await GridDataManager.shared.ensureLoaded()
    SessionManager.shared.consumeTestSession()
    guard let challenge = GridChallengeEngine.gridWeightsChallenge() else { return }

    cancelTasks()
    self.challenge = challenge
    pickedLeft = nil
    wasCorrect = false
    reactionMs = 0
    startTime = nil
    acceptsInput = false
    session.begin(roundCount: 1)
    phase = .preview

    previewTask = Task {
      try? await Task.sleep(for: .milliseconds(previewDurationMs))
      guard !Task.isCancelled, phase == .preview else { return }
      beginAnswerWindow()
    }
  }

  func reset() {
    cancelTasks()
    session.reset()
    phase = .idle
    challenge = nil
    pickedLeft = nil
    wasCorrect = false
    reactionMs = 0
    startTime = nil
    acceptsInput = false
  }

  func pickLeft() { answer(pickedLeft: true) }
  func pickRight() { answer(pickedLeft: false) }

  private func beginAnswerWindow() {
    phase = .playing
    startTime = .now
    acceptsInput = false

    startTimerTicks()
    timerTask = Task {
      try? await Task.sleep(for: .milliseconds(timeLimitMs))
      guard !Task.isCancelled, phase == .playing else { return }
      answer(pickedLeft: nil)
    }

    Task {
      try? await Task.sleep(for: .milliseconds(180))
      guard phase == .playing else { return }
      acceptsInput = true
    }
  }

  private func startTimerTicks() {
    tickTask?.cancel()
    tickTask = Task {
      while !Task.isCancelled, phase == .playing {
        timerTick &+= 1
        try? await Task.sleep(for: .milliseconds(50))
      }
    }
  }

  private func answer(pickedLeft: Bool?) {
    guard phase == .playing, let challenge, let startTime else { return }
    if pickedLeft != nil, !acceptsInput { return }

    cancelTasks()
    reactionMs = Int(Date().timeIntervalSince(startTime) * 1000)
    self.pickedLeft = pickedLeft

    let leftCount = challenge.leftFilled.count
    let rightCount = challenge.rightFilled.count
    let heavierLeft = leftCount > rightCount

    if let pickedLeft {
      wasCorrect = pickedLeft == heavierLeft
    } else {
      wasCorrect = false
    }

    phase = .reveal
    Task {
      try? await Task.sleep(for: .milliseconds(900))
      guard !Task.isCancelled else { return }
      completeSummary()
    }
  }

  private func completeSummary() {
    let score = GridScoreEngine.gridWeightsScore(correct: wasCorrect)
    session.sessionScore = score
    session.primaryMetric = wasCorrect ? 1 : 0
    phase = .summary
    session.phase = .summary

    if wasCorrect {
      session.flash(.correct)
      SoundManager.playSuccess()
      HapticManager.success()
    } else {
      session.flash(.wrong)
      SoundManager.playWrong()
      HapticManager.error()
    }

    SessionFinisher.finish(
      activityType: TestType.gridWeights.rawValue,
      score: score,
      primaryMetric: wasCorrect ? 1 : 0,
      secondaryMetric: Double(reactionMs)
    )
  }

  private func cancelTasks() {
    previewTask?.cancel()
    timerTask?.cancel()
    tickTask?.cancel()
    previewTask = nil
    timerTask = nil
    tickTask = nil
  }

  private func states(for filled: [Int], size: Int) -> [GridCellState] {
    (0..<(size * size)).map { filled.contains($0) ? .on : .off }
  }
}
