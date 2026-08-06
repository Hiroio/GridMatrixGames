//
//  SecondaryScreensEnum.swift
//  SlayGem
//

import Foundation

enum SecondaryScreensEnum: Identifiable {
  case stats

  var id: String {
    switch self {
    case .stats: "stats"
    }
  }
}
