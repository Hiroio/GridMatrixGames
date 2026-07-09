//
//  SlideFusionGameView.swift
//  SpinGrid
//

import SwiftUI

struct SlideFusionGameView: View {
  @Environment(NavigationManager.self) private var navigation
  @Environment(StoreKitManager.self) private var store
  @Environment(AppStorageManager.self) private var appStorage

  @State private var viewModel = SlideFusionGameViewModel()
  @State private var difficulty: GridDifficulty = .easy

  var body: some View {
    GridSessionShell(
      title: GameType.slideFusion.title,
      subtitle: viewModel.statusText,
      chips: chips,
      answerFlash: viewModel.answerFlash,
      isSessionActive: viewModel.isRunning,
      isCompactLayout: viewModel.phase == .idle,
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
        (label: "Highest", value: "\(viewModel.highestValue)"),
        (label: "Moves", value: "\(viewModel.moves)"),
        (label: "Goal", value: "\(viewModel.goalValue)"),
      ]
    case .summary:
      return [
        (label: "Best tile", value: "\(viewModel.highestValue)"),
        (label: "Moves", value: "\(viewModel.moves)"),
        (label: "Score", value: "\(viewModel.finalScore)%"),
      ]
    default:
      return []
    }
  }

  @ViewBuilder
  private var stageContent: some View {
    switch viewModel.phase {
    case .idle:
      sessionIdlePreview {
        SlideFusionSwipeHints(placement: .idle)
      }

    case .playing:
      if viewModel.isBoardReady {
        SlideFusionBoardView(
          size: viewModel.gridSize,
          values: viewModel.tiles,
          blocked: viewModel.blocked,
          onSwipe: { viewModel.swipe($0) }
        )
        .overlay {
          if viewModel.moves == 0 {
            SlideFusionSwipeHints(placement: .board)
              .transition(.opacity)
          }
        }
        .animation(AppDesign.smoothAnimation, value: viewModel.moves == 0)
        .padding(.horizontal, AppDesign.screenPadding)
      } else {
        ProgressView()
          .tint(AppDesign.accent)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }

    case .summary:
      if viewModel.isBoardReady {
        VStack(spacing: AppDesign.spacingL) {
          MatrixStageFrame {
            MatrixGridView(
              size: viewModel.gridSize,
              states: summaryStates,
              labels: summaryLabels,
              interactive: false
            )
            .padding(AppDesign.spacingM)
          }
          .padding(.horizontal, AppDesign.screenPadding)

          sessionSummaryStage(
            score: viewModel.finalScore,
            metricText: viewModel.summaryMetricText
          )
        }
      }
    }
  }

  private var summaryStates: [GridCellState] {
    (0..<(viewModel.gridSize * viewModel.gridSize)).map { viewModel.cellState(at: $0) }
  }

  private var summaryLabels: [String?] {
    (0..<(viewModel.gridSize * viewModel.gridSize)).map { viewModel.cellLabel(at: $0) }
  }

  @ViewBuilder
  private var footerContent: some View {
    switch viewModel.phase {
    case .idle:
      sessionIdleFooter(
        steps: [
          "Swipe left, right, or up to slide all tiles.",
          "Matching numbers merge and double (2→4→8…).",
          "Play as long as you like — tap End Session when done."
        ],
        selectedDifficulty: $difficulty,
        isPremium: store.isPremium,
        gridLabel: slideFusionGridLabel,
        onRequirePremium: { store.presentPaywall() },
        onStart: {
          guard store.requirePremium() else { return }
          appStorage.selectedGameDifficulty = difficulty
          viewModel.start(difficulty: difficulty)
        }
      )

    case .playing:
      Button {
        viewModel.endSession()
      } label: {
        Label("End Session", systemImage: "stop.circle")
          .frame(maxWidth: .infinity)
      }
      .font(.headline.weight(.semibold))
      .foregroundStyle(AppDesign.primaryText)
      .padding(.vertical, 16)
      .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.buttonCorner, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: AppDesign.buttonCorner, style: .continuous)
          .stroke(AppDesign.gridLine, lineWidth: 1)
      }

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

  private func slideFusionGridLabel(_ difficulty: GridDifficulty) -> String {
    "\(SlideFusionEngine.gridSize(for: difficulty))×\(SlideFusionEngine.gridSize(for: difficulty))"
  }
}
