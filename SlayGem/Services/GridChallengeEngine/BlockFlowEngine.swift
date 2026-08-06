//
//  BlockFlowEngine.swift
//  SlayGem
//

import Foundation

enum BlockFlowEngine {
  static func generate(size: Int, pairCount: Int, difficulty: GridDifficulty) -> BlockFlowChallenge {
    let path = hamiltonianSnake(size: size)
    let cellsPerPair = (size * size) / pairCount
    let letters = ["A", "B", "C", "D", "E"]
    var pairs: [BlockFlowPair] = []

    for pairIndex in 0..<pairCount {
      let startOffset = pairIndex * cellsPerPair
      let endOffset = startOffset + cellsPerPair - 1
      let segment = Array(path[startOffset...endOffset])
      pairs.append(
        BlockFlowPair(
          letter: letters[pairIndex],
          indices: [segment.first!, segment.last!]
        )
      )
    }

    return BlockFlowChallenge(
      id: "bf-\(difficulty.rawValue)-\(size)-\(Int.random(in: 1000...9999))",
      difficulty: difficulty,
      size: size,
      pairs: pairs
    )
  }

  static func pairCount(for difficulty: GridDifficulty) -> Int {
    switch difficulty {
    case .easy: 2
    case .medium: 3
    case .hard: 4
    }
  }

  static func gridSize(for difficulty: GridDifficulty) -> Int {
    switch difficulty {
    case .easy: 4
    case .medium: 5
    case .hard: 5
    }
  }

  static func solutionPath(for challenge: BlockFlowChallenge) -> [String: [Int]] {
    let path = hamiltonianSnake(size: challenge.size)
    let cellsPerPair = (challenge.size * challenge.size) / challenge.pairs.count
    var result: [String: [Int]] = [:]

    for (index, pair) in challenge.pairs.enumerated() {
      let startOffset = index * cellsPerPair
      let endOffset = startOffset + cellsPerPair - 1
      result[pair.letter] = Array(path[startOffset...endOffset])
    }
    return result
  }

  private static func hamiltonianSnake(size: Int) -> [Int] {
    var path: [Int] = []
    for row in 0..<size {
      if row.isMultiple(of: 2) {
        for col in 0..<size {
          path.append(row * size + col)
        }
      } else {
        for col in stride(from: size - 1, through: 0, by: -1) {
          path.append(row * size + col)
        }
      }
    }
    return path
  }
}
