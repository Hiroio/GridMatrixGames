//
//  GameDifficultyPicker.swift
//  SlayGem
//

import SwiftUI

struct GameDifficultyPicker: View {
  @Binding var selection: GridDifficulty
  var isPremium: Bool
  var onHardLocked: () -> Void

  var gridLabel: (GridDifficulty) -> String = { $0.gridLabel }

  var body: some View {
    HStack(spacing: AppDesign.spacingS) {
      ForEach(GridDifficulty.allCases) { difficulty in
        difficultyTile(difficulty)
      }
    }
  }

  private func difficultyTile(_ difficulty: GridDifficulty) -> some View {
    let isSelected = selection == difficulty
    let isLocked = difficulty == .hard && !isPremium

    return Button {
      if isLocked {
        onHardLocked()
      } else {
        withAnimation(AppDesign.segmentAnimation) {
          selection = difficulty
        }
      }
    } label: {
      HStack(spacing: 4) {
        Text(difficulty.title)
          .font(.caption.weight(.bold))
        Text(gridLabel(difficulty))
          .font(.caption2)
          .opacity(0.75)
      }
      .foregroundStyle(isSelected ? AppDesign.ctaTextOnAccent : AppDesign.secondaryText)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 9)
      .background(
        isSelected ? AppDesign.accent : AppDesign.surface,
        in: RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous)
      )
      .overlay {
        RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous)
          .stroke(isSelected ? AppDesign.accent : AppDesign.gridLine, lineWidth: 1)
      }
      .overlay(alignment: .topTrailing) {
        if isLocked {
          Image(systemName: "lock.fill")
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(AppDesign.tertiaryText)
            .padding(5)
        }
      }
      .animation(AppDesign.segmentAnimation, value: isSelected)
    }
    .contentShape(Rectangle())
    .buttonStyle(.plain)
  }
}
