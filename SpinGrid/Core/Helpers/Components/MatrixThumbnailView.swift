//
//  MatrixThumbnailView.swift
//  SpinGrid
//

import SwiftUI

enum MatrixThumbnailStyle {
  case gridSearch
  case missingLink
  case gridWeights
  case memoryBlitz
  case flipMatrix
  case blockFlow
  case deductionRows
  case slideFusion
  case decorative
}

struct MatrixThumbnailView: View {
  var style: MatrixThumbnailStyle = .decorative
  var size: CGFloat = 44

  private let gridSize = 3

  var body: some View {
    let cell = max(6, (size - AppDesign.spacingS * CGFloat(gridSize - 1)) / CGFloat(gridSize))
    LazyVGrid(
      columns: Array(repeating: GridItem(.fixed(cell), spacing: AppDesign.spacingS), count: gridSize),
      spacing: AppDesign.spacingS
    ) {
      ForEach(0..<(gridSize * gridSize), id: \.self) { index in
        RoundedRectangle(cornerRadius: 3, style: .continuous)
          .fill(cellOn(index) ? AppDesign.accent : AppDesign.cellOff)
          .frame(width: cell, height: cell)
          .overlay {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
              .stroke(
                missingLinkGap(index) ? AppDesign.accent : AppDesign.gridLine,
                style: missingLinkGap(index)
                  ? StrokeStyle(lineWidth: 1.2, dash: [3, 2])
                  : StrokeStyle(lineWidth: 0.5)
              )
          }
      }
    }
    .frame(width: size, height: size)
  }

  private func cellOn(_ index: Int) -> Bool {
    switch style {
    case .gridSearch: [0, 4, 8].contains(index)
    case .missingLink: [1, 2, 5, 7, 6, 3].contains(index)
    case .gridWeights: index % 3 == 0 || index == 8
    case .memoryBlitz: [1, 3, 4, 7].contains(index)
    case .flipMatrix: index % 2 == 0
    case .blockFlow: [0, 2, 6, 8].contains(index)
    case .deductionRows: [0, 1, 3, 4, 6].contains(index)
    case .slideFusion: [0, 1, 4].contains(index)
    case .decorative: [1, 3, 4, 7].contains(index)
    }
  }

  private func missingLinkGap(_ index: Int) -> Bool {
    style == .missingLink && index == 4
  }
}
