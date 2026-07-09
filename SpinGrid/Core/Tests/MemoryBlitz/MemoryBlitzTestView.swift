//
//  MemoryBlitzTestView.swift
//  SpinGrid
//

import SwiftUI

struct MemoryBlitzTestView: View {
  @Environment(NavigationManager.self) private var navigation
  @State private var viewModel = MemoryBlitzTestViewModel()

  var body: some View {
    GridSessionShell(
      title: TestType.memoryBlitz.title,
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
    case .recall:
      return [
        (label: "Picked", value: "\(viewModel.selected.count)/\(viewModel.patternSize)"),
      ]
    case .summary:
      return [
        (label: "Recall", value: "\(viewModel.correctCount)/\(viewModel.patternSize)"),
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
        MatrixThumbnailView(style: .memoryBlitz, size: 88)
      }

    case .flash, .recall, .summary:
      MatrixStageFrame {
        MatrixGridView(
          size: 4,
          states: viewModel.cellStates(),
          onTap: viewModel.phase == .recall ? { viewModel.handleTap(at: $0) } : nil
        )
        .padding(AppDesign.spacingM)
      }
      .padding(.horizontal, AppDesign.screenPadding)
    }
  }

  @ViewBuilder
  private var footerContent: some View {
    switch viewModel.phase {
    case .idle:
      sessionIdleFooter(
        steps: [
          "A pattern flashes on a 4×4 grid for 1 second.",
          "Tap the same cells from memory.",
          "Select \(4)–\(5) cells — extra taps are blocked."
        ],
        onStart: { Task { await viewModel.start() } }
      )
    case .recall:
      Button("Confirm picks") { viewModel.confirmSelection() }
        .gridAccentButton()
        .disabled(viewModel.selected.isEmpty)
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
