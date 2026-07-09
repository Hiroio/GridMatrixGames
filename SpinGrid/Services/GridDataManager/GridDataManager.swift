//
//  GridDataManager.swift
//  SpinGrid
//

import Foundation

struct FlipMatrixChallenge: Codable, Identifiable {
  let id: String
  let difficulty: GridDifficulty
  let size: Int
  let initialOn: [Int]
  let parMoves: Int
}

struct BlockFlowPair: Codable {
  let letter: String
  let indices: [Int]
}

struct BlockFlowChallenge: Codable, Identifiable {
  let id: String
  let difficulty: GridDifficulty
  let size: Int
  let pairs: [BlockFlowPair]
}

struct DeductionRowsChallenge: Codable, Identifiable {
  let id: String
  let difficulty: GridDifficulty
  let size: Int
  let rowClues: [[Int]]
  let colClues: [[Int]]
  let solution: [Int]
}

struct SlideFusionChallenge: Codable, Identifiable {
  let id: String
  let difficulty: GridDifficulty
  let size: Int
  let blockedIndices: [Int]
  let goalValue: Int
  let parMoves: Int
}

private struct GamesPayload: Codable {
  let flipMatrix: [FlipMatrixChallenge]
  let blockFlow: [BlockFlowChallenge]
  let deductionRows: [DeductionRowsChallenge]
  let slideFusion: [SlideFusionChallenge]
}

@MainActor
final class GridDataManager {
  static let shared = GridDataManager()

  private(set) var flipMatrixChallenges: [FlipMatrixChallenge] = []
  private(set) var blockFlowChallenges: [BlockFlowChallenge] = []
  private(set) var deductionRowsChallenges: [DeductionRowsChallenge] = []
  private(set) var slideFusionChallenges: [SlideFusionChallenge] = []
  private(set) var missingLinkChallenges: [MissingLinkChallenge] = []
  private(set) var gridWeightsChallenges: [GridWeightsChallenge] = []
  private(set) var memoryBlitzChallenges: [MemoryBlitzChallenge] = []
  private(set) var isLoaded = false

  private init() {}

  func preload() {
    guard !isLoaded else { return }
    loadGames()
    loadTests()
    isLoaded = true
  }

  func ensureLoaded() async {
    preload()
  }

  private func loadGames() {
    if let games = decode("games_challenges", as: GamesPayload.self) {
      flipMatrixChallenges = games.flipMatrix
      blockFlowChallenges = games.blockFlow
      deductionRowsChallenges = games.deductionRows
      slideFusionChallenges = games.slideFusion
    } else {
      flipMatrixChallenges = fallbackFlipMatrix()
      blockFlowChallenges = fallbackBlockFlow()
      deductionRowsChallenges = fallbackDeductionRows()
      slideFusionChallenges = fallbackSlideFusion()
    }
  }

  private func loadTests() {
    if let tests = decode("tests_challenges", as: TestsPayload.self) {
      missingLinkChallenges = tests.missingLink
      gridWeightsChallenges = tests.gridWeights
      memoryBlitzChallenges = tests.memoryBlitz
    } else {
      missingLinkChallenges = fallbackMissingLink()
      gridWeightsChallenges = fallbackGridWeights()
      memoryBlitzChallenges = fallbackMemoryBlitz()
    }
  }

  private func decode<T: Decodable>(_ name: String, as type: T.Type) -> T? {
    guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
          let data = try? Data(contentsOf: url) else { return nil }
    return try? JSONDecoder().decode(T.self, from: data)
  }

  private func fallbackFlipMatrix() -> [FlipMatrixChallenge] {
    [FlipMatrixChallenge(id: "fm-e1", difficulty: .easy, size: 3, initialOn: [0, 1, 4], parMoves: 4)]
  }

  private func fallbackBlockFlow() -> [BlockFlowChallenge] {
    [BlockFlowChallenge(id: "bf-e1", difficulty: .easy, size: 4, pairs: [
      BlockFlowPair(letter: "A", indices: [0, 15]),
      BlockFlowPair(letter: "B", indices: [3, 12]),
    ])]
  }

  private func fallbackDeductionRows() -> [DeductionRowsChallenge] {
    [DeductionRowsChallenge(id: "dr-e1", difficulty: .easy, size: 3, rowClues: [[1], [1], [3]], colClues: [[1], [1], [3]], solution: [0, 0, 1, 0, 0, 1, 1, 1, 1])]
  }

  private func fallbackSlideFusion() -> [SlideFusionChallenge] {
    [SlideFusionChallenge(id: "sf-e1", difficulty: .easy, size: 4, blockedIndices: [], goalValue: 6, parMoves: 42)]
  }

  private func fallbackMissingLink() -> [MissingLinkChallenge] {
    [MissingLinkChallenge(id: "ml-f1", gridSize: 5, pathIndices: [5, 6, 7, 12, 17, 16, 15], gapIndex: 12)]
  }

  private func fallbackGridWeights() -> [GridWeightsChallenge] {
    [GridWeightsChallenge(id: "gw-f1", leftFilled: [0, 1, 4], rightFilled: [0, 3, 6, 7])]
  }

  private func fallbackMemoryBlitz() -> [MemoryBlitzChallenge] {
    [MemoryBlitzChallenge(id: "mb-f1", patternIndices: [1, 4, 6, 9])]
  }
}

struct MissingLinkChallenge: Codable, Identifiable {
  let id: String
  let gridSize: Int
  let pathIndices: [Int]
  let gapIndex: Int
}

struct GridWeightsChallenge: Codable, Identifiable {
  let id: String
  let leftFilled: [Int]
  let rightFilled: [Int]
}

struct MemoryBlitzChallenge: Codable, Identifiable {
  let id: String
  let patternIndices: [Int]
}

private struct TestsPayload: Codable {
  let missingLink: [MissingLinkChallenge]
  let gridWeights: [GridWeightsChallenge]
  let memoryBlitz: [MemoryBlitzChallenge]
}
