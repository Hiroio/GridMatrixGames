//
//  SoundManager.swift
//  SlayGem
//

import AudioToolbox

enum SoundManager {
  static func playTap() {
    guard AppStorageManager.shared.isSoundEnabled else { return }
    AudioServicesPlaySystemSound(1104)
  }

  static func playSuccess() {
    guard AppStorageManager.shared.isSoundEnabled else { return }
    AudioServicesPlaySystemSound(1057)
  }

  static func playWrong() {
    guard AppStorageManager.shared.isSoundEnabled else { return }
    AudioServicesPlaySystemSound(1053)
  }

  static func playGameComplete() {
    guard AppStorageManager.shared.isSoundEnabled else { return }
    AudioServicesPlaySystemSound(1025)
  }

  static func playLimitBlocked() {
    guard AppStorageManager.shared.isSoundEnabled else { return }
    AudioServicesPlaySystemSound(1102)
  }
}
