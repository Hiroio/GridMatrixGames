//
//  SFSymbolBadge.swift
//  SpinGrid
//

import SwiftUI

struct SFSymbolBadge: View {
  let systemName: String
  var size: CGFloat = 28
  var iconSize: CGFloat = 13

  var body: some View {
    Image(systemName: systemName)
      .font(.system(size: iconSize, weight: .semibold))
      .foregroundStyle(AppDesign.accent)
      .frame(width: size, height: size)
      .background(AppDesign.accentMuted, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
  }
}

struct LabeledGridButton: View {
  let title: String
  let systemName: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 10) {
        Image(systemName: systemName)
          .font(.body.weight(.semibold))
        Text(title)
          .font(.headline.weight(.bold))
      }
      .frame(maxWidth: .infinity)
    }
    .gridAccentButton()
  }
}
