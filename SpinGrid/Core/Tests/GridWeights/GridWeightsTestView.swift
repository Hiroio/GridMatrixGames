//
//  GridWeightsTestView.swift
//  SpinGrid
//

import SwiftUI

struct GridWeightsTestView: View {
  @Environment(NavigationManager.self) private var navigation
  @State private var viewModel = GridWeightsTestViewModel()

  var body: some View {
    GridSessionShell(
      title: TestType.gridWeights.title,
      subtitle: viewModel.statusText,
      chips: chips,
      answerFlash: viewModel.answerFlash,
      isSessionActive: viewModel.isRunning,
      isCompactLayout: viewModel.phase == .idle,
      stage: { stageContent },
      footer: { footerContent }
    )
    .onDisappear { viewModel.reset() }
  }

  private var chips: [(label: String, value: String)] {
    switch viewModel.phase {
    case .summary:
      return [
        (label: "Result", value: viewModel.wasCorrect ? "Correct" : "Wrong"),
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
        MatrixThumbnailView(style: .gridWeights, size: 88)
      }

    case .preview, .playing, .reveal, .summary:
      VStack(spacing: AppDesign.spacingL) {
        if viewModel.phase == .playing {
          GridAnimatedTimerBar(progress: viewModel.timerProgress)
            .padding(.horizontal, AppDesign.screenPadding)
        }

        HStack(spacing: AppDesign.spacingL) {
          panel(title: "Left", states: viewModel.leftStates())
          panel(title: "Right", states: viewModel.rightStates())
        }
        .padding(.horizontal, AppDesign.screenPadding)

        if viewModel.phase == .playing {
          LeftRightChoiceBar(
            onLeft: { viewModel.pickLeft() },
            onRight: { viewModel.pickRight() }
          )
          .padding(.horizontal, AppDesign.screenPadding)
        } else if viewModel.phase == .summary {
          sessionSummaryStage(
            score: viewModel.finalScore,
            metricText: viewModel.wasCorrect ? "Sharp spatial read" : "Try counting blocks faster"
          )
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  private func panel(title: String, states: [GridCellState]) -> some View {
    VStack(spacing: AppDesign.spacingS) {
      Text(title)
        .font(.caption.weight(.bold))
        .foregroundStyle(AppDesign.tertiaryText)
      MatrixStageFrame {
        MatrixGridView(size: 3, states: states, interactive: false)
          .padding(AppDesign.spacingS)
      }
    }
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  private var footerContent: some View {
    switch viewModel.phase {
    case .idle:
      sessionIdleFooter(
        steps: [
          "Two 3×3 grids appear with different fill counts.",
          "Study both sides, then tap Left or Right.",
          "You have 3 seconds to pick the heavier side."
        ],
        onStart: { Task { await viewModel.start() } }
      )
    case .summary:
      sessionSummaryFooter(
        onAgain: { viewModel.reset(); Task { await viewModel.start() } },
        onDone: { navigation.closeTest() }
      )
    default:
      Color.clear.frame(height: 1)
    }
  }
}
