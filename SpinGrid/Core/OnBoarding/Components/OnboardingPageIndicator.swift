//
//  OnboardingPageIndicator.swift
//  SpinGrid
//

import SwiftUI

struct OnboardingPageIndicator: View {
  let count: Int
  let current: Int

  var body: some View {
    HStack(spacing: 6) {
      ForEach(0..<count, id: \.self) { index in
        RoundedRectangle(cornerRadius: 1, style: .continuous)
          .fill(index == current ? AppDesign.accent : AppDesign.gridLine)
          .frame(width: 6, height: 6)
          .scaleEffect(index == current ? 1.15 : 1)
          .animation(AppDesign.segmentAnimation, value: current)
      }
    }
  }
}
