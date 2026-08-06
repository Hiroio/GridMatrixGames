//
//  AppBackgroundView.swift
//  SlayGem
//

import SwiftUI

struct AppBackgroundView: View {
  var showsAmbientGrid = true
  var showsGems = true

  var body: some View {
    ZStack {
      AppDesign.background.ignoresSafeArea()

      RadialGradient(
        colors: [AppDesign.accent.opacity(0.14), .clear],
        center: .topTrailing,
        startRadius: 0,
        endRadius: 400
      )
      .ignoresSafeArea()

      RadialGradient(
        colors: [AppDesign.accentSecondary.opacity(0.08), .clear],
        center: .bottomLeading,
        startRadius: 0,
        endRadius: 360
      )
      .ignoresSafeArea()

      if showsAmbientGrid {
        AmbientGridPattern()
          .ignoresSafeArea()
      }

      if showsGems {
        SoftGemField()
          .ignoresSafeArea()
      }
    }
  }
}

/// A few faint green gems in the corners — atmosphere only.
private struct SoftGemField: View {
  @State private var phase: CGFloat = 0

  private let gems: [(x: CGFloat, y: CGFloat, size: CGFloat, rot: Double, delay: CGFloat)] = [
    (0.08, 0.18, 14, -12, 0),
    (0.9, 0.28, 11, 18, 0.2),
    (0.12, 0.78, 10, 8, 0.4),
    (0.86, 0.82, 13, -20, 0.15),
    (0.72, 0.12, 8, 6, 0.55),
  ]

  var body: some View {
    GeometryReader { geo in
      ForEach(Array(gems.enumerated()), id: \.offset) { _, gem in
        SlayGemShape()
          .fill(
            LinearGradient(
              colors: [
                AppDesign.gemMint.opacity(0.55),
                AppDesign.accent.opacity(0.45),
                AppDesign.accent.opacity(0.2),
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
          .overlay {
            SlayGemShape()
              .stroke(AppDesign.gemMint.opacity(0.35), lineWidth: 1)
          }
          .frame(width: gem.size * 0.72, height: gem.size)
          .rotationEffect(.degrees(gem.rot))
          .opacity(0.18 + Double(gem.delay) * 0.12)
          .blur(radius: 0.3)
          .offset(y: sin((phase + gem.delay) * .pi * 2) * 3)
          .position(
            x: geo.size.width * gem.x,
            y: geo.size.height * gem.y
          )
      }
    }
    .allowsHitTesting(false)
    .onAppear {
      withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
        phase = 1
      }
    }
  }
}
