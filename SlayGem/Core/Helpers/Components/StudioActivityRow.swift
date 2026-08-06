//
//  StudioActivityRow.swift
//  SlayGem
//

import SwiftUI

struct StudioActivityRow: View {
  let thumbnailStyle: MatrixThumbnailStyle
  let title: String
  let subtitle: String
  var isLocked = false
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: AppDesign.spacingM) {
        MatrixThumbnailView(style: thumbnailStyle, size: 44)

        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.headline.weight(.semibold))
            .foregroundStyle(AppDesign.primaryText)
          Text(subtitle)
            .font(.caption)
            .foregroundStyle(AppDesign.secondaryText)
        }

        Spacer(minLength: 0)

        Image(systemName: isLocked ? "lock.fill" : "chevron.right")
          .font(.caption.weight(.bold))
          .foregroundStyle(AppDesign.tertiaryText)
      }
      .padding(AppDesign.spacingM)
      .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous)
          .stroke(AppDesign.gridLine, lineWidth: 1)
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}

extension TestType {
  var thumbnailStyle: MatrixThumbnailStyle {
    switch self {
    case .gridSearch: .gridSearch
    case .missingLink: .missingLink
    case .gridWeights: .gridWeights
    case .memoryBlitz: .memoryBlitz
    }
  }
}

extension GameType {
  var thumbnailStyle: MatrixThumbnailStyle {
    switch self {
    case .flipMatrix: .flipMatrix
    case .blockFlow: .blockFlow
    case .deductionRows: .deductionRows
    case .slideFusion: .slideFusion
    }
  }
}
