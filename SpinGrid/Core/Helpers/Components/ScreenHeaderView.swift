//
//  ScreenHeaderView.swift
//  SpinGrid
//

import SwiftUI

struct ScreenHeaderView: View {
  let title: String
  let subtitle: String
  var icon: String?

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 10) {
        if let icon {
          Image(systemName: icon)
            .font(.title3.weight(.semibold))
            .foregroundStyle(AppDesign.accent)
        }
        Text(title)
          .font(.title2.weight(.bold))
          .foregroundStyle(AppDesign.primaryText)
      }
      Text(subtitle)
        .font(.subheadline)
        .foregroundStyle(AppDesign.secondaryText)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
