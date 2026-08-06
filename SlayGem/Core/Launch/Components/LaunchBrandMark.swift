//
//  LaunchBrandMark.swift
//  SlayGem
//

import SwiftUI

struct LaunchBrandMark: View {
  var pulseScale: CGFloat = 1
  var size: CGFloat = 96

  var body: some View {
    ZStack {
      Circle()
        .fill(AppDesign.accent.opacity(0.1))
        .frame(width: size * 1.35, height: size * 1.35)

      SlayGemShape()
        .fill(
          LinearGradient(
            colors: [
              Color(red: 119 / 255, green: 228 / 255, blue: 92 / 255),
              AppDesign.accent,
              Color(red: 40 / 255, green: 140 / 255, blue: 40 / 255),
            ],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .frame(width: size * 0.62, height: size * 0.78)
        .overlay {
          SlayGemShape()
            .stroke(AppDesign.gemMint, lineWidth: 2.5)
        }
        .overlay {
          // Facet highlight
          SlayGemShape()
            .fill(
              LinearGradient(
                colors: [Color.white.opacity(0.35), .clear],
                startPoint: .topLeading,
                endPoint: .center
              )
            )
            .padding(size * 0.08)
            .blendMode(.screen)
        }
        .scaleEffect(pulseScale)
    }
    .frame(width: size * 1.4, height: size * 1.4)
  }
}

/// Vertical hex gem — SLOTS GEM silhouette.
struct SlayGemShape: Shape {
  func path(in rect: CGRect) -> Path {
    let w = rect.width
    let h = rect.height
    var path = Path()
    path.move(to: CGPoint(x: w * 0.5, y: 0))
    path.addLine(to: CGPoint(x: w, y: h * 0.22))
    path.addLine(to: CGPoint(x: w, y: h * 0.78))
    path.addLine(to: CGPoint(x: w * 0.5, y: h))
    path.addLine(to: CGPoint(x: 0, y: h * 0.78))
    path.addLine(to: CGPoint(x: 0, y: h * 0.22))
    path.closeSubpath()
    return path
  }
}

/// "Slay" white + "Gem" gold — bold italic wordmark.
struct SlayGemTitleText: View {
  var size: CGFloat = 32

  var body: some View {
    HStack(spacing: 0) {
      Text("Slay")
        .foregroundStyle(AppDesign.primaryText)
      Text("Gem")
        .foregroundStyle(AppDesign.accentSecondary)
    }
    .font(.system(size: size, weight: .heavy, design: .default))
    .italic()
    .tracking(0.8)
  }
}

#Preview {
  ZStack {
    AppDesign.background.ignoresSafeArea()
    VStack(spacing: 24) {
      LaunchBrandMark()
      SlayGemTitleText()
    }
  }
}
