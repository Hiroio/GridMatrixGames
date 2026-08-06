//
//  MissingLinkTestView.swift
//  SlayGem
//

import SwiftUI

struct MissingLinkTestView: View {
  @Environment(NavigationManager.self) private var navigation
  @State private var viewModel = MissingLinkTestViewModel()

  var body: some View {
    GridSessionShell(
      title: TestType.missingLink.title,
      subtitle: viewModel.statusText,
      chips: chips,
      answerFlash: viewModel.answerFlash,
      isSessionActive: viewModel.isRunning,
      isCompactLayout: viewModel.phase == .idle,
      isSummaryLayout: viewModel.phase == .summary,
      stage: { stageContent },
      footer: { footerContent }
    )
    .onDisappear { viewModel.reset() }
  }

  private var chips: [(label: String, value: String)] {
    switch viewModel.phase {
    case .playing:
      return [
        (label: "Grid", value: "\(viewModel.gridSize)×\(viewModel.gridSize)"),
        (label: "Path", value: "\(viewModel.pathIndices.count) cells"),
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
        VStack(spacing: AppDesign.spacingS) {
          MissingLinkBoardView(
            size: MissingLinkDemo.previewSize,
            pathIndices: MissingLinkDemo.previewPath,
            gapIndex: MissingLinkDemo.previewGap,
            interactive: false
          )
          .frame(width: 88, height: 88)

          Text("Tap the dashed cell")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(AppDesign.tertiaryText)
        }
      }

    case .preview, .playing, .reveal:
      VStack(spacing: AppDesign.spacingM) {
        if viewModel.phase == .playing {
          GridAnimatedTimerBar(progress: viewModel.timerProgress)
            .padding(.horizontal, AppDesign.screenPadding)
        }

        MatrixStageFrame {
          MissingLinkBoardView(
            size: viewModel.gridSize,
            pathIndices: viewModel.pathIndices,
            gapIndex: viewModel.gapIndex,
            wrongTapIndex: viewModel.wrongTapIndex,
            highlightGap: viewModel.phase == .reveal,
            interactive: viewModel.phase == .playing,
            onTap: { viewModel.handleTap(at: $0) }
          )
          .padding(AppDesign.spacingM)
        }
        .padding(.horizontal, AppDesign.screenPadding)

        if viewModel.phase == .reveal {
          revealCaption
        }
      }

    case .summary:
      sessionSummaryStage(
        score: viewModel.finalScore,
        metricText: viewModel.wasCorrect
          ? "Detected in \(formatMs(viewModel.detectionMs))"
          : "The missing link was in the dashed cell"
      )
    }
  }

  private var revealCaption: some View {
    Label(
      viewModel.wasCorrect ? "You restored the path" : "Look for where the trail breaks",
      systemImage: viewModel.wasCorrect ? "checkmark.circle.fill" : "link.badge.plus"
    )
    .font(.caption.weight(.semibold))
    .foregroundStyle(viewModel.wasCorrect ? AppDesign.accent : AppDesign.secondaryText)
    .padding(.horizontal, AppDesign.screenPadding)
  }

  @ViewBuilder
  private var footerContent: some View {
    switch viewModel.phase {
    case .idle:
      sessionIdleFooter(
        steps: [
          "A yellow trail snakes through the grid.",
          "One cell is missing — shown with a dashed border.",
          "Tap that gap before time runs out. Wrong taps don't end the round."
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

  private func formatMs(_ ms: Int) -> String {
    TimeFormat.secondsLabel(ms: ms)
  }
}
