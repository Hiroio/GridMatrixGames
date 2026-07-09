//
//  StudioGameTile.swift
//  SpinGrid
//

import SwiftUI

struct StudioGameTile: View {
  let thumbnailStyle: MatrixThumbnailStyle
  let title: String
  let subtitle: String
  var difficultyHint: String = "Easy · Med · Hard"
  var isLocked = false
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 0) {
        ZStack {
          RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous)
            .fill(AppDesign.backgroundElevated)
            .frame(height: 96)
            .overlay {
              RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous)
                .stroke(AppDesign.accentMuted, lineWidth: 1)
            }

          MatrixThumbnailView(style: thumbnailStyle, size: 64)

          if isLocked {
            VStack {
              HStack {
                Spacer()
                Label("Premium", systemImage: "lock.fill")
                  .font(.caption2.weight(.bold))
                  .foregroundStyle(AppDesign.primaryText)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
              }
              Spacer()
            }
            .padding(8)
          }
        }

        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(AppDesign.primaryText)
            .lineLimit(1)

          Text(subtitle)
            .font(.caption)
            .foregroundStyle(AppDesign.secondaryText)
            .lineLimit(2)
            .frame(minHeight: 30, alignment: .topLeading)

          Text(difficultyHint)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(AppDesign.accent.opacity(0.9))
        }
        .padding(.horizontal, AppDesign.spacingM)
        .padding(.vertical, AppDesign.spacingS)
      }
      .background(AppDesign.surface.opacity(0.6), in: RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous)
          .stroke(AppDesign.gridLine, lineWidth: 1)
      }
    }
    .buttonStyle(StudioGameTileButtonStyle())
  }
}

private struct StudioGameTileButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.97 : 1)
      .animation(AppDesign.cellTapSpring, value: configuration.isPressed)
  }
}

extension GameType {
  var difficultyHint: String {
    switch self {
    case .flipMatrix: "3×3 · 4×4 · 5×5"
    case .blockFlow: "2–4 pairs"
    case .deductionRows: "3×3 · 5×5"
    case .slideFusion: "4×4 · 5×5 · 6×6"
    }
  }
}
