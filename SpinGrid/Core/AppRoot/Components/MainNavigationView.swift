//
//  MainNavigationView.swift
//  SpinGrid
//

import SwiftUI

struct MainNavigationView: View {
  @Environment(NavigationManager.self) private var navigation

  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        Group {
          switch navigation.mainScreen {
          case .main:
            MainView()
          case .studio:
            StudioView()
          case .stats:
            StatsView()
          case .profile:
            ProfileView()
          }
        }
        .transition(AppTransitions.tabContent)
        .id(navigation.mainScreen)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .animation(AppDesign.tabContentAnimation, value: navigation.mainScreen)

      CustomTabBar()
    }
  }
}
