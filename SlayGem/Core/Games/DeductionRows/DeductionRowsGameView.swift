//
//  DeductionRowsGameView.swift
//  SlayGem
//

import SwiftUI

struct DeductionRowsGameView: View {
  @Environment(NavigationManager.self) private var navigation
  @Environment(StoreKitManager.self) private var store
  @Environment(AppStorageManager.self) private var appStorage

  @State private var viewModel = DeductionRowsGameViewModel()
  @State private var difficulty: GridDifficulty = .easy

  var body: some View {
    GridSessionShell(
      title: GameType.deductionRows.title,
      subtitle: viewModel.statusText,
      chips: chips,
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

  private var chips: [(label: String, value: String)] {
    switch viewModel.phase {
    case .playing:
      return [
        (label: "Time", value: viewModel.timer.formatted),
        (label: "Misses", value: "\(viewModel.mistakes)"),
      ]
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
        MatrixThumbnailView(style: .deductionRows, size: 88)
      }

    case .playing:
      MatrixStageFrame {
        if let challenge = viewModel.challenge {
          NonogramBoardView(
            size: challenge.size,
            rowClues: challenge.rowClues,
            colClues: challenge.colClues,
            states: (0..<(challenge.size * challenge.size)).map { viewModel.gridCellState(at: $0) },
            onTap: { viewModel.toggleFill(at: $0) },
            onMark: { viewModel.toggleMark(at: $0) }
          )
          .padding(AppDesign.spacingM)
        }
      }
      .padding(.horizontal, AppDesign.screenPadding)

    case .summary:
      sessionSummaryStage(
        score: viewModel.finalScore,
        metricText: "Solved in \(viewModel.timer.formatted)"
      )
    }
  }

  @ViewBuilder
  private var footerContent: some View {
    switch viewModel.phase {
    case .idle:
      sessionIdleFooter(
        steps: [
          "Use the number clues on each row and column.",
          "1 · 1 means two separate filled blocks with a gap between.",
          "Tap to fill a cell, long press to mark empty.",
          "Hit Check when you think the grid is right."
        ],
        selectedDifficulty: $difficulty,
        isPremium: store.isPremium,
        onRequirePremium: { store.presentPaywall() },
        onStart: {
          appStorage.selectedGameDifficulty = difficulty
          viewModel.start(difficulty: difficulty)
        }
      )
    case .playing:
      Button {
        viewModel.checkSolution()
      } label: {
        Label("Check solution", systemImage: "checkmark.seal")
          .frame(maxWidth: .infinity)
      }
      .gridAccentButton()
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
    }
  }
}
