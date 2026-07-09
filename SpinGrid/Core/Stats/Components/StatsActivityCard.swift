//
//  StatsActivityCard.swift
//  SpinGrid
//

import SwiftUI

struct StatsActivityCard: View {
  let row: StatsActivityRow

  var body: some View {
    VStack(alignment: .leading, spacing: AppDesign.spacingM) {
      HStack(spacing: 10) {
        Image(systemName: row.icon)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(AppDesign.accent)
          .frame(width: 28, height: 28)
          .background(AppDesign.accentMuted, in: RoundedRectangle(cornerRadius: 6, style: .continuous))

        VStack(alignment: .leading, spacing: 2) {
          Text(row.title)
            .font(.headline.weight(.semibold))
            .foregroundStyle(AppDesign.primaryText)
          Text(row.metricLabel)
            .font(.caption)
            .foregroundStyle(AppDesign.tertiaryText)
        }
        Spacer()
        Text("\(row.sessions)")
          .font(.caption.weight(.bold).monospacedDigit())
          .foregroundStyle(AppDesign.secondaryText)
        Text("runs")
          .font(.caption2)
          .foregroundStyle(AppDesign.tertiaryText)
      }

      HStack(spacing: AppDesign.spacingL) {
        statColumn("Best", row.bestText)
        statColumn("Last", row.lastText)
      }

      StatsSquareBarChart(values: row.sparkValues)
    }
    .gridCard(padding: AppDesign.spacingM)
  }

  private func statColumn(_ title: String, _ value: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title.uppercased())
        .font(.caption2.weight(.bold))
        .foregroundStyle(AppDesign.tertiaryText)
      Text(value)
        .font(.subheadline.weight(.semibold).monospacedDigit())
        .foregroundStyle(AppDesign.primaryText)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
