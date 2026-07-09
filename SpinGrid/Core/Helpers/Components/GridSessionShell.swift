//
//  GridSessionShell.swift
//  SpinGrid
//

import SwiftUI

struct GridSessionShell<Stage: View, Footer: View>: View {
  @Environment(NavigationManager.self) private var navigation

  let title: String
  let subtitle: String
  var chips: [(label: String, value: String)] = []
  var answerFlash: AnswerFlashKind?
  var isSessionActive = false
  var isCompactLayout = false

  @ViewBuilder let stage: () -> Stage
  @ViewBuilder let footer: () -> Footer

  @State private var showsExitConfirmation = false

  var body: some View {
    ZStack {
      AppDesign.background.ignoresSafeArea()

      if isCompactLayout {
        compactLayout
          .transition(AppTransitions.sessionContent)
      } else {
        standardLayout
          .transition(AppTransitions.sessionContent)
      }

      AnswerFlashController(kind: answerFlash)
    }
    .animation(AppDesign.phaseAnimation, value: isCompactLayout)
    .animation(AppDesign.gridCellSpring, value: chips.map(\.value).joined())
    .animation(AppDesign.smoothAnimation, value: subtitle)
    .alert("Leave session?", isPresented: $showsExitConfirmation) {
      Button("Stay", role: .cancel) {}
      Button("Leave", role: .destructive) { exitSession() }
    } message: {
      Text("Your current progress will be lost.")
    }
  }

  private var standardLayout: some View {
    VStack(spacing: AppDesign.spacingL) {
      sessionHeader
      subtitleView

      if !chips.isEmpty {
        chipsRow
      }

      stage()
        .frame(maxWidth: .infinity, maxHeight: .infinity)

      footer()
        .padding(.horizontal, AppDesign.screenPadding)
        .padding(.bottom, AppDesign.spacingL)
    }
  }

  private var compactLayout: some View {
    VStack(spacing: 0) {
      sessionHeader
      Spacer(minLength: AppDesign.spacingM)
      VStack(spacing: AppDesign.spacingL) {
        subtitleView
        stage()
        footer()
          .padding(.horizontal, AppDesign.screenPadding)
      }
      Spacer(minLength: AppDesign.spacingM)
    }
    .padding(.bottom, AppDesign.spacingM)
  }

  private var subtitleView: some View {
    Text(subtitle)
      .font(.subheadline.weight(.medium))
      .foregroundStyle(AppDesign.secondaryText)
      .multilineTextAlignment(.center)
      .padding(.horizontal, AppDesign.screenPadding)
  }

  private var chipsRow: some View {
    HStack(spacing: AppDesign.spacingS) {
      ForEach(Array(chips.enumerated()), id: \.offset) { _, chip in
        MetricChip(
          label: chip.label,
          value: chip.value,
          systemName: chipIcon(for: chip.label)
        )
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .padding(.horizontal, AppDesign.screenPadding)
  }

  private var sessionHeader: some View {
    HStack {
      Button(action: handleBack) {
        Image(systemName: "xmark")
          .font(.body.weight(.semibold))
          .foregroundStyle(AppDesign.primaryText)
          .frame(width: 40, height: 40)
          .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous))
      }

      Spacer()

      Text(title)
        .font(.headline.weight(.bold))
        .foregroundStyle(AppDesign.primaryText)

      Spacer()

      Color.clear.frame(width: 40, height: 40)
    }
    .padding(.horizontal, AppDesign.screenPadding)
    .padding(.top, AppDesign.spacingS)
  }

  private func handleBack() {
    if isSessionActive {
      showsExitConfirmation = true
    } else {
      exitSession()
    }
  }

  private func chipIcon(for label: String) -> String? {
    switch label.lowercased() {
    case "time": "clock.fill"
    case "moves": "arrow.left.arrow.right"
    case "pairs": "link"
    case "misses": "xmark.circle"
    case "score": "star.fill"
    case "left": "hourglass"
    case "goal": "flag.checkered"
    case "highest", "best tile": "arrow.up.circle.fill"
    case "grid": "square.grid.3x3"
    default: nil
    }
  }

  private func exitSession() {
    if navigation.activeTest != nil {
      navigation.closeTest()
    } else if navigation.activeGame != nil {
      navigation.closeGame()
    } else {
      navigation.closeSecondary()
    }
  }
}
