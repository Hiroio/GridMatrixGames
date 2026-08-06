//
//  SwiftDataManager.swift
//  SlayGem
//

import Foundation
import SwiftData

@MainActor
@Observable
final class SwiftDataManager {
  static let shared = SwiftDataManager()

  let modelContainer: ModelContainer
  private(set) var trainingResults: [TrainingResult] = []

  private init() {
    do {
      modelContainer = try ModelContainer(for: TrainingResult.self)
    } catch {
      fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
    }
  }

  func configure(modelContext: ModelContext) {
    refreshData(using: modelContext)
  }

  func refreshData(using modelContext: ModelContext? = nil) {
    let context = modelContext ?? modelContainer.mainContext
    let descriptor = FetchDescriptor<TrainingResult>(
      sortBy: [SortDescriptor(\.date, order: .reverse)]
    )
    trainingResults = (try? context.fetch(descriptor)) ?? []
  }

  func saveTrainingResult(
    activityType: String,
    score: Int,
    primaryMetric: Double,
    secondaryMetric: Double? = nil,
    date: Date = .now
  ) {
    let context = modelContainer.mainContext
    let result = TrainingResult(
      activityType: activityType,
      score: score,
      primaryMetric: primaryMetric,
      secondaryMetric: secondaryMetric,
      date: date
    )
    context.insert(result)
    try? context.save()
    refreshData(using: context)
    ProfileActivityEngine.recordSession(on: date)
  }

  func results(for activityType: String) -> [TrainingResult] {
    trainingResults.filter { $0.activityType == activityType }
  }
}
