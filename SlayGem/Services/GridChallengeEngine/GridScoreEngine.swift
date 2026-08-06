//
//  GridScoreEngine.swift
//  SlayGem
//

import Foundation

enum GridScoreEngine {
  static let successScoreFloor = 58

  static func score() -> Int {
    let results = SwiftDataManager.shared.trainingResults
    guard !results.isEmpty else { return 0 }

    let recent = results.prefix(20)
    let avgScore = recent.map(\.score).reduce(0, +) / max(1, recent.count)
    let streak = SessionManager.shared.currentStreak
    let streakBonus = min(100, streak * 12)
    let searchBonus = gridSearchBonus()

    let raw = Double(avgScore) * 6.5 + Double(streakBonus) + searchBonus
    return min(1000, max(0, Int(raw.rounded())))
  }

  static func caption(for score: Int) -> String {
    switch score {
    case 850...: return "Grid master"
    case 650..<850: return "Sharp cells"
    case 350..<650: return "Matrix eye"
    default: return "Learning the grid"
    }
  }

  static func gridSearchScore(clearTimeMs: Int) -> Int {
    gentleSuccess(100 - Double(clearTimeMs - 15_000) / 200)
  }

  static func flipMatrixScore(moves: Int, parMoves: Int, won: Bool) -> Int {
    guard won else { return 0 }
    return gentleSuccess(100 - Double(moves - parMoves) * 8)
  }

  static func missingLinkScore(detectionMs: Int, correct: Bool) -> Int {
    guard correct else { return 0 }
    return gentleSuccess(100 - Double(detectionMs - 400) / 25)
  }

  static func gridWeightsScore(correct: Bool) -> Int {
    correct ? 100 : 0
  }

  static func memoryBlitzScore(correctCount: Int, patternSize: Int) -> Int {
    guard patternSize > 0 else { return 0 }
    let raw = Double(correctCount * 100) / Double(patternSize)
    return correctCount > 0 ? gentleSuccess(raw) : 0
  }

  static func blockFlowScore(elapsedMs: Int, won: Bool = true) -> Int {
    guard won else { return 0 }
    return gentleSuccess(100 - Double(elapsedMs) / 300)
  }

  static func deductionRowsScore(elapsedMs: Int, mistakes: Int, won: Bool = true) -> Int {
    guard won else { return 0 }
    return gentleSuccess(100 - Double(mistakes) * 15 - Double(elapsedMs) / 500)
  }

  static func slideFusionScore(highest: Int, goal: Int, moves: Int, won: Bool) -> Int {
    guard highest > 0 else { return 0 }
    if won { return 100 }
    let progress = min(1, Double(highest) / Double(max(goal, 1)))
    let movePenalty = min(25, moves / 8)
    return max(0, min(100, Int(progress * 100) - movePenalty))
  }

  private static func gentleSuccess(_ raw: Double) -> Int {
    min(100, max(successScoreFloor, Int(raw.rounded())))
  }

  private static func gridSearchBonus() -> Double {
    guard let best = ProfileActivityEngine.bestGridSearchMsToday() else { return 0 }
    return max(0, 80 - Double(best) / 400)
  }
}
