//
//  GridScoreCard.swift
//  SlayGem
//

import SwiftUI

struct GridScoreCard: View {
  let score: Int
  let caption: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: AppDesign.spacingL) {
        VStack(alignment: .leading, spacing: 8) {
          Label("GRID SCORE", systemImage: "chart.line.uptrend.xyaxis")
            .font(.caption.weight(.bold))
            .foregroundStyle(AppDesign.tertiaryText)

          Text("\(score)")
            .font(.system(.largeTitle, design: .rounded).weight(.bold).monospacedDigit())
            .foregroundStyle(AppDesign.primaryText)

          Text(caption)
            .font(.subheadline)
            .foregroundStyle(AppDesign.secondaryText)

          Capsule()
            .fill(Color.clear)
            .frame(width: 80, height: 80)
            .overlay {
              Circle()
                .trim(from: 0, to: 0.35)
                .stroke(AppDesign.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(135))
            }
            .offset(x: -10, y: -8)
        }

        Spacer()

        MatrixThumbnailView(style: .decorative, size: 72)

        Image(systemName: "chevron.right")
          .foregroundStyle(AppDesign.tertiaryText)
      }
      .gridCard()
    }
    .contentShape(Rectangle())
    .buttonStyle(.plain)
  }
}
