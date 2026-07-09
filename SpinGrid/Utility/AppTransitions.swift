//
//  AppTransitions.swift
//  SpinGrid
//

import SwiftUI

enum AppTransitions {
  static var overlay: AnyTransition {
    .asymmetric(
      insertion: .opacity
        .combined(with: .scale(scale: 0.97))
        .combined(with: .offset(y: 18)),
      removal: .opacity
        .combined(with: .scale(scale: 1.01))
        .combined(with: .offset(y: -10))
    )
  }

  static var tabContent: AnyTransition {
    .asymmetric(
      insertion: .opacity.combined(with: .offset(y: 10)),
      removal: .opacity.combined(with: .offset(y: -8))
    )
  }

  static var phase: AnyTransition {
    .opacity.combined(with: .scale(scale: 0.985))
  }

  static var segmentContent: AnyTransition {
    .opacity.combined(with: .offset(y: 8))
  }

  static var sessionContent: AnyTransition {
    .opacity.combined(with: .scale(scale: 0.98))
  }
}

extension View {
  func gridCellAnimation<Value: Equatable>(value: Value) -> some View {
    animation(AppDesign.gridCellSpring, value: value)
  }

  func appPhaseAnimation<Value: Equatable>(value: Value) -> some View {
    animation(AppDesign.phaseAnimation, value: value)
  }
}
