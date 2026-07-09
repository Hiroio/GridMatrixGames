//
//  TrainingResult.swift
//  SpinGrid
//

import Foundation
import SwiftData

@Model
final class TrainingResult {
  var id: UUID
  var activityType: String
  var score: Int
  var primaryMetric: Double
  var secondaryMetric: Double?
  var date: Date

  init(
    id: UUID = UUID(),
    activityType: String,
    score: Int,
    primaryMetric: Double,
    secondaryMetric: Double? = nil,
    date: Date = .now
  ) {
    self.id = id
    self.activityType = activityType
    self.score = score
    self.primaryMetric = primaryMetric
    self.secondaryMetric = secondaryMetric
    self.date = date
  }
}
