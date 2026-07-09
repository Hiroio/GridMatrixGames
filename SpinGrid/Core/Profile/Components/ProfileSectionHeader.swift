//
//  ProfileSectionHeader.swift
//  SpinGrid
//

import SwiftUI

struct ProfileSectionHeader: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.caption.weight(.bold))
      .foregroundStyle(AppDesign.tertiaryText)
      .textCase(.uppercase)
      .tracking(0.8)
      .padding(.leading, 2)
  }
}

struct ProfileSection<Content: View>: View {
  let title: String
  @ViewBuilder var content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: AppDesign.spacingS) {
      ProfileSectionHeader(title: title)
      content()
    }
  }
}
