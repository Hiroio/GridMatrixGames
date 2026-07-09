//
//  MatrixGridView.swift
//  SpinGrid
//

import SwiftUI

struct MatrixGridView: View {
  let size: Int
  let states: [GridCellState]
  var labels: [String?] = []
  var interactive = true
  var onTap: ((Int) -> Void)?

  private var columns: [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: AppDesign.spacingM), count: size)
  }

  var body: some View {
    LazyVGrid(columns: columns, spacing: AppDesign.spacingM) {
      ForEach(0..<(size * size), id: \.self) { index in
        let cellState = index < states.count ? states[index] : .off
        let label = index < labels.count ? labels[index] : nil

        if interactive, let onTap {
          Button {
            withAnimation(AppDesign.gridCellPop) {
              onTap(index)
            }
          } label: {
            GridCellView(state: cellState, label: label)
          }
          .buttonStyle(MatrixCellButtonStyle())
          .animation(AppDesign.gridCellSpring, value: cellState)
          .animation(AppDesign.gridCellSpring, value: label)
        } else {
          GridCellView(state: cellState, label: label)
            .animation(AppDesign.gridCellSpring, value: cellState)
            .animation(AppDesign.gridCellSpring, value: label)
        }
      }
    }
    .animation(AppDesign.gridCellSpring, value: states)
  }
}

struct MatrixCellButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.92 : 1)
      .animation(AppDesign.cellTapSpring, value: configuration.isPressed)
  }
}

struct MatrixStageFrame<Content: View>: View {
  @ViewBuilder let content: () -> Content

  var body: some View {
    content()
      .padding(AppDesign.matrixFrameInset)
      .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: AppDesign.cardCorner, style: .continuous)
          .stroke(AppDesign.stageFrame, lineWidth: 1)
      }
      .overlay {
        RoundedRectangle(cornerRadius: AppDesign.cardCorner - 4, style: .continuous)
          .stroke(AppDesign.gridLine, lineWidth: 1)
          .padding(4)
      }
  }
}
