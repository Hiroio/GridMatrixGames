//
//  SlayGemApp.swift
//  SlayGem
//

import SwiftData
import SwiftUI

@main
struct SlayGemApp: App {
  @State private var navigation = NavigationManager.shared
  @State private var appStorage = AppStorageManager.shared
  @State private var store = StoreKitManager.shared
  @State private var session = SessionManager.shared

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(navigation)
        .environment(appStorage)
        .environment(store)
        .environment(session)
        .modelContainer(SwiftDataManager.shared.modelContainer)
        .preferredColorScheme(.dark)
    }
  }
}
