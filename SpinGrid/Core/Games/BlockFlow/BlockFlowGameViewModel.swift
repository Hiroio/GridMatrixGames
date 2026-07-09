//
//  BlockFlowGameViewModel.swift
//  SpinGrid
//

import Foundation

enum BlockFlowPhase: Equatable {
  case idle
  case playing
  case summary
}

@MainActor
@Observable
final class BlockFlowGameViewModel {
  var session = GridRoundSession()
  var timer = SessionTimer()
  var phase: BlockFlowPhase = .idle
  var challenge: BlockFlowChallenge?
  var paths: [String: [Int]] = [:]
  var activePath: [Int] = []
  var activeLetter: String?
  var selectedDifficulty: GridDifficulty = .easy

  var gridSize: Int { challenge?.size ?? 4 }
  var isRunning: Bool { phase == .playing }
  var answerFlash: AnswerFlashKind? { session.answerFlash }
  var finalScore: Int { session.sessionScore }

  var statusText: String {
    switch phase {
    case .idle: "Connect matching letters without crossing"
    case .playing: "Drag through cells to link pairs"
    case .summary: "Grid complete"
    }
  }

  func endpointMap() -> [Int: String] {
    guard let challenge else { return [:] }
    var map: [Int: String] = [:]
    for pair in challenge.pairs {
      for index in pair.indices { map[index] = pair.letter }
    }
    return map
  }

  func pairIndex(for letter: String) -> Int {
    challenge?.pairs.firstIndex(where: { $0.letter == letter }) ?? 0
  }

  func cellStates() -> [GridCellState] {
    let count = gridSize * gridSize
    var states = Array(repeating: GridCellState.off, count: count)
    let endpoints = endpointMap()

    for (letter, indices) in paths {
      let shade = pairIndex(for: letter)
      for index in indices where index < count {
        states[index] = .path
      }
      _ = shade
    }

    for index in activePath where index < count {
      states[index] = .path
    }

    for (index, _) in endpoints {
      if !cellInAnyPath(index) {
        states[index] = .on
      }
    }

    return states
  }

  func cellLabels() -> [String?] {
    let endpoints = endpointMap()
    return (0..<(gridSize * gridSize)).map { endpoints[$0] }
  }

  func pairShade(at index: Int) -> Int {
    if let letter = letterForPathIndex(index) {
      return pairIndex(for: letter)
    }
    return 0
  }

  func start(difficulty: GridDifficulty) {
    guard SessionManager.shared.tryStartGame() else { return }
    SessionManager.shared.consumeGameSession()
    selectedDifficulty = GridChallengeEngine.resolvedDifficulty(
      difficulty,
      premium: StoreKitManager.shared.isPremium
    )
    guard let challenge = GridChallengeEngine.blockFlowChallenge(
      premium: StoreKitManager.shared.isPremium,
      difficulty: selectedDifficulty
    ) else { return }

    self.challenge = challenge
    paths = [:]
    activePath = []
    activeLetter = nil
    session.begin(roundCount: 1)
    phase = .playing
    timer.start()
  }

  func reset() {
    timer.reset()
    session.reset()
    phase = .idle
    challenge = nil
    paths = [:]
    activePath = []
    activeLetter = nil
  }

  func beginDrag(at index: Int) {
    guard phase == .playing, let challenge else { return }
    let endpoints = endpointMap()

    if let letter = activeLetter, !activePath.isEmpty {
      guard let last = activePath.last,
            GridIndexMath.neighbors(of: last, size: challenge.size).contains(index) else { return }

      if activePath.count > 1, activePath[activePath.count - 2] == index {
        activePath.removeLast()
        return
      }

      guard !activePath.contains(index), canUse(index, letter: letter) else { return }
      activePath.append(index)
      return
    }

    if let letter = endpoints[index] {
      activeLetter = letter
      paths[letter] = nil
      activePath = [index]
    }
  }

  func endDrag() {
    guard phase == .playing, let challenge, let letter = activeLetter else { return }
    let endpoints = Set(challenge.pairs.first(where: { $0.letter == letter })?.indices ?? [])
    guard activePath.count >= 2,
          let first = activePath.first,
          let last = activePath.last,
          endpoints.contains(first),
          endpoints.contains(last),
          first != last else {
      activePath = []
      activeLetter = nil
      return
    }

    paths[letter] = activePath
    activePath = []
    activeLetter = nil
    SoundManager.playTap()
    HapticManager.light()

    if isSolved() { finish() }
  }

  func undoLast() {
    guard let lastLetter = paths.keys.sorted().last else { return }
    paths.removeValue(forKey: lastLetter)
    activePath = []
    activeLetter = nil
  }

  private func canUse(_ index: Int, letter: String) -> Bool {
    if cellInCommittedPath(index) { return false }
    if let other = endpointMap()[index], other != letter { return false }
    return true
  }

  private func cellInCommittedPath(_ index: Int) -> Bool {
    paths.values.contains(where: { $0.contains(index) })
  }

  private func cellInAnyPath(_ index: Int) -> Bool {
    cellInCommittedPath(index) || activePath.contains(index)
  }

  private func letterForPathIndex(_ index: Int) -> String? {
    for (letter, indices) in paths where indices.contains(index) { return letter }
    if activePath.contains(index) { return activeLetter }
    return nil
  }

  private func isSolved() -> Bool {
    guard let challenge else { return false }
    let total = challenge.size * challenge.size
    var covered = Set<Int>()
    for path in paths.values { covered.formUnion(path) }
    return paths.count == challenge.pairs.count && covered.count == total
  }

  private func finish() {
    timer.stop()
    let score = GridScoreEngine.blockFlowScore(elapsedMs: timer.elapsedMs)
    session.sessionScore = score
    session.primaryMetric = Double(timer.elapsedMs)
    phase = .summary
    session.phase = .summary
    SoundManager.playSuccess()
    HapticManager.success()
    SessionFinisher.finish(
      activityType: GameType.blockFlow.rawValue,
      score: score,
      primaryMetric: Double(timer.elapsedMs)
    )
  }
}
