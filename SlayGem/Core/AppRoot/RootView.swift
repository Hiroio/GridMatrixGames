//
//  RootView.swift
//  SlayGem
//

import SwiftUI

private enum RootPhase {
  case launch
  case onboarding
  case main
}

struct RootView: View {
  @Environment(StoreKitManager.self) private var store
  @Environment(SessionManager.self) private var session
  @Environment(AppStorageManager.self) private var appStorage
  @Environment(\.scenePhase) private var scenePhase

  @State private var phase: RootPhase = .launch

  var body: some View {
    ZStack {
      switch phase {
      case .launch:
        LaunchView(onFinish: handleLaunchFinished)
          .transition(AppTransitions.phase)
      case .onboarding:
        OnBoardingView(onFinish: { phase = .main })
          .transition(AppTransitions.phase)
      case .main:
        mainShell
          .transition(AppTransitions.phase)
      }
    }
    .animation(AppDesign.phaseAnimation, value: phaseIdentifier)
  }

  private var phaseIdentifier: String {
    switch phase {
    case .launch: "launch"
    case .onboarding: "onboarding"
    case .main: "main"
    }
  }

  private var mainShell: some View {
    ZStack {
      AppBackgroundView()
      MainNavigationView()
      SecondaryView()
    }
    .sheet(isPresented: Binding(
      get: { store.showingPaywall },
      set: { store.showingPaywall = $0 }
    )) {
      PaywallView()
        .environment(store)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppDesign.background)
    }
    .task { await store.refreshAccess() }
    .onChange(of: scenePhase) { _, newPhase in
      guard newPhase == .active else { return }
      session.reloadUsage()
      Task { await store.refreshAccess() }
    }
  }

  private func handleLaunchFinished() {
    phase = appStorage.hasCompletedOnboarding ? .main : .onboarding
  }
}
