//
//  StatsViewModel.swift
//  SlayGem
//

import Foundation
import SwiftUI

struct StatsActivityRow: Identifiable {
  let id: String
  let title: String
  let icon: String
  let metricLabel: String
  let bestText: String
  let lastText: String
  let sessions: Int
  let sparkValues: [CGFloat]
  let chartPeriodLabel: String
}

@MainActor
@Observable
final class StatsViewModel {
  var extendedCharts = false

  var gridScore: Int { GridScoreEngine.score() }
  var gridCaption: String { GridScoreEngine.caption(for: gridScore) }

  var weekActivity: [CGFloat] {
    let calendar = Calendar.current
    return (0..<7).reversed().map { offset in
      guard let day = calendar.date(byAdding: .day, value: -offset, to: .now) else { return 0 }
      let count = SwiftDataManager.shared.trainingResults.filter {
        calendar.isDate($0.date, inSameDayAs: day)
      }.count
      return CGFloat(count)
    }
  }

  var sessionsThisWeek: Int {
    Int(weekActivity.reduce(0, +))
  }

  var testRows: [StatsActivityRow] {
    TestType.allCases.map { row(for: $0) }
  }

  var gameRows: [StatsActivityRow] {
    GameType.allCases.map { row(for: $0) }
  }

  func exportCSV() -> String {
    var lines = ["activityType,score,primaryMetric,secondaryMetric,date"]
    for result in SwiftDataManager.shared.trainingResults {
      let secondary = result.secondaryMetric.map { String($0) } ?? ""
      let date = ISO8601DateFormatter().string(from: result.date)
      lines.append("\(result.activityType),\(result.score),\(result.primaryMetric),\(secondary),\(date)")
    }
    return lines.joined(separator: "\n")
  }

  private var chartDays: Int { extendedCharts ? 30 : 7 }
  private var chartPeriodLabel: String { extendedCharts ? "30-day activity" : "7-day activity" }

  private func row(for test: TestType) -> StatsActivityRow {
    let results = SwiftDataManager.shared.results(for: test.rawValue)
    return StatsActivityRow(
      id: test.rawValue,
      title: test.title.replacingOccurrences(of: " Test", with: ""),
      icon: test.icon,
      metricLabel: metricLabel(for: test),
      bestText: bestText(for: test, results: results),
      lastText: lastText(for: test, results: results),
      sessions: results.count,
      sparkValues: sparkline(for: test.rawValue),
      chartPeriodLabel: chartPeriodLabel
    )
  }

  private func row(for game: GameType) -> StatsActivityRow {
    let results = SwiftDataManager.shared.results(for: game.rawValue)
    return StatsActivityRow(
      id: game.rawValue,
      title: game.title,
      icon: game.icon,
      metricLabel: gameMetricLabel(for: game),
      bestText: bestGameText(for: game, results: results),
      lastText: lastGameText(for: game, results: results),
      sessions: results.count,
      sparkValues: sparkline(for: game.rawValue),
      chartPeriodLabel: chartPeriodLabel
    )
  }

  private func metricLabel(for test: TestType) -> String {
    switch test {
    case .gridSearch: "Fastest clear"
    case .missingLink: "Fastest detection"
    case .gridWeights: "Accuracy"
    case .memoryBlitz: "Best recall"
    }
  }

  private func gameMetricLabel(for game: GameType) -> String {
    switch game {
    case .flipMatrix: "Fewest moves"
    case .blockFlow, .deductionRows: "Best time"
    case .slideFusion: "Best score"
    }
  }

  private func bestText(for test: TestType, results: [TrainingResult]) -> String {
    guard !results.isEmpty else { return "—" }
    switch test {
    case .gridSearch:
      guard let ms = results.filter({ $0.score > 0 }).map(\.primaryMetric).min() else { return "—" }
      return formatSeconds(ms: Int(ms))
    case .missingLink:
      let correct = results.filter { ($0.secondaryMetric ?? 0) > 0 }
      guard let ms = correct.map(\.primaryMetric).min() else { return "—" }
      return formatSeconds(ms: Int(ms))
    case .gridWeights:
      let hits = results.filter { $0.primaryMetric > 0 }.count
      return results.isEmpty ? "—" : "\(hits)/\(results.count) correct"
    case .memoryBlitz:
      guard let best = results.map(\.score).max() else { return "—" }
      return "\(best)%"
    }
  }

  private func lastText(for test: TestType, results: [TrainingResult]) -> String {
    guard let last = results.first else { return "—" }
    switch test {
    case .gridSearch:
      return formatSeconds(ms: Int(last.primaryMetric))
    case .missingLink:
      if (last.secondaryMetric ?? 0) > 0 {
        return formatSeconds(ms: Int(last.primaryMetric))
      }
      return "Miss"
    case .gridWeights:
      return last.primaryMetric > 0 ? "Correct" : "Wrong"
    case .memoryBlitz:
      let total = Int(last.secondaryMetric ?? Double(last.primaryMetric))
      return "\(Int(last.primaryMetric))/\(max(1, total)) cells"
    }
  }

  private func bestGameText(for game: GameType, results: [TrainingResult]) -> String {
    let wins = results.filter { $0.score >= GridScoreEngine.successScoreFloor }
    switch game {
    case .flipMatrix:
      guard let moves = wins.map(\.primaryMetric).min() else { return "—" }
      return "\(Int(moves)) moves"
    case .blockFlow, .deductionRows:
      guard let ms = wins.map(\.primaryMetric).min() else { return "—" }
      return TimeFormat.secondsLabel(ms: Int(ms))
    case .slideFusion:
      guard let best = results.map(\.score).max() else { return "—" }
      return "\(best)%"
    }
  }

  private func lastGameText(for game: GameType, results: [TrainingResult]) -> String {
    guard let last = results.first else { return "—" }
    switch game {
    case .flipMatrix:
      return "\(Int(last.primaryMetric)) moves · \(last.score)%"
    case .blockFlow, .deductionRows:
      return "\(TimeFormat.secondsLabel(ms: Int(last.primaryMetric))) · \(last.score)%"
    case .slideFusion:
      return "\(last.score)%"
    }
  }

  private func formatSeconds(ms: Int) -> String {
    TimeFormat.secondsLabel(ms: ms)
  }

  private func sparkline(for activity: String) -> [CGFloat] {
    let calendar = Calendar.current
    let values = (0..<chartDays).reversed().map { offset -> CGFloat in
      guard let day = calendar.date(byAdding: .day, value: -offset, to: .now) else { return 0 }
      let dayResults = SwiftDataManager.shared.trainingResults.filter {
        $0.activityType == activity && calendar.isDate($0.date, inSameDayAs: day)
      }
      return CGFloat(dayResults.count)
    }
    let maxVal = values.max() ?? 1
    return values.map { $0 / max(maxVal, 1) }
  }
}
