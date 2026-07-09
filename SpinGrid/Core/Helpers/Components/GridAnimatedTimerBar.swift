//
//  GridAnimatedTimerBar.swift
//  SpinGrid
//

import SwiftUI

struct GridAnimatedTimerBar: View {
  let progress: CGFloat
  var segments = 20

  var body: some View {
    HStack(spacing: 3) {
      ForEach(0..<segments, id: \.self) { index in
        let threshold = CGFloat(index + 1) / CGFloat(segments)
        let isFilled = progress >= threshold
        RoundedRectangle(cornerRadius: 2, style: .continuous)
          .fill(isFilled ? AppDesign.accent : AppDesign.timerTrack)
          .frame(height: 8)
          .scaleEffect(x: 1, y: isFilled ? 1 : 0.7, anchor: .center)
          .animation(AppDesign.gridCellSpring.delay(Double(index) * 0.01), value: isFilled)
      }
    }
    .animation(AppDesign.gridCellSpring, value: progress)
  }
}
