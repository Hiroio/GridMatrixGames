//
//  GridCellView.swift
//  SpinGrid
//

import SwiftUI

enum GridCellState: Equatable {
  case off
  case on
  case target
  case done
  case path
  case gap
  case mark
  case blocked
  case selected
  case wrongPick
}

struct GridCellView: View {
  let state: GridCellState
  var label: String?
  var pairShadeIndex = 0

  private var visualKey: String {
    "\(state)-\(label ?? "")-\(pairShadeIndex)"
  }

  private var isLit: Bool {
    switch state {
    case .on, .path, .target, .selected, .done: true
    default: label != nil && !(label?.isEmpty ?? true)
    }
  }

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: AppDesign.cellCorner, style: .continuous)
        .fill(fillColor)
      RoundedRectangle(cornerRadius: AppDesign.cellCorner, style: .continuous)
        .stroke(borderColor, style: borderStyle)

      if let label, !label.isEmpty {
        Text(label)
          .font(.system(.title3, design: .rounded).weight(.semibold).monospacedDigit())
          .foregroundStyle(labelColor)
          .minimumScaleFactor(0.6)
          .contentTransition(.numericText())
      }

      if state == .mark {
        Image(systemName: "xmark")
          .font(.caption.weight(.bold))
          .foregroundStyle(AppDesign.tertiaryText)
      }
    }
    .scaleEffect(isLit ? 1 : 0.94)
    .opacity(state == .off && (label?.isEmpty ?? true) ? 0.88 : 1)
    .animation(AppDesign.gridCellSpring, value: visualKey)
    .aspectRatio(1, contentMode: .fit)
    .contentShape(Rectangle())
  }

  private var fillColor: Color {
    switch state {
    case .off, .gap: AppDesign.cellOff
    case .on: AppDesign.cellOn
    case .target: AppDesign.accentMuted
    case .done: AppDesign.cellOn.opacity(0.35)
    case .path: AppDesign.pairShade(pairShadeIndex).opacity(0.65)
    case .mark: AppDesign.cellOff
    case .blocked: AppDesign.cellBlocked
    case .selected: AppDesign.accentMuted
    case .wrongPick: AppDesign.warning.opacity(0.35)
    }
  }

  private var borderColor: Color {
    switch state {
    case .target, .selected: AppDesign.accent
    case .gap: AppDesign.accent
    case .wrongPick: AppDesign.warning
    case .blocked: AppDesign.gridLineStrong
    default: AppDesign.gridLine
    }
  }

  private var borderWidth: CGFloat {
    switch state {
    case .target, .selected, .gap: 2
    default: 1
    }
  }

  private var borderStyle: StrokeStyle {
    state == .gap ? StrokeStyle(lineWidth: 2, dash: [4, 3]) : StrokeStyle(lineWidth: borderWidth)
  }

  private var labelColor: Color {
    switch state {
    case .on, .path: AppDesign.ctaTextOnAccent
    case .done: AppDesign.tertiaryText
    default: AppDesign.primaryText
    }
  }
}
