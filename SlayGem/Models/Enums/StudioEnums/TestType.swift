//
//  TestType.swift
//  SlayGem
//

import Foundation

enum TestType: String, CaseIterable, Identifiable {
  case gridSearch
  case missingLink
  case gridWeights
  case memoryBlitz

  var id: String { rawValue }

  var title: String {
    switch self {
    case .gridSearch: "Grid Search Test"
    case .missingLink: "Missing Link Test"
    case .gridWeights: "Grid Weights Test"
    case .memoryBlitz: "Memory Blitz Test"
    }
  }

  var subtitle: String {
    switch self {
    case .gridSearch: "Schulte 4×4 · 1 round"
    case .missingLink: "Trace the path · find the gap"
    case .gridWeights: "Compare weight · 1 round"
    case .memoryBlitz: "Recall pattern · 1 round"
    }
  }

  var icon: String {
    switch self {
    case .gridSearch: "number.square"
    case .missingLink: "link.badge.plus"
    case .gridWeights: "scale.3d"
    case .memoryBlitz: "brain.head.profile"
    }
  }
}
