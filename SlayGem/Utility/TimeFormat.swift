//
//  TimeFormat.swift
//  SlayGem
//

import Foundation

enum TimeFormat {
  static func secondsLabel(ms: Int) -> String {
    let s = max(1, Int((Double(ms) / 1000.0).rounded()))
    return "\(s) s"
  }
}
