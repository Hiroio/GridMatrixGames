//
//  Design.swift
//  SpinGrid
//

import SwiftUI

enum AppDesign {
  static let appName = "SpinGrid"
  static let tagline = "Matrix Cognition Lab"

  static let spacingXS: CGFloat = 4
  static let spacingS: CGFloat = 8
  static let spacingM: CGFloat = 12
  static let spacingL: CGFloat = 16
  static let spacingXL: CGFloat = 24
  static let spacingXXL: CGFloat = 32
  static let screenPadding: CGFloat = 20
  static let tabBarHeight: CGFloat = 56

  static let cellCorner: CGFloat = 8
  static let cardCorner: CGFloat = 14
  static let buttonCorner: CGFloat = 12
  static let tabBarCornerRadius: CGFloat = 22
  static let chipCorner: CGFloat = 8
  static let matrixFrameInset: CGFloat = 10
  static let headerHeight: CGFloat = 52
  static let footerHeight: CGFloat = 72

  static let background = Color(red: 0.18, green: 0.094, blue: 0.282)
  static let backgroundElevated = Color(red: 0.227, green: 0.133, blue: 0.345)
  static let surface = Color(red: 0.271, green: 0.165, blue: 0.408).opacity(0.88)

  static let primaryText = Color.white
  static let secondaryText = Color.white.opacity(0.72)
  static let tertiaryText = Color.white.opacity(0.48)

  static let accent = Color(red: 0.957, green: 0.769, blue: 0.188)
  static let accentMuted = Color(red: 0.957, green: 0.769, blue: 0.188).opacity(0.22)
  static let ctaTextOnAccent = Color(red: 0.18, green: 0.094, blue: 0.282)

  static let gridLine = Color.white.opacity(0.28)
  static let gridLineStrong = Color.white.opacity(0.55)
  static let stageFrame = Color.white.opacity(0.38)
  static let ambientGrid = Color.white.opacity(0.06)

  static let cellOn = accent
  static let cellOff = background
  static let cellPath = accent.opacity(0.65)
  static let cellMark = Color.white.opacity(0.18)
  static let cellBlocked = Color(red: 0.42, green: 0.29, blue: 0.51)

  static let success = accent
  static let warning = Color(red: 1.0, green: 0.42, blue: 0.42)
  static let timerTrack = Color.white.opacity(0.12)
  static let cardShadow = Color.black.opacity(0.28)

  static let tabAnimation: Animation = .easeInOut(duration: 0.22)
  static let springAnimation: Animation = .spring(response: 0.32, dampingFraction: 0.78)
  static let cellTapSpring: Animation = .spring(response: 0.32, dampingFraction: 0.78)
  static let cellFill: Animation = .easeOut(duration: 0.15)
  static let smoothAnimation: Animation = .spring(response: 0.55, dampingFraction: 0.86)
  static let flashInAnimation: Animation = .easeOut(duration: 0.14)
  static let flashOutAnimation: Animation = .easeInOut(duration: 0.16)

  static let gridCellSpring: Animation = .spring(response: 0.36, dampingFraction: 0.8)
  static let gridCellPop: Animation = .spring(response: 0.28, dampingFraction: 0.68)
  static let tabContentAnimation: Animation = .spring(response: 0.42, dampingFraction: 0.88)
  static let overlayAnimation: Animation = .spring(response: 0.48, dampingFraction: 0.86)
  static let phaseAnimation: Animation = .spring(response: 0.5, dampingFraction: 0.9)
  static let segmentAnimation: Animation = .spring(response: 0.34, dampingFraction: 0.82)

  static func pairShade(_ index: Int) -> Color {
    let opacities: [CGFloat] = [1.0, 0.72, 0.55, 0.4]
    return accent.opacity(opacities[min(index, opacities.count - 1)])
  }
}
