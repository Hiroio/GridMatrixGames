//
//  ProfileLinkRow.swift
//  SlayGem
//

import SwiftUI

struct ProfileLinkRow: View {
  let title: String
  let subtitle: String
  let systemName: String
  var showsChevron = true
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: AppDesign.spacingM) {
        SFSymbolBadge(systemName: systemName, size: 36, iconSize: 15)

        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppDesign.primaryText)
          Text(subtitle)
            .font(.caption)
            .foregroundStyle(AppDesign.tertiaryText)
        }

        Spacer(minLength: 0)

        if showsChevron {
          Image(systemName: "arrow.up.right")
            .font(.caption.weight(.bold))
            .foregroundStyle(AppDesign.accent)
            .padding(8)
            .background(AppDesign.accentMuted, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
      }
      .padding(AppDesign.spacingM)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}

struct ProfileToggleRow: View {
  let title: String
  let subtitle: String
  let systemName: String
  @Binding var isOn: Bool

  var body: some View {
    HStack(spacing: AppDesign.spacingM) {
      SFSymbolBadge(systemName: systemName, size: 36, iconSize: 15)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(AppDesign.primaryText)
        Text(subtitle)
          .font(.caption)
          .foregroundStyle(AppDesign.tertiaryText)
      }

      Spacer()

      Toggle("", isOn: $isOn)
        .labelsHidden()
        .tint(AppDesign.accent)
    }
    .padding(AppDesign.spacingM)
  }
}
