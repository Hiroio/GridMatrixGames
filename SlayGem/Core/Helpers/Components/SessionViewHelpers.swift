//
//  SessionViewHelpers.swift
//  SlayGem
//

import SwiftUI

@ViewBuilder
func sessionIdlePreview<Content: View>(@ViewBuilder content: () -> Content) -> some View {
  content()
    .frame(maxWidth: .infinity)
}

@ViewBuilder
func sessionSummaryStage(score: Int, metricText: String) -> some View {
  SessionSummaryCompact(score: score, metricText: metricText)
}

private struct SessionSummaryCompact: View {
  @Environment(\.verticalSizeClass) private var verticalSizeClass
  let score: Int
  let metricText: String

  private var ring: CGFloat { verticalSizeClass == .compact ? 72 : 96 }

  var body: some View {
    VStack(spacing: verticalSizeClass == .compact ? AppDesign.spacingS : AppDesign.spacingL) {
      ZStack {
        RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous)
          .stroke(AppDesign.timerTrack, lineWidth: 4)
          .frame(width: ring, height: ring)
        VStack(spacing: 4) {
          Image(systemName: "star.fill")
            .font(.caption)
            .foregroundStyle(AppDesign.accent)
          Text("\(score)%")
            .font(.system(size: verticalSizeClass == .compact ? 28 : 34, weight: .bold, design: .rounded).monospacedDigit())
            .foregroundStyle(AppDesign.accent)
        }
      }

      Label(metricText, systemImage: "checkmark.circle")
        .font(.subheadline)
        .foregroundStyle(AppDesign.secondaryText)
        .multilineTextAlignment(.center)
        .minimumScaleFactor(0.85)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, AppDesign.spacingM)
  }
}

@ViewBuilder
func sessionIdleFooter(
  steps: [String],
  selectedDifficulty: Binding<GridDifficulty>? = nil,
  isPremium: Bool = false,
  gridLabel: @escaping (GridDifficulty) -> String = { $0.gridLabel },
  onRequirePremium: (() -> Void)? = nil,
  onStart: @escaping () -> Void
) -> some View {
  VStack(spacing: AppDesign.spacingM) {
    if let selectedDifficulty {
      GameDifficultyPicker(
        selection: selectedDifficulty,
        isPremium: isPremium,
        onHardLocked: { onRequirePremium?() },
        gridLabel: gridLabel
      )
    }

    VStack(alignment: .leading, spacing: 6) {
      ForEach(Array(steps.prefix(3).enumerated()), id: \.offset) { _, step in
        HStack(alignment: .top, spacing: 8) {
          Circle()
            .fill(AppDesign.accent)
            .frame(width: 4, height: 4)
            .padding(.top, 6)
          Text(step)
            .font(.caption)
            .foregroundStyle(AppDesign.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
    }
    .frame(maxWidth: 340, alignment: .leading)
    .frame(maxWidth: .infinity, alignment: .center)

    Button(action: onStart) {
      Label("Start", systemImage: "play.fill")
        .frame(maxWidth: .infinity)
    }
    .gridAccentButton()
  }
}

@ViewBuilder
func sessionSummaryFooter(onAgain: (() -> Void)? = nil, onDone: @escaping () -> Void) -> some View {
  HStack(spacing: AppDesign.spacingM) {
    if let onAgain {
      Button(action: onAgain) {
        Label("Again", systemImage: "arrow.clockwise")
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
    }

    Button(action: onDone) {
      Label("Done", systemImage: "checkmark")
        .frame(maxWidth: .infinity)
    }
    .gridAccentButton()
  }
}
