//
//  GridChallengeEngine.swift
//  SpinGrid
//

import Foundation

@MainActor
enum GridChallengeEngine {
  static func resolvedDifficulty(_ difficulty: GridDifficulty, premium: Bool) -> GridDifficulty {
    if difficulty == .hard && !premium { return .medium }
    return difficulty
  }

  static func flipMatrixChallenge(premium: Bool, difficulty: GridDifficulty) -> FlipMatrixChallenge? {
    let resolved = resolvedDifficulty(difficulty, premium: premium)
    let size = FlipMatrixEngine.gridSize(for: resolved)
    let taps = FlipMatrixEngine.tapBudget(for: resolved)
    return FlipMatrixEngine.generate(size: size, tapCount: taps, difficulty: resolved)
  }

  static func missingLinkChallenge() -> MissingLinkChallenge? {
    GridDataManager.shared.missingLinkChallenges.randomElement()
  }

  static func gridWeightsChallenge() -> GridWeightsChallenge? {
    GridDataManager.shared.gridWeightsChallenges.randomElement()
  }

  static func memoryBlitzChallenge() -> MemoryBlitzChallenge? {
    GridDataManager.shared.memoryBlitzChallenges.randomElement()
  }

  static func blockFlowChallenge(premium: Bool, difficulty: GridDifficulty) -> BlockFlowChallenge? {
    let resolved = resolvedDifficulty(difficulty, premium: premium)
    let size = BlockFlowEngine.gridSize(for: resolved)
    let pairs = BlockFlowEngine.pairCount(for: resolved)
    return BlockFlowEngine.generate(size: size, pairCount: pairs, difficulty: resolved)
  }

  static func deductionRowsChallenge(premium: Bool, difficulty: GridDifficulty) -> DeductionRowsChallenge? {
    let resolved = resolvedDifficulty(difficulty, premium: premium)
    let pool = GridDataManager.shared.deductionRowsChallenges.filter { $0.difficulty == resolved }
    if let challenge = pool.randomElement() { return challenge }
    if resolved != .easy { return deductionRowsChallenge(premium: premium, difficulty: .easy) }
    return nil
  }

  static func slideFusionChallenge(premium: Bool, difficulty: GridDifficulty) -> SlideFusionChallenge? {
    guard premium else { return nil }
    let resolved = resolvedDifficulty(difficulty, premium: true)
    return SlideFusionEngine.makeChallenge(difficulty: resolved)
  }
}

enum GridIndexMath {
  static func rowCol(flatIndex: Int, columns: Int) -> (row: Int, col: Int) {
    (flatIndex / columns, flatIndex % columns)
  }

  static func flatIndex(row: Int, col: Int, columns: Int) -> Int {
    row * columns + col
  }

  static func neighbors(of flatIndex: Int, size: Int) -> [Int] {
    let (row, col) = rowCol(flatIndex: flatIndex, columns: size)
    var result: [Int] = []
    if row > 0 { result.append(Self.flatIndex(row: row - 1, col: col, columns: size)) }
    if row < size - 1 { result.append(Self.flatIndex(row: row + 1, col: col, columns: size)) }
    if col > 0 { result.append(Self.flatIndex(row: row, col: col - 1, columns: size)) }
    if col < size - 1 { result.append(Self.flatIndex(row: row, col: col + 1, columns: size)) }
    return result
  }

  static func toggleLights(at flatIndex: Int, size: Int, states: inout [Bool]) {
    let affected = [flatIndex] + neighbors(of: flatIndex, size: size)
    for i in affected where i >= 0 && i < states.count {
      states[i].toggle()
    }
  }
}
