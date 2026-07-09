//
//  SlideFusionBoardView.swift
//  SpinGrid
//

import SwiftUI

struct SlideFusionBoardView: View {
  let size: Int
  let values: [Int]
  let blocked: Set<Int>
  let onSwipe: (SlideDirection) -> Bool

  @State private var nudge = CGSize.zero
  @State private var nudgeToken = 0

  private var states: [GridCellState] {
    (0..<(size * size)).map { index in
      if blocked.contains(index) { return .blocked }
      guard values.indices.contains(index) else { return .off }
      return values[index] > 0 ? .on : .off
    }
  }

  private var labels: [String?] {
    (0..<(size * size)).map { index in
      if blocked.contains(index) { return nil }
      guard values.indices.contains(index) else { return nil }
      let value = values[index]
      return value > 0 ? "\(value)" : nil
    }
  }

  var body: some View {
    GeometryReader { geo in
      let stride = cellStride(in: geo.size)

      MatrixStageFrame {
        MatrixGridView(
          size: size,
          states: states,
          labels: labels,
          interactive: false
        )
        .padding(AppDesign.spacingM)
      }
      .offset(nudge)
      .contentShape(Rectangle())
      .highPriorityGesture(swipeGesture(stride: stride))
    }
    .aspectRatio(1, contentMode: .fit)
  }

  private func cellStride(in containerSize: CGSize) -> CGFloat {
    let spacing = AppDesign.spacingM
    let padding = AppDesign.spacingM * 2 + AppDesign.matrixFrameInset * 2
    let side = (containerSize.width - padding - spacing * CGFloat(size - 1)) / CGFloat(size)
    return max(side, 24) + spacing
  }

  private func swipeGesture(stride: CGFloat) -> some Gesture {
    DragGesture(minimumDistance: 14, coordinateSpace: .local)
      .onEnded { value in
        guard let direction = resolvedDirection(from: value) else { return }
        if onSwipe(direction) {
          playNudge(direction, stride: stride)
        }
      }
  }

  private func resolvedDirection(from value: DragGesture.Value) -> SlideDirection? {
    let dx = value.translation.width
    let dy = value.translation.height
    let vx = value.predictedEndTranslation.width - value.translation.width
    let vy = value.predictedEndTranslation.height - value.translation.height
    let horizontal = abs(dx) + abs(vx) * 0.25
    let vertical = abs(dy) + abs(vy) * 0.25
    let threshold: CGFloat = 14

    guard max(horizontal, vertical) >= threshold else { return nil }

    if horizontal > vertical {
      return dx < 0 ? .left : .right
    }
    if dy < 0 {
      return .up
    }
    return nil
  }

  private func playNudge(_ direction: SlideDirection, stride: CGFloat) {
    let amount = min(stride * 0.12, 14)
    let offset: CGSize = switch direction {
    case .left: CGSize(width: amount, height: 0)
    case .right: CGSize(width: -amount, height: 0)
    case .up: CGSize(width: 0, height: amount)
    }

    nudgeToken += 1
    let token = nudgeToken

    withAnimation(AppDesign.gridCellSpring) {
      nudge = offset
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      guard token == nudgeToken else { return }
      withAnimation(AppDesign.gridCellSpring) {
        nudge = .zero
      }
    }
  }
}
