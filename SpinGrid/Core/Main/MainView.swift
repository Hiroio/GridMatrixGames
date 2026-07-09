//
//  MainView.swift
//  SpinGrid
//

import SwiftUI

struct MainView: View {
  @Environment(NavigationManager.self) private var navigation
  @Environment(StoreKitManager.self) private var store
  @State private var viewModel = MainViewModel()

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: AppDesign.spacingL) {
        ScreenHeaderView(
          title: AppDesign.appName,
          subtitle: AppDesign.tagline,
          icon: "square.grid.3x3.fill"
        )

        MainScoreAndStudioCard(
          score: viewModel.gridScore,
          caption: viewModel.gridCaption,
          testsLeft: viewModel.testsLeft,
          gamesLeft: viewModel.gamesLeft,
          streak: viewModel.streak,
          isPremium: store.isPremium,
          onOpenStats: { navigation.openStats() }
        )

        MainQuickPickGrid(
          onTest: { navigation.openTest($0) },
          onGame: { navigation.openGame($0) }
        )

        if let recent = viewModel.recentSession {
          MainRecentSessionCard(
            title: recent.title,
            subtitle: recent.subtitle,
            scoreText: recent.scoreText
          )
        }
      }
      .padding(.horizontal, AppDesign.screenPadding)
      .padding(.top, AppDesign.spacingM)
      .padding(.bottom, AppDesign.spacingXL)
    }
    .gridTransparentScroll()
  }
}
