//
//  ProfileMetricsBar.swift
//  SlayGem
//

import SwiftUI

struct ProfileMetricsBar: View {
  let testsPlayed: Int
  let gamesPlayed: Int
  let todayStreak: Int

  var body: some View {
    HStack(spacing: AppDesign.spacingS) {
      metricItem(icon: "checklist", title: "Tests", value: "\(testsPlayed)")
      metricItem(icon: "gamecontroller.fill", title: "Games", value: "\(gamesPlayed)")
      metricItem(icon: "flame.fill", title: "Streak", value: "\(todayStreak)")
    }
    .padding(AppDesign.spacingM)
    .background(AppDesign.surface.opacity(0.85), in: RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous)
        .stroke(AppDesign.gridLine, lineWidth: 1)
    }
  }

  private func metricItem(icon: String, title: String, value: String) -> some View {
    VStack(spacing: 6) {
      Image(systemName: icon)
        .font(.caption.weight(.bold))
        .foregroundStyle(AppDesign.accent)
      Text(value)
        .font(.title3.weight(.bold).monospacedDigit())
        .foregroundStyle(AppDesign.primaryText)
      Text(title)
        .font(.caption2.weight(.semibold))
        .foregroundStyle(AppDesign.tertiaryText)
    }
    .frame(maxWidth: .infinity)
  }
}
