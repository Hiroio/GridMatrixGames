//
//  CustomTabBar.swift
//  SpinGrid
//

import SwiftUI

struct CustomTabBar: View {
  @Environment(NavigationManager.self) private var navigation

  var body: some View {
    HStack(spacing: 0) {
      ForEach(MainScreensEnum.allCases) { screen in
        tabButton(for: screen)
      }
    }
    .padding(.horizontal, 8)
    .frame(height: AppDesign.tabBarHeight)
    .background {
      RoundedRectangle(cornerRadius: AppDesign.tabBarCornerRadius, style: .continuous)
        .fill(AppDesign.backgroundElevated.opacity(0.96))
        .overlay {
          RoundedRectangle(cornerRadius: AppDesign.tabBarCornerRadius, style: .continuous)
            .stroke(AppDesign.gridLine, lineWidth: 1)
        }
    }
    .padding(.horizontal, AppDesign.screenPadding)
    .padding(.bottom, 10)
  }

  private func tabButton(for screen: MainScreensEnum) -> some View {
    let isSelected = navigation.mainScreen == screen

    return Button {
      navigation.selectTab(screen)
    } label: {
      VStack(spacing: 4) {
        Image(systemName: screen.icon)
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(isSelected ? AppDesign.accent : AppDesign.tertiaryText)

        if isSelected {
          RoundedRectangle(cornerRadius: 1, style: .continuous)
            .fill(AppDesign.accent)
            .frame(width: 4, height: 4)
            .transition(.scale.combined(with: .opacity))
        } else {
          Color.clear.frame(width: 4, height: 4)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 8)
      .animation(AppDesign.segmentAnimation, value: isSelected)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(screen.title)
  }
}
