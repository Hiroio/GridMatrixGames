//
//  MissingLinkBoardView.swift
//  SpinGrid
//

import SwiftUI

struct MissingLinkBoardView: View {
  let size: Int
  let pathIndices: [Int]
  let gapIndex: Int
  var wrongTapIndex: Int?
  var highlightGap = false
  var interactive = true
  var onTap: ((Int) -> Void)?

  private var columns: [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: AppDesign.spacingM), count: size)
  }

  var body: some View {
    GeometryReader { geo in
      let cellSide = cellSide(in: geo.size)

      ZStack {
        connectorLines(cellSide: cellSide, in: geo.size)

        LazyVGrid(columns: columns, spacing: AppDesign.spacingM) {
          ForEach(0..<(size * size), id: \.self) { index in
            cellButton(at: index, side: cellSide)
          }
        }
      }
    }
    .aspectRatio(1, contentMode: .fit)
  }

  @ViewBuilder
  private func cellButton(at index: Int, side: CGFloat) -> some View {
    let state = cellState(at: index)
    let shade = pathShade(for: index)

    if interactive, let onTap {
      Button {
        withAnimation(AppDesign.gridCellPop) {
          onTap(index)
        }
      } label: {
        GridCellView(state: state, pairShadeIndex: shade)
          .frame(width: side, height: side)
      }
      .buttonStyle(MatrixCellButtonStyle())
      .animation(AppDesign.gridCellSpring, value: state)
      .animation(AppDesign.gridCellSpring, value: wrongTapIndex)
    } else {
      GridCellView(state: state, pairShadeIndex: shade)
        .frame(width: side, height: side)
        .animation(AppDesign.gridCellSpring, value: state)
    }
  }

  private func connectorLines(cellSide: CGFloat, in containerSize: CGSize) -> some View {
    Canvas { context, canvasSize in
      let spacing = AppDesign.spacingM
      let stride = cellSide + spacing
      let originX = (canvasSize.width - stride * CGFloat(size) + spacing) / 2 + cellSide / 2
      let originY = (canvasSize.height - stride * CGFloat(size) + spacing) / 2 + cellSide / 2

      func center(for index: Int) -> CGPoint {
        let row = index / size
        let col = index % size
        return CGPoint(
          x: originX + CGFloat(col) * stride,
          y: originY + CGFloat(row) * stride
        )
      }

      for pair in zip(pathIndices, pathIndices.dropFirst()) {
        let start = center(for: pair.0)
        let end = center(for: pair.1)
        let isBroken = pair.0 == gapIndex || pair.1 == gapIndex

        var path = Path()
        path.move(to: start)
        path.addLine(to: end)

        context.stroke(
          path,
          with: .color(isBroken ? AppDesign.accent.opacity(0.45) : AppDesign.accent.opacity(0.9)),
          style: StrokeStyle(
            lineWidth: isBroken ? 2 : 3.5,
            lineCap: .round,
            dash: isBroken ? [5, 4] : []
          )
        )
      }
    }
    .allowsHitTesting(false)
  }

  private func cellState(at index: Int) -> GridCellState {
    if index == gapIndex {
      return highlightGap ? .target : .gap
    }
    if index == wrongTapIndex {
      return .wrongPick
    }
    if pathIndices.contains(index) {
      return .path
    }
    return .off
  }

  private func pathShade(for index: Int) -> Int {
    guard let position = pathIndices.firstIndex(of: index) else { return 0 }
    return min(position, 3)
  }

  private func cellSide(in containerSize: CGSize) -> CGFloat {
    let spacing = AppDesign.spacingM
    let gaps = spacing * CGFloat(size - 1)
    let side = (min(containerSize.width, containerSize.height) - gaps) / CGFloat(size)
    return max(24, side)
  }
}

enum MissingLinkDemo {
  static let previewSize = 3
  static let previewPath = [1, 2, 5, 7, 6, 3]
  static let previewGap = 4
}
