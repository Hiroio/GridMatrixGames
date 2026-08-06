//
//  GameType.swift
//  SlayGem
//

import Foundation

enum GameType: String, CaseIterable, Identifiable {
  case flipMatrix
  case blockFlow
  case deductionRows
  case slideFusion

  var id: String { rawValue }

  var title: String {
    switch self {
    case .flipMatrix: "Flip Matrix"
    case .blockFlow: "Block Flow"
    case .deductionRows: "Deduction Rows"
    case .slideFusion: "Slide Fusion"
    }
  }

  var subtitle: String {
    switch self {
    case .flipMatrix: "Lights out · invert neighbors"
    case .blockFlow: "Connect pairs · fill grid"
    case .deductionRows: "Mini nonograms"
    case .slideFusion: "Swipe · merge · 2048"
    }
  }

  var icon: String {
    switch self {
    case .flipMatrix: "lightbulb"
    case .blockFlow: "point.3.connected.trianglepath.dotted"
    case .deductionRows: "tablecells"
    case .slideFusion: "arrow.up.and.down.and.arrow.left.and.right"
    }
  }

  var isPremium: Bool {
    self == .slideFusion
  }
}
