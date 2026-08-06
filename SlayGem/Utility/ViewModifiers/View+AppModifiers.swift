//
//  View+AppModifiers.swift
//  SlayGem
//

import SwiftUI

extension View {
  func gridCard(padding: CGFloat = AppDesign.spacingL) -> some View {
    self
      .padding(padding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous)
          .stroke(AppDesign.gridLine, lineWidth: 1)
      }
  }

  func gridAccentButton() -> some View {
    buttonStyle(GridAccentButtonStyle())
  }

  func gridTransparentScroll() -> some View {
    scrollContentBackground(.hidden)
  }
}

struct GridAccentButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline.weight(.bold))
      .foregroundStyle(AppDesign.ctaTextOnAccent)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(AppDesign.accent, in: RoundedRectangle(cornerRadius: AppDesign.buttonCorner, style: .continuous))
      .contentShape(Rectangle())
      .scaleEffect(configuration.isPressed ? 0.98 : 1)
      .animation(AppDesign.cellTapSpring, value: configuration.isPressed)
  }
}
