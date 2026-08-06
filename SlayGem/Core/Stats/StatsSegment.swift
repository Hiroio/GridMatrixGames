//
//  StatsSegment.swift
//  SlayGem
//

import Foundation

enum StatsSegment: String, CaseIterable, Identifiable {
  case tests
  case games

  var id: String { rawValue }

  var title: String {
    switch self {
    case .tests: "Tests"
    case .games: "Games"
    }
  }
}
