//
//  MainScreensEnum.swift
//  SpinGrid
//

import Foundation

enum MainScreensEnum: String, CaseIterable, Identifiable {
  case main
  case studio
  case stats
  case profile

  var id: String { rawValue }

  var title: String {
    switch self {
    case .main: "Main"
    case .studio: "Studio"
    case .stats: "Stats"
    case .profile: "Profile"
    }
  }

  var shortTitle: String { title }

  var icon: String {
    switch self {
    case .main: "house"
    case .studio: "square.grid.3x3"
    case .stats: "chart.bar"
    case .profile: "person"
    }
  }
}
