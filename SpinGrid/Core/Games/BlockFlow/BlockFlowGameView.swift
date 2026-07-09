//
//  BlockFlowGameView.swift
//  SpinGrid
//

import SwiftUI

struct BlockFlowGameView: View {
  @Environment(NavigationManager.self) private var navigation
  @Environment(StoreKitManager.self) private var store
  @Environment(AppStorageManager.self) private var appStorage

  @State private var viewModel = BlockFlowGameViewModel()
  @State private var difficulty: GridDifficulty = .easy

  var body: some View {
    GridSessionShell(
      title: GameType.blockFlow.title,
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
        (label: "Time", value: viewModel.timer.formatted),
        (label: "Pairs", value: "\(viewModel.paths.count)/\(viewModel.challenge?.pairs.count ?? 0)"),
      ]
    case .summary:
      return [
        (label: "Time", value: viewModel.timer.formatted),
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
        MatrixThumbnailView(style: .blockFlow, size: 88)
      }

    case .playing:
      VStack(spacing: AppDesign.spacingM) {
        MatrixStageFrame {
          BlockFlowBoardView(
            size: viewModel.gridSize,
            states: viewModel.cellStates(),
            labels: viewModel.cellLabels(),
            pairShades: pairShades(),
            onDragChanged: { viewModel.beginDrag(at: $0) },
            onDragEnded: { viewModel.endDrag() }
          )
          .padding(AppDesign.spacingM)
        }
        if viewModel.phase == .playing {
          Button {
            viewModel.undoLast()
          } label: {
            Label("Undo pair", systemImage: "arrow.uturn.backward")
              .font(.caption.weight(.semibold))
              .foregroundStyle(AppDesign.secondaryText)
          }
        }
      }
      .padding(.horizontal, AppDesign.screenPadding)

    case .summary:
      sessionSummaryStage(
        score: viewModel.finalScore,
        metricText: "Connected in \(viewModel.timer.formatted)"
      )
    }
  }

  private func pairShades() -> [Int] {
    (0..<(viewModel.gridSize * viewModel.gridSize)).map { viewModel.pairShade(at: $0) }
  }

  @ViewBuilder
  private var footerContent: some View {
    switch viewModel.phase {
    case .idle:
      sessionIdleFooter(
        steps: [
          "Drag from one letter to its matching pair.",
          "Paths cannot cross or reuse cells.",
          "Fill the entire grid to win."
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
