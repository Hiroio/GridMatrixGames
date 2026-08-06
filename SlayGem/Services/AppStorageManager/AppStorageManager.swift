//
//  AppStorageManager.swift
//  SlayGem
//

import Foundation

@MainActor
@Observable
final class AppStorageManager {
  static let shared = AppStorageManager()

  private enum Keys {
    static let onboarding = "slaygem.hasCompletedOnboarding"
    static let sound = "slaygem.isSoundEnabled"
    static let haptic = "slaygem.isHapticEnabled"
    static let sfxVolume = "slaygem.sfxVolume"
    static let difficulty = "slaygem.selectedGameDifficulty"
  }

  var hasCompletedOnboarding: Bool {
    didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.onboarding) }
  }

  var isSoundEnabled: Bool {
    didSet { UserDefaults.standard.set(isSoundEnabled, forKey: Keys.sound) }
  }

  var isHapticEnabled: Bool {
    didSet { UserDefaults.standard.set(isHapticEnabled, forKey: Keys.haptic) }
  }

  var sfxVolume: Double {
    didSet { UserDefaults.standard.set(sfxVolume, forKey: Keys.sfxVolume) }
  }

  var selectedGameDifficulty: GridDifficulty {
    didSet {
      UserDefaults.standard.set(selectedGameDifficulty.rawValue, forKey: Keys.difficulty)
    }
  }

  private init() {
    let defaults = UserDefaults.standard
    hasCompletedOnboarding = defaults.bool(forKey: Keys.onboarding)
    isSoundEnabled = defaults.object(forKey: Keys.sound) as? Bool ?? true
    isHapticEnabled = defaults.object(forKey: Keys.haptic) as? Bool ?? true
    sfxVolume = defaults.object(forKey: Keys.sfxVolume) as? Double ?? 1.0
    if let raw = defaults.string(forKey: Keys.difficulty),
       let difficulty = GridDifficulty(rawValue: raw) {
      selectedGameDifficulty = difficulty
    } else {
      selectedGameDifficulty = .easy
    }
  }
}
