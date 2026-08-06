//
//  SlideFusionSwipeHints.swift
//  SlayGem
//

import SwiftUI

enum SlideFusionSwipeHintDirection: CaseIterable {
  case left
  case right
  case up

  var handIcon: String {
    switch self {
    case .left: "hand.point.up.left.fill"
    case .right: "hand.point.up.right.fill"
    case .up: "hand.point.up.fill"
    }
  }

  var arrowIcon: String {
    switch self {
    case .left: "arrow.left"
    case .right: "arrow.right"
    case .up: "arrow.up"
    }
  }

  var label: String {
    switch self {
    case .left: "Left"
    case .right: "Right"
    case .up: "Up"
    }
  }
}

struct SlideFusionSwipeHints: View {
  enum Placement {
    case idle
    case board
  }

  let placement: Placement

  var body: some View {
    Group {
      switch placement {
      case .idle:
        idleLayout
      case .board:
        boardLayout
      }
    }
    .allowsHitTesting(false)
  }

  private var idleLayout: some View {
    ZStack {
      MatrixThumbnailView(style: .slideFusion, size: 88)

      hintBadge(.up)
        .offset(y: -58)

      hintBadge(.left)
        .offset(x: -58)

      hintBadge(.right)
        .offset(x: 58)
    }
    .frame(width: 148, height: 148)
  }

  private var boardLayout: some View {
    ZStack {
      VStack {
        hintBadge(.up)
          .padding(.top, 4)
        Spacer(minLength: 0)
      }

      HStack {
        hintBadge(.left)
          .padding(.leading, 2)
        Spacer(minLength: 0)
        hintBadge(.right)
          .padding(.trailing, 2)
      }
    }
    .padding(AppDesign.spacingS)
  }

  private func hintBadge(_ direction: SlideFusionSwipeHintDirection) -> some View {
    SlideFusionSwipeHintBadge(direction: direction, placement: placement)
  }
}

private struct SlideFusionSwipeHintBadge: View {
  let direction: SlideFusionSwipeHintDirection
  let placement: SlideFusionSwipeHints.Placement

  @State private var animate = false

  private var handFont: Font {
    placement == .idle ? .title3.weight(.semibold) : .title2.weight(.semibold)
  }

  var body: some View {
    VStack(spacing: 4) {
      Image(systemName: direction.handIcon)
        .font(handFont)
        .foregroundStyle(AppDesign.accent)
        .shadow(color: AppDesign.background.opacity(0.45), radius: 4, y: 2)
        .offset(animatedOffset)
        .animation(
          .easeInOut(duration: 0.85).repeatForever(autoreverses: true).delay(directionDelay),
          value: animate
        )

      Image(systemName: direction.arrowIcon)
        .font(.caption2.weight(.bold))
        .foregroundStyle(AppDesign.tertiaryText)

      Text(direction.label)
        .font(.caption2.weight(.bold))
        .foregroundStyle(AppDesign.tertiaryText)
    }
    .padding(.horizontal, placement == .board ? 10 : 6)
    .padding(.vertical, placement == .board ? 8 : 4)
    .background {
      RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous)
        .fill(AppDesign.surface.opacity(0.92))
        .overlay {
          RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous)
            .stroke(AppDesign.gridLine, lineWidth: 1)
        }
    }
    .onAppear { animate = true }
  }

  private var directionDelay: Double {
    switch direction {
    case .left: 0
    case .right: 0.22
    case .up: 0.44
    }
  }

  private var animatedOffset: CGSize {
    let amount: CGFloat = animate ? 0 : 9
    return switch direction {
    case .left: CGSize(width: -amount, height: 0)
    case .right: CGSize(width: amount, height: 0)
    case .up: CGSize(width: 0, height: -amount)
    }
  }
}
