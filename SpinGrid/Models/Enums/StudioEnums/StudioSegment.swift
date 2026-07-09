//
//  StudioSegment.swift
//  SpinGrid
//

import Foundation

enum StudioSegment: String, CaseIterable, Identifiable {
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
