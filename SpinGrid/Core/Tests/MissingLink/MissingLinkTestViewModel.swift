//
//  MissingLinkTestViewModel.swift
//  SpinGrid
//

import Foundation

enum MissingLinkPhase: Equatable {
  case idle
  case preview
  case playing
  case reveal
  case summary
}

@MainActor
@Observable
final class MissingLinkTestViewModel {
  var session = GridRoundSession()
  var phase: MissingLinkPhase = .idle
  var challenge: MissingLinkChallenge?
  var detectionMs = 0
  var wasCorrect = false
  var wrongTapIndex: Int?
  var lastTappedIndex: Int?

  private var startTime: Date?
  private var previewTask: Task<Void, Never>?
  private var timerTask: Task<Void, Never>?
  private var tickTask: Task<Void, Never>?
  private var wrongTapTask: Task<Void, Never>?
  private var acceptsInput = false
  private var timerTick = 0

  private let previewDurationMs = 1_600
  private let timeLimitMs = 4_500

  var gridSize: Int { challenge?.gridSize ?? 5 }
  var pathIndices: [Int] { challenge?.pathIndices ?? [] }
  var gapIndex: Int { challenge?.gapIndex ?? 0 }
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
    case .idle: "Find the one cell that completes the path"
    case .preview: "Follow the glowing trail…"
    case .playing: "Tap the broken link — \(remainingSecondsText)"
    case .reveal: wasCorrect ? "Link restored" : "The gap was here"
    case .summary: wasCorrect ? "Sharp eye" : "Keep tracing the path"
    }
  }

  private var remainingSecondsText: String {
    guard let startTime else { return "4.5s" }
    let left = max(0, Double(timeLimitMs) / 1000 - Date().timeIntervalSince(startTime))
    return String(format: "%.1fs", left)
  }

  func start() async {
    guard SessionManager.shared.tryStartTest() else { return }
    await GridDataManager.shared.ensureLoaded()
    SessionManager.shared.consumeTestSession()
    guard let challenge = GridChallengeEngine.missingLinkChallenge() else { return }

    cancelTasks()
    self.challenge = challenge
    wasCorrect = false
    detectionMs = 0
    wrongTapIndex = nil
    lastTappedIndex = nil
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
    detectionMs = 0
    wasCorrect = false
    wrongTapIndex = nil
    lastTappedIndex = nil
    startTime = nil
    acceptsInput = false
  }

  func handleTap(at index: Int) {
    guard phase == .playing, let challenge, acceptsInput else { return }

    if index == challenge.gapIndex {
      finish(correct: true, tappedIndex: index)
      return
    }

    registerWrongTap(at: index)
  }

  private func beginAnswerWindow() {
    phase = .playing
    startTime = .now
    acceptsInput = false

    startTimerTicks()
    timerTask = Task {
      try? await Task.sleep(for: .milliseconds(timeLimitMs))
      guard !Task.isCancelled, phase == .playing else { return }
      finish(correct: false, tappedIndex: nil)
    }

    Task {
      try? await Task.sleep(for: .milliseconds(200))
      guard phase == .playing else { return }
      acceptsInput = true
    }
  }

  private func registerWrongTap(at index: Int) {
    wrongTapIndex = index
    lastTappedIndex = index
    session.flash(.wrong)
    SoundManager.playWrong()
    HapticManager.light()

    wrongTapTask?.cancel()
    wrongTapTask = Task {
      try? await Task.sleep(for: .milliseconds(320))
      guard !Task.isCancelled else { return }
      wrongTapIndex = nil
    }
  }

  private func finish(correct: Bool, tappedIndex: Int?) {
    guard phase == .playing else { return }
    cancelTasks()

    if let startTime {
      detectionMs = Int(Date().timeIntervalSince(startTime) * 1000)
    } else {
      detectionMs = timeLimitMs
    }

    wasCorrect = correct
    lastTappedIndex = tappedIndex
    phase = .reveal

    Task {
      try? await Task.sleep(for: .milliseconds(correct ? 700 : 1_200))
      guard !Task.isCancelled else { return }
      completeSummary()
    }
  }

  private func completeSummary() {
    let score = GridScoreEngine.missingLinkScore(detectionMs: detectionMs, correct: wasCorrect)
    session.sessionScore = score
    session.primaryMetric = Double(detectionMs)
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
      activityType: TestType.missingLink.rawValue,
      score: score,
      primaryMetric: Double(detectionMs),
      secondaryMetric: wasCorrect ? 1 : 0
    )
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

  private func cancelTasks() {
    previewTask?.cancel()
    timerTask?.cancel()
    tickTask?.cancel()
    wrongTapTask?.cancel()
    previewTask = nil
    timerTask = nil
    tickTask = nil
    wrongTapTask = nil
  }
}
