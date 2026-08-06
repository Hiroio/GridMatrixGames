//
//  SecondaryView.swift
//  SlayGem
//

import SwiftUI

struct SecondaryView: View {
  @Environment(NavigationManager.self) private var navigation

  var body: some View {
    ZStack {
      if let test = navigation.activeTest {
        TestPlayView(type: test)
          .zIndex(2)
          .transition(AppTransitions.overlay)
      }

      if let game = navigation.activeGame {
        GamePlayView(type: game)
          .zIndex(2)
          .transition(AppTransitions.overlay)
      }
    }
    .animation(AppDesign.overlayAnimation, value: navigation.activityOverlayToken)
    .allowsHitTesting(navigation.activeTest != nil || navigation.activeGame != nil)
  }
}

struct TestPlayView: View {
  let type: TestType

  var body: some View {
    switch type {
    case .gridSearch:
      GridSearchTestView()
    case .missingLink:
      MissingLinkTestView()
    case .gridWeights:
      GridWeightsTestView()
    case .memoryBlitz:
      MemoryBlitzTestView()
    }
  }
}

struct GamePlayView: View {
  let type: GameType

  var body: some View {
    switch type {
    case .flipMatrix:
      FlipMatrixGameView()
    case .blockFlow:
      BlockFlowGameView()
    case .deductionRows:
      DeductionRowsGameView()
    case .slideFusion:
      SlideFusionGameView()
    }
  }
}
