//
//  AnswerFlashOverlay.swift
//  SlayGem
//

import SwiftUI

struct AnswerFlashController: View {
  let kind: AnswerFlashKind?

  var body: some View {
    ZStack {
      if let kind {
        Color(kind == .correct ? AppDesign.success : AppDesign.warning)
          .opacity(kind == .correct ? 0.18 : 0.22)
          .ignoresSafeArea()
          .allowsHitTesting(false)
          .transition(.opacity)
          .id(kind)
      }
    }
    .animation(AppDesign.flashInAnimation, value: kind)
  }
}
