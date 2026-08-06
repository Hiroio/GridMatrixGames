//
//  NonogramBoardView.swift
//  SlayGem
//

import SwiftUI

struct NonogramBoardView: View {
  let size: Int
  let rowClues: [[Int]]
  let colClues: [[Int]]
  let states: [GridCellState]
  let onTap: (Int) -> Void
  let onMark: (Int) -> Void

  private let clueWidth: CGFloat = 28
  private let spacing = AppDesign.spacingM

  var body: some View {
    GeometryReader { geo in
      let cellSide = cellSide(in: geo.size)

      VStack(spacing: spacing) {
        HStack(spacing: spacing) {
          Color.clear.frame(width: clueWidth, height: clueWidth)
          ForEach(0..<size, id: \.self) { col in
            clueLabel(colClues[safe: col] ?? [], vertical: true)
              .frame(width: cellSide, height: clueWidth)
          }
        }

        ForEach(0..<size, id: \.self) { row in
          HStack(spacing: spacing) {
            clueLabel(rowClues[safe: row] ?? [], vertical: false)
              .frame(width: clueWidth, height: cellSide, alignment: .trailing)

            ForEach(0..<size, id: \.self) { col in
              let index = row * size + col
              let state = states[safe: index] ?? .off

              Button {
                withAnimation(AppDesign.gridCellSpring) {
                  onTap(index)
                }
              } label: {
                GridCellView(state: state)
                  .frame(width: cellSide, height: cellSide)
              }
              .buttonStyle(MatrixCellButtonStyle())
              .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.35)
                  .onEnded { _ in
                    withAnimation(AppDesign.gridCellSpring) {
                      onMark(index)
                    }
                  }
              )
              .animation(AppDesign.gridCellSpring, value: state)
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    .aspectRatio(boardAspectRatio, contentMode: .fit)
  }

  private var boardAspectRatio: CGFloat {
    let gridWidth = CGFloat(size) + clueWidth / 50
    let gridHeight = CGFloat(size + 1)
    return gridWidth / gridHeight
  }

  private func cellSide(in containerSize: CGSize) -> CGFloat {
    let clueColumn = clueWidth + spacing
    let horizontalGaps = spacing * CGFloat(self.size)
    let verticalGaps = spacing * CGFloat(self.size)
    let clueRow = clueWidth + spacing

    let widthBudget = containerSize.width - clueColumn - horizontalGaps
    let heightBudget = containerSize.height - clueRow - verticalGaps

    let fromWidth = widthBudget / CGFloat(self.size)
    let fromHeight = heightBudget / CGFloat(self.size)
    return max(24, min(fromWidth, fromHeight))
  }

  @ViewBuilder
  private func clueLabel(_ clues: [Int], vertical: Bool) -> some View {
    if clues.isEmpty {
      Text("0")
        .font(.caption.weight(.bold).monospacedDigit())
        .foregroundStyle(AppDesign.tertiaryText)
    } else if clues.count == 1 {
      Text("\(clues[0])")
        .font(.caption.weight(.bold).monospacedDigit())
        .foregroundStyle(AppDesign.accent)
    } else {
      let separator = vertical ? "\n" : " · "
      Text(clues.map(String.init).joined(separator: separator))
        .font(.caption2.weight(.bold).monospacedDigit())
        .foregroundStyle(AppDesign.accent)
        .multilineTextAlignment(vertical ? .center : .trailing)
        .minimumScaleFactor(0.6)
    }
  }
}

private extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
