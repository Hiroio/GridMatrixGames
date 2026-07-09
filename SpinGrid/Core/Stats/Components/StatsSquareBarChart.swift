//
//  StatsSquareBarChart.swift
//  SpinGrid
//

import SwiftUI

struct StatsSquareBarChart: View {
  let values: [CGFloat]
  var compact = false

  private var dayLabels: [String] {
    ["M", "T", "W", "T", "F", "S", "S"]
  }

  var body: some View {
    GeometryReader { geo in
      let count = max(values.count, 1)
      let spacing: CGFloat = compact ? 1.5 : 6
      let barWidth = max(3, (geo.size.width - spacing * CGFloat(count - 1)) / CGFloat(count))

      HStack(alignment: .bottom, spacing: spacing) {
        ForEach(Array(values.enumerated()), id: \.offset) { index, value in
          VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: compact ? 1.5 : 2, style: .continuous)
              .fill(value > 0 ? AppDesign.accent : AppDesign.timerTrack)
              .frame(width: barWidth, height: max(4, 36 * value))

            if !compact {
              Text(dayLabels[safe: index] ?? "")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppDesign.tertiaryText)
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
    }
    .frame(height: compact ? 44 : 52)
  }
}

private extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
