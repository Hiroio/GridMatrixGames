//
//  BlockFlowBoardView.swift
//  SlayGem
//

import SwiftUI

struct BlockFlowBoardView: View {
  let size: Int
  let states: [GridCellState]
  let labels: [String?]
  let pairShades: [Int]
  let onDragChanged: (Int) -> Void
  let onDragEnded: () -> Void

  @State private var lastDragIndex: Int?

  private var columns: [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: AppDesign.spacingM), count: size)
  }

  var body: some View {
    GeometryReader { geo in
      let spacing = AppDesign.spacingM
      let side = min(geo.size.width, geo.size.height)
      let cellSide = (side - spacing * CGFloat(size - 1)) / CGFloat(size)
      let stride = cellSide + spacing

      ZStack {
        LazyVGrid(columns: columns, spacing: spacing) {
          ForEach(0..<(size * size), id: \.self) { index in
          GridCellView(
            state: states[safe: index] ?? .off,
            label: labels[safe: index] ?? nil,
            pairShadeIndex: pairShades[safe: index] ?? 0
          )
          .frame(width: cellSide, height: cellSide)
          .animation(AppDesign.gridCellSpring, value: states[safe: index])
          .animation(AppDesign.gridCellSpring, value: labels[safe: index])
          }
        }
        .frame(width: side, height: side)

        Color.clear
          .frame(width: side, height: side)
          .contentShape(Rectangle())
          .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
              .onChanged { value in
                guard let index = cellIndex(
                  at: value.location,
                  cellSide: cellSide,
                  stride: stride
                ) else { return }
                guard lastDragIndex != index else { return }
                lastDragIndex = index
                onDragChanged(index)
              }
              .onEnded { _ in
                lastDragIndex = nil
                onDragEnded()
              }
          )
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    .aspectRatio(1, contentMode: .fit)
  }

  private func cellIndex(at point: CGPoint, cellSide: CGFloat, stride: CGFloat) -> Int? {
    var col = Int(point.x / stride)
    var row = Int(point.y / stride)
    col = min(max(0, col), size - 1)
    row = min(max(0, row), size - 1)

    let localX = point.x - CGFloat(col) * stride
    let localY = point.y - CGFloat(row) * stride
    if localX > cellSide, col < size - 1 { col += 1 }
    if localY > cellSide, row < size - 1 { row += 1 }

    return row * size + col
  }
}

private extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
