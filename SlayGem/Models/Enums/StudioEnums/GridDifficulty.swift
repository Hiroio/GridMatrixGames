//
//  GridDifficulty.swift
//  SlayGem
//

import Foundation

enum GridDifficulty: String, CaseIterable, Identifiable, Codable {
  case easy
  case medium
  case hard

  var id: String { rawValue }

  var title: String {
    switch self {
    case .easy: "Easy"
    case .medium: "Medium"
    case .hard: "Hard"
    }
  }

  var gridLabel: String {
    switch self {
    case .easy: "3×3"
    case .medium: "4×4"
    case .hard: "5×5"
    }
  }
}
