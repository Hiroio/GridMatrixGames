//
//  MainHomeComponents.swift
//  SpinGrid
//

import SwiftUI

struct MainScoreAndStudioCard: View {
  let score: Int
  let caption: String
  let testsLeft: Int
  let gamesLeft: Int
  let streak: Int
  var isPremium = false
  let onOpenStats: () -> Void

  private var ringProgress: CGFloat {
    min(1, CGFloat(score) / 500)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: AppDesign.spacingL) {
      Button(action: onOpenStats) {
        HStack(spacing: AppDesign.spacingL) {
          ZStack {
            Circle()
              .stroke(AppDesign.timerTrack, lineWidth: 6)
              .frame(width: 76, height: 76)
            Circle()
              .trim(from: 0, to: ringProgress)
              .stroke(AppDesign.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
              .rotationEffect(.degrees(-90))
              .frame(width: 76, height: 76)
            Text("\(score)")
              .font(.title3.weight(.bold).monospacedDigit())
              .foregroundStyle(AppDesign.primaryText)
          }

          VStack(alignment: .leading, spacing: 4) {
            Label("Grid Score", systemImage: "chart.line.uptrend.xyaxis")
              .font(.caption.weight(.bold))
              .foregroundStyle(AppDesign.tertiaryText)
            Text(caption)
              .font(.subheadline.weight(.semibold))
              .foregroundStyle(AppDesign.primaryText)
          }

          Spacer(minLength: 0)

          Image(systemName: "chevron.right")
            .font(.caption.weight(.bold))
            .foregroundStyle(AppDesign.accent)
        }
      }
      .buttonStyle(.plain)

      Rectangle()
        .fill(AppDesign.gridLine)
        .frame(height: 1)

      Label("Today's Studio", systemImage: "sun.max.fill")
        .font(.caption.weight(.bold))
        .foregroundStyle(AppDesign.tertiaryText)

      HStack(spacing: AppDesign.spacingM) {
        studioTile(
          icon: "checklist",
          title: "Tests",
          value: isPremium ? "∞" : "\(testsLeft)",
          suffix: isPremium ? "unlimited" : "left"
        )
        studioTile(
          icon: "gamecontroller.fill",
          title: "Games",
          value: isPremium ? "∞" : "\(gamesLeft)",
          suffix: isPremium ? "unlimited" : "left"
        )
        studioTile(icon: "flame.fill", title: "Streak", value: "\(streak)", suffix: "days")
      }
    }
    .gridCard()
  }

  private func studioTile(icon: String, title: String, value: String, suffix: String) -> some View {
    VStack(spacing: 4) {
      Image(systemName: icon)
        .font(.caption2.weight(.bold))
        .foregroundStyle(AppDesign.accent)
      Text(value)
        .font(.headline.weight(.bold).monospacedDigit())
        .foregroundStyle(AppDesign.primaryText)
      Text(title)
        .font(.caption2.weight(.semibold))
        .foregroundStyle(AppDesign.tertiaryText)
      Text(suffix)
        .font(.caption2)
        .foregroundStyle(AppDesign.tertiaryText.opacity(0.8))
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 8)
    .background(AppDesign.backgroundElevated, in: RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous))
  }
}

struct MainQuickPickGrid: View {
  let onTest: (TestType) -> Void
  let onGame: (GameType) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: AppDesign.spacingM) {
      Label("Quick pick", systemImage: "bolt.fill")
        .font(.caption.weight(.bold))
        .foregroundStyle(AppDesign.tertiaryText)

      LazyVGrid(
        columns: [
          GridItem(.flexible(), spacing: AppDesign.spacingM),
          GridItem(.flexible(), spacing: AppDesign.spacingM),
        ],
        spacing: AppDesign.spacingM
      ) {
        quickTile(title: "Grid Search", icon: "number.square", style: .gridSearch) { onTest(.gridSearch) }
        quickTile(title: "Flip Matrix", icon: "lightbulb", style: .flipMatrix) { onGame(.flipMatrix) }
        quickTile(title: "Missing Link", icon: "link", style: .missingLink) { onTest(.missingLink) }
        quickTile(title: "Block Flow", icon: "point.3.connected.trianglepath.dotted", style: .blockFlow) { onGame(.blockFlow) }
      }
    }
  }

  private func quickTile(
    title: String,
    icon: String,
    style: MatrixThumbnailStyle,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      VStack(spacing: AppDesign.spacingS) {
        MatrixThumbnailView(style: style, size: 48)
        Label(title, systemImage: icon)
          .font(.caption.weight(.bold))
          .foregroundStyle(AppDesign.primaryText)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, AppDesign.spacingM)
      .background(AppDesign.surface.opacity(0.65), in: RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous)
          .stroke(AppDesign.gridLine, lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
  }
}

struct MainRecentSessionCard: View {
  let title: String
  let subtitle: String
  let scoreText: String

  var body: some View {
    HStack(spacing: AppDesign.spacingM) {
      SFSymbolBadge(systemName: "clock.arrow.circlepath", size: 40, iconSize: 16)

      VStack(alignment: .leading, spacing: 4) {
        Text("Last session")
          .font(.caption.weight(.bold))
          .foregroundStyle(AppDesign.tertiaryText)
        Text(title)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(AppDesign.primaryText)
        Text(subtitle)
          .font(.caption)
          .foregroundStyle(AppDesign.secondaryText)
      }

      Spacer()

      Text(scoreText)
        .font(.headline.weight(.bold).monospacedDigit())
        .foregroundStyle(AppDesign.accent)
    }
    .gridCard()
  }
}
