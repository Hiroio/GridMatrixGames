//
//  SlideFusionEngine.swift
//  SpinGrid
//

import Foundation

enum SlideDirection: CaseIterable {
  case up, left, right

  static var playable: [SlideDirection] { [.left, .right, .up] }
}

enum SlideFusionEngine {
  static let defaultGoal = 2048

  static func gridSize(for difficulty: GridDifficulty) -> Int {
    switch difficulty {
    case .easy: 4
    case .medium: 5
    case .hard: 6
    }
  }

  static func makeChallenge(difficulty: GridDifficulty) -> SlideFusionChallenge {
    let size = gridSize(for: difficulty)
    return SlideFusionChallenge(
      id: "sf-\(difficulty.rawValue)-\(size)",
      difficulty: difficulty,
      size: size,
      blockedIndices: [],
      goalValue: defaultGoal,
      parMoves: 0
    )
  }

  static func move(
    tiles: inout [Int],
    blocked: Set<Int>,
    size: Int,
    direction: SlideDirection
  ) -> Bool {
    var changed = false
    switch direction {
    case .left:
      for row in 0..<size {
        let indices = (0..<size).map { row * size + $0 }
        changed = process(indices: indices, tiles: &tiles, blocked: blocked) || changed
      }
    case .right:
      for row in 0..<size {
        let indices = (0..<size).map { row * size + $0 }.reversed()
        changed = process(indices: Array(indices), tiles: &tiles, blocked: blocked) || changed
      }
    case .up:
      for col in 0..<size {
        let indices = (0..<size).map { $0 * size + col }
        changed = process(indices: indices, tiles: &tiles, blocked: blocked) || changed
      }
    }
    return changed
  }

  private static func process(
    indices: [Int],
    tiles: inout [Int],
    blocked: Set<Int>
  ) -> Bool {
    var changed = false
    let segments = splitSegments(indices: indices, blocked: blocked)
    for segment in segments {
      if mergeSegment(segment, tiles: &tiles) {
        changed = true
      }
    }
    return changed
  }

  private static func splitSegments(indices: [Int], blocked: Set<Int>) -> [[Int]] {
    var segments: [[Int]] = []
    var current: [Int] = []
    for index in indices {
      if blocked.contains(index) {
        if !current.isEmpty {
          segments.append(current)
          current = []
        }
      } else {
        current.append(index)
      }
    }
    if !current.isEmpty { segments.append(current) }
    return segments
  }

  private static func mergeSegment(
    _ indices: [Int],
    tiles: inout [Int]
  ) -> Bool {
    let values = indices.compactMap { tiles[$0] > 0 ? tiles[$0] : nil }
    var merged: [Int] = []
    var index = 0
    while index < values.count {
      if index + 1 < values.count, values[index] == values[index + 1] {
        merged.append(values[index] * 2)
        index += 2
      } else {
        merged.append(values[index])
        index += 1
      }
    }

    let padding = Array(repeating: 0, count: max(0, indices.count - merged.count))
    // Indices are already ordered in slide direction (L/R/U), so merged tiles
    // belong at the leading edge of that traversal — always prefix, never suffix.
    let layout = merged + padding

    var changed = false
    for (cellIndex, value) in zip(indices, layout) {
      if tiles[cellIndex] != value {
        tiles[cellIndex] = value
        changed = true
      }
    }
    return changed
  }

  static func spawn(into tiles: inout [Int], blocked: Set<Int>) {
    let empties = tiles.indices.filter { tiles[$0] == 0 && !blocked.contains($0) }
    guard let spot = empties.randomElement() else { return }
    tiles[spot] = Int.random(in: 0..<10) < 9 ? 2 : 4
  }

  static func hasMoves(tiles: [Int], blocked: Set<Int>, size: Int) -> Bool {
    SlideDirection.playable.contains { direction in
      var copy = tiles
      return move(tiles: &copy, blocked: blocked, size: size, direction: direction)
    }
  }

  static func highestValue(in tiles: [Int], blocked: Set<Int>) -> Int {
    tiles.enumerated()
      .filter { !blocked.contains($0.offset) }
      .map(\.element)
      .max() ?? 0
  }

  static func isWin(tiles: [Int], goalValue: Int) -> Bool {
    tiles.contains(where: { $0 >= goalValue })
  }
}
