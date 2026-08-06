//
//  OnboardingAnimatedGrid.swift
//  SlayGem
//

import SwiftUI

struct OnboardingAnimatedGrid: View {
  private let gridSize = 4
  @State private var litIndices: Set<Int> = []
  @State private var animationTask: Task<Void, Never>?

  private var columns: [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: AppDesign.spacingS), count: gridSize)
  }

  var body: some View {
    let cell = CGFloat(18)
    LazyVGrid(columns: columns, spacing: AppDesign.spacingS) {
      ForEach(0..<(gridSize * gridSize), id: \.self) { index in
        RoundedRectangle(cornerRadius: AppDesign.cellCorner, style: .continuous)
          .fill(litIndices.contains(index) ? AppDesign.accent : AppDesign.cellOff)
          .overlay {
            RoundedRectangle(cornerRadius: AppDesign.cellCorner, style: .continuous)
              .stroke(AppDesign.gridLine, lineWidth: 1)
          }
          .frame(width: cell, height: cell)
          .scaleEffect(litIndices.contains(index) ? 1 : 0.9)
          .animation(AppDesign.gridCellSpring, value: litIndices.contains(index))
      }
    }
    .frame(width: cell * 4 + AppDesign.spacingS * 3, height: cell * 4 + AppDesign.spacingS * 3)
    .animation(AppDesign.gridCellSpring, value: litIndices)
    .onAppear { startAnimation() }
    .onDisappear { animationTask?.cancel() }
  }

  private func startAnimation() {
    animationTask?.cancel()
    litIndices = []

    let sequence = Array(0..<(gridSize * gridSize)).shuffled()
    animationTask = Task { @MainActor in
      while !Task.isCancelled {
        for index in sequence {
          guard !Task.isCancelled else { return }
          litIndices.insert(index)
          try? await Task.sleep(for: .milliseconds(90))
        }
        try? await Task.sleep(for: .milliseconds(500))
        litIndices = []
        try? await Task.sleep(for: .milliseconds(350))
      }
    }
  }
}
