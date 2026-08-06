//
//  GridSearchTestView.swift
//  SlayGem
//

import SwiftUI

struct GridSearchTestView: View {
  @Environment(NavigationManager.self) private var navigation
  @State private var viewModel = GridSearchTestViewModel()

  var body: some View {
    GridSessionShell(
      title: TestType.gridSearch.title,
      subtitle: viewModel.statusText,
      chips: metricChips,
      answerFlash: viewModel.answerFlash,
      isSessionActive: viewModel.isRunning,
      isCompactLayout: viewModel.phase == .idle,
      isSummaryLayout: viewModel.phase == .summary,
      stage: { stageContent },
      footer: { footerContent }
    )
    .onDisappear { viewModel.reset() }
  }

  private var metricChips: [(label: String, value: String)] {
    switch viewModel.phase {
    case .playing, .preview:
      return [
        (label: "Next", value: "\(viewModel.nextTarget)"),
        (label: "Grid", value: "4×4"),
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
        MatrixThumbnailView(style: .gridSearch, size: 88)
      }

    case .preview, .playing:
      MatrixStageFrame {
        MatrixGridView(
          size: 4,
          states: viewModel.cellStates,
          labels: viewModel.cellLabels,
          onTap: viewModel.phase == .playing ? { viewModel.handleTap(at: $0) } : nil
        )
        .padding(AppDesign.spacingS)
      }
      .padding(.horizontal, AppDesign.screenPadding)
      .frame(maxWidth: .infinity, maxHeight: .infinity)

    case .summary:
      sessionSummaryStage(
        score: viewModel.finalScore,
        metricText: "Cleared in \(formatMs(viewModel.clearTimeMs))"
      )
    }
  }

  @ViewBuilder
  private var footerContent: some View {
    switch viewModel.phase {
    case .idle:
      sessionIdleFooter(
        steps: [
          "A 4×4 grid shows numbers 1 through 16 in random positions.",
          "Tap each number in ascending order as quickly as you can.",
          "Wrong taps are ignored and flash red."
        ],
        onStart: { viewModel.start() }
      )
    case .summary:
      sessionSummaryFooter(
        onAgain: { viewModel.reset(); viewModel.start() },
        onDone: { navigation.closeTest() }
      )
    default:
      Color.clear.frame(height: 1)
    }
  }

  private func formatMs(_ ms: Int) -> String {
    TimeFormat.secondsLabel(ms: ms)
  }
}
