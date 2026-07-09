//
//  StudioView.swift
//  SpinGrid
//

import SwiftUI

struct StudioView: View {
  @Environment(NavigationManager.self) private var navigation
  @Environment(StoreKitManager.self) private var store
  @State private var viewModel = StudioViewModel()

  private let gameColumns = [
    GridItem(.flexible(), spacing: AppDesign.spacingM),
    GridItem(.flexible(), spacing: AppDesign.spacingM),
  ]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: AppDesign.spacingL) {
        ScreenHeaderView(
          title: "Studio",
          subtitle: viewModel.headerSubtitle,
          icon: "square.grid.3x3"
        )

        StudioSegmentedControl(selection: $viewModel.segment)

        switch viewModel.segment {
        case .tests:
          testsSection
            .transition(AppTransitions.segmentContent)
        case .games:
          gamesSection
            .transition(AppTransitions.segmentContent)
        }
      }
      .padding(.horizontal, AppDesign.screenPadding)
      .padding(.top, AppDesign.spacingM)
      .padding(.bottom, AppDesign.spacingXL)
      .animation(AppDesign.segmentAnimation, value: viewModel.segment)
    }
    .gridTransparentScroll()
  }

  private var testsSection: some View {
    LazyVStack(spacing: AppDesign.spacingM) {
      ForEach(TestType.allCases) { test in
        StudioActivityRow(
          thumbnailStyle: test.thumbnailStyle,
          title: test.title,
          subtitle: test.subtitle
        ) {
          navigation.openTest(test)
        }
      }
    }
  }

  private var gamesSection: some View {
    LazyVGrid(columns: gameColumns, spacing: AppDesign.spacingM) {
      ForEach(GameType.allCases) { game in
        StudioGameTile(
          thumbnailStyle: game.thumbnailStyle,
          title: game.title,
          subtitle: game.subtitle,
          difficultyHint: game.difficultyHint,
          isLocked: game.isPremium && !store.isPremium
        ) {
          if store.requireAccess(to: game) {
            navigation.openGame(game)
          }
        }
      }
    }
  }
}
