//
//  FlipMatrixEngine.swift
//  SpinGrid
//

import Foundation

enum FlipMatrixEngine {
  static func generate(size: Int, tapCount: Int, difficulty: GridDifficulty) -> FlipMatrixChallenge {
    var states = Array(repeating: false, count: size * size)
    var taps = 0
    var guardLoop = 0

    while guardLoop < 32 {
      guardLoop += 1
      states = Array(repeating: false, count: size * size)
      taps = max(2, tapCount)
      for _ in 0..<taps {
        let index = Int.random(in: 0..<states.count)
        GridIndexMath.toggleLights(at: index, size: size, states: &states)
      }
      if states.contains(true) { break }
    }

    let initialOn = states.enumerated().compactMap { $0.element ? $0.offset : nil }
    return FlipMatrixChallenge(
      id: "fm-\(difficulty.rawValue)-\(size)-\(Int.random(in: 1000...9999))",
      difficulty: difficulty,
      size: size,
      initialOn: initialOn,
      parMoves: taps
    )
  }

  static func maxMoves(for difficulty: GridDifficulty) -> Int? {
    switch difficulty {
    case .easy: nil
    case .medium: nil
    case .hard: 28
    }
  }

  static func tapBudget(for difficulty: GridDifficulty) -> Int {
    switch difficulty {
    case .easy: Int.random(in: 3...5)
    case .medium: Int.random(in: 5...9)
    case .hard: Int.random(in: 8...14)
    }
  }

  static func gridSize(for difficulty: GridDifficulty) -> Int {
    switch difficulty {
    case .easy: 3
    case .medium: 4
    case .hard: 5
    }
  }
}
