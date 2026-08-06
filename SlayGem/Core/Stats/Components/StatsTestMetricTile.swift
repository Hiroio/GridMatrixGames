//
//  StatsTestMetricTile.swift
//  SlayGem
//

import SwiftUI

struct StatsTestMetricTile: View {
  let row: StatsActivityRow

  var body: some View {
    VStack(alignment: .leading, spacing: AppDesign.spacingS) {
      HStack(spacing: 8) {
        Image(systemName: row.icon)
          .font(.caption.weight(.bold))
          .foregroundStyle(AppDesign.accent)
        Text(row.title)
          .font(.caption.weight(.bold))
          .foregroundStyle(AppDesign.primaryText)
          .lineLimit(1)
      }

      Text(row.bestText)
        .font(.title3.weight(.bold).monospacedDigit())
        .foregroundStyle(AppDesign.accent)
        .lineLimit(1)
        .minimumScaleFactor(0.7)

      Text(row.metricLabel)
        .font(.caption2)
        .foregroundStyle(AppDesign.tertiaryText)
        .lineLimit(1)

      HStack {
        Text("Last")
          .font(.caption2.weight(.semibold))
          .foregroundStyle(AppDesign.tertiaryText)
        Spacer()
        Text(row.lastText)
          .font(.caption.weight(.semibold).monospacedDigit())
          .foregroundStyle(AppDesign.secondaryText)
          .lineLimit(1)
      }
    }
    .padding(AppDesign.spacingM)
    .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
    .background(AppDesign.surface.opacity(0.7), in: RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous)
        .stroke(AppDesign.gridLine, lineWidth: 1)
    }
  }
}
