//
//  MetricChip.swift
//  SlayGem
//

import SwiftUI

struct MetricChip: View {
  let label: String
  let value: String
  var systemName: String?

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack(spacing: 4) {
        if let systemName {
          Image(systemName: systemName)
            .font(.caption2.weight(.bold))
            .foregroundStyle(AppDesign.accent)
        }
        Text(label.uppercased())
          .font(.caption2.weight(.bold))
          .foregroundStyle(AppDesign.tertiaryText)
      }
      Text(value)
        .font(.subheadline.weight(.bold).monospacedDigit())
        .foregroundStyle(AppDesign.primaryText)
        .contentTransition(.numericText())
        .animation(AppDesign.gridCellSpring, value: value)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(AppDesign.backgroundElevated, in: RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous)
        .stroke(AppDesign.gridLine, lineWidth: 1)
    }
  }
}
