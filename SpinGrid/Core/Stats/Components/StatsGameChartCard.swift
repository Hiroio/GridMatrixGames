//
//  StatsGameChartCard.swift
//  SpinGrid
//

import SwiftUI

struct StatsGameChartCard: View {
  let row: StatsActivityRow

  var body: some View {
    VStack(alignment: .leading, spacing: AppDesign.spacingM) {
      HStack(spacing: 10) {
        SFSymbolBadge(systemName: row.icon, size: 32, iconSize: 14)

        VStack(alignment: .leading, spacing: 2) {
          Text(row.title)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(AppDesign.primaryText)
          Text("\(row.sessions) sessions")
            .font(.caption)
            .foregroundStyle(AppDesign.tertiaryText)
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 2) {
          Text(row.bestText)
            .font(.caption.weight(.bold).monospacedDigit())
            .foregroundStyle(AppDesign.accent)
          Text("best")
            .font(.caption2)
            .foregroundStyle(AppDesign.tertiaryText)
        }
      }

      StatsSquareBarChart(values: row.sparkValues, compact: row.sparkValues.count > 14)

      HStack {
        Text(row.chartPeriodLabel)
          .font(.caption2.weight(.semibold))
          .foregroundStyle(AppDesign.tertiaryText)
        Spacer()
        Text("Last")
          .font(.caption2.weight(.semibold))
          .foregroundStyle(AppDesign.tertiaryText)
        Text(row.lastText)
          .font(.caption.weight(.semibold).monospacedDigit())
          .foregroundStyle(AppDesign.secondaryText)
      }
    }
    .gridCard(padding: AppDesign.spacingM)
  }
}
