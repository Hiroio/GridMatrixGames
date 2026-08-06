//
//  LaunchLoadingBar.swift
//  SlayGem
//

import SwiftUI

struct LaunchLoadingBar: View {
  let progress: CGFloat
  var segments = 16

  var body: some View {
    VStack(spacing: AppDesign.spacingS) {
      HStack(spacing: 3) {
        ForEach(0..<segments, id: \.self) { index in
          let threshold = CGFloat(index + 1) / CGFloat(segments)
          RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(progress >= threshold ? AppDesign.accent : AppDesign.timerTrack)
            .frame(width: 10, height: 10)
            .scaleEffect(progress >= threshold ? 1 : 0.82)
            .animation(
              AppDesign.gridCellSpring.delay(Double(index) * 0.015),
              value: progress >= threshold
            )
        }
      }

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(AppDesign.timerTrack)
            .frame(height: 4)
          Capsule()
            .fill(AppDesign.accent)
            .frame(width: max(0, geo.size.width * progress), height: 4)
            .animation(AppDesign.smoothAnimation, value: progress)
        }
      }
      .frame(height: 4)
    }
    .frame(maxWidth: 220)
  }
}
