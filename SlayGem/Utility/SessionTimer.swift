//
//  SessionTimer.swift
//  SlayGem
//

import Foundation

@MainActor
@Observable
final class SessionTimer {
  private(set) var elapsedMs = 0
  private var startedAt: Date?
  private var tickTask: Task<Void, Never>?

  var isRunning: Bool { tickTask != nil }

  func start() {
    guard tickTask == nil else { return }
    startedAt = .now
    elapsedMs = 0
    tickTask = Task {
      while !Task.isCancelled {
        if let startedAt {
          elapsedMs = Int(Date().timeIntervalSince(startedAt) * 1000)
        }
        try? await Task.sleep(for: .milliseconds(200))
      }
    }
  }

  func stop() {
    tickTask?.cancel()
    tickTask = nil
  }

  func reset() {
    stop()
    elapsedMs = 0
    startedAt = nil
  }

  var formatted: String {
    TimeFormat.secondsLabel(ms: elapsedMs)
  }
}
