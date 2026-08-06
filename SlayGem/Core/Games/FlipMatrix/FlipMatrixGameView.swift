//
//  FlipMatrixGameView.swift
//  SlayGem
//

import SwiftUI

struct FlipMatrixGameView: View {
  @Environment(NavigationManager.self) private var navigation
  @Environment(StoreKitManager.self) private var store
  @Environment(AppStorageManager.self) private var appStorage

  @State private var viewModel = FlipMatrixGameViewModel()
  @State private var difficulty: GridDifficulty = .easy

  var body: some View {
    GridSessionShell(
      title: GameType.flipMatrix.title,
      subtitle: viewModel.statusText,
      chips: metricChips,
      answerFlash: viewModel.answerFlash,
      isSessionActive: viewModel.isRunning,
      isCompactLayout: viewModel.phase == .idle,
      isSummaryLayout: viewModel.phase == .summary,
      stage: { stageContent },
      footer: { footerContent }
    )
    .onAppear { difficulty = appStorage.selectedGameDifficulty }
    .onDisappear { viewModel.reset() }
  }

  private var metricChips: [(label: String, value: String)] {
    switch viewModel.phase {
    case .playing:
      var chips: [(label: String, value: String)] = [
        (label: "Time", value: viewModel.timer.formatted),
        (label: "Moves", value: "\(viewModel.moves)"),
      ]
      if let remaining = viewModel.movesRemaining {
        chips.append((label: "Left", value: "\(remaining)"))
      }
      return chips
    case .summary:
      return []
    default:
      return []
    }
  }

  @ViewBuilder
  private var stageContent: some View {
    switch viewModel.phase {
    case .idle:
      sessionIdlePreview {
        MatrixThumbnailView(style: .flipMatrix, size: 88)
      }

    case .playing:
      MatrixStageFrame {
        MatrixGridView(
          size: viewModel.gridSize,
          states: viewModel.displayStates,
          labels: [],
          onTap: { viewModel.handleTap(at: $0) }
        )
        .padding(AppDesign.spacingS)
      }
      .padding(.horizontal, AppDesign.screenPadding)
      .frame(maxWidth: .infinity, maxHeight: .infinity)

    case .summary:
      sessionSummaryStage(
        score: viewModel.finalScore,
        metricText: viewModel.won
          ? "Solved in \(viewModel.moves) moves"
          : "Out of moves — try again"
      )
    }
  }

  @ViewBuilder
  private var footerContent: some View {
    switch viewModel.phase {
    case .idle:
      sessionIdleFooter(
        steps: [
          "Each tap flips that cell and its four neighbors.",
          "Turn off every yellow cell to win.",
          "Fewer moves than par earns a higher score."
        ],
        selectedDifficulty: $difficulty,
        isPremium: store.isPremium,
        onRequirePremium: { store.presentPaywall() },
        onStart: {
          appStorage.selectedGameDifficulty = difficulty
          viewModel.start(difficulty: difficulty)
        }
      )
    case .summary:
      sessionSummaryFooter(
        onAgain: {
          let d = difficulty
          viewModel.reset()
          difficulty = d
          viewModel.start(difficulty: d)
        },
        onDone: { navigation.closeGame() }
      )
    default:
      Color.clear.frame(height: 1)
    }
  }
}
