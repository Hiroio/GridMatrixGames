//
//  LeftRightChoiceBar.swift
//  SpinGrid
//

import SwiftUI

struct LeftRightChoiceBar: View {
  let onLeft: () -> Void
  let onRight: () -> Void

  var body: some View {
    HStack(spacing: AppDesign.spacingM) {
      choiceButton("Left", action: onLeft)
      choiceButton("Right", action: onRight)
    }
  }

  private func choiceButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(.headline.weight(.bold))
        .foregroundStyle(AppDesign.ctaTextOnAccent)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppDesign.accent, in: RoundedRectangle(cornerRadius: AppDesign.buttonCorner, style: .continuous))
    }
    .buttonStyle(.plain)
  }
}
