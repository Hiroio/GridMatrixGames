//
//  LaunchViewModel.swift
//  SpinGrid
//

import Foundation

@MainActor
@Observable
final class LaunchViewModel {
  var progress: CGFloat = 0
  var statusText = "Starting up…"
  var isReady = false

  private let minimumDisplaySeconds: TimeInterval = 1.05

  func bootstrap(store: StoreKitManager) async {
    let startedAt = Date()
    isReady = false
    progress = 0
    statusText = "Loading matrix puzzles…"

    GridDataManager.shared.preload()
    progress = 0.45

    statusText = "Preparing Studio…"
    try? await Task.sleep(for: .milliseconds(120))
    progress = 0.7

    statusText = "Checking Premium access…"
    await store.refreshAccess()
    await store.fetchProducts()
    progress = 1

    statusText = "Ready"

    let elapsed = Date().timeIntervalSince(startedAt)
    if elapsed < minimumDisplaySeconds {
      try? await Task.sleep(for: .seconds(minimumDisplaySeconds - elapsed))
    }

    isReady = true
  }
}
