//
//  HapticManager.swift
//  SpinGrid
//

import UIKit

enum HapticManager {
  static func light() {
    guard AppStorageManager.shared.isHapticEnabled else { return }
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

  static func medium() {
    guard AppStorageManager.shared.isHapticEnabled else { return }
    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
  }

  static func success() {
    guard AppStorageManager.shared.isHapticEnabled else { return }
    UINotificationFeedbackGenerator().notificationOccurred(.success)
  }

  static func error() {
    guard AppStorageManager.shared.isHapticEnabled else { return }
    UINotificationFeedbackGenerator().notificationOccurred(.error)
  }
}
