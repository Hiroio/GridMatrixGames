//
//  TodayMatrixStrip.swift
//  SpinGrid
//

import SwiftUI

struct TodayMatrixStrip: View {
  let streak: Int
  let testsLeft: Int
  let gamesLeft: Int

  var body: some View {
    HStack(spacing: AppDesign.spacingS) {
      statCell(icon: "flame.fill", title: "streak", value: "\(streak)")
      statCell(icon: "checklist", title: "tests", value: "\(testsLeft) left")
      statCell(icon: "gamecontroller.fill", title: "games", value: "\(gamesLeft) left")
    }
  }

  private func statCell(icon: String, title: String, value: String) -> some View {
    VStack(spacing: 6) {
      HStack(spacing: 4) {
        Image(systemName: icon)
          .font(.caption2.weight(.bold))
          .foregroundStyle(AppDesign.accent)
        Text(value)
          .font(.subheadline.weight(.bold).monospacedDigit())
          .foregroundStyle(AppDesign.primaryText)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }
      Text(title)
        .font(.caption2.weight(.semibold))
        .foregroundStyle(AppDesign.tertiaryText)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .background(AppDesign.backgroundElevated, in: RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous)
        .stroke(AppDesign.gridLine, lineWidth: 1)
    }
  }
}
