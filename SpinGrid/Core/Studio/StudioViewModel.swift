//
//  StudioViewModel.swift
//  SpinGrid
//

import Foundation

@MainActor
@Observable
final class StudioViewModel {
  var segment: StudioSegment = .tests

  var headerSubtitle: String {
    switch segment {
    case .tests: "One-round matrix benchmarks"
    case .games: "Logic puzzles with difficulty tiers"
    }
  }
}
