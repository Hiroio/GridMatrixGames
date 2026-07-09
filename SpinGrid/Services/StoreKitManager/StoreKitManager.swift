//
//  StoreKitManager.swift
//  SpinGrid
//

import Foundation
import StoreKit

@MainActor
@Observable
final class StoreKitManager {
  static let shared = StoreKitManager()

  var isPremium = false
  var showingPaywall = false
  var isPurchasing = false
  var isRestoring = false
  var isLoadingProducts = false
  var statusMessage: String?
  var premiumProduct: Product?

  private var transactionListener: Task<Void, Never>?

  var isProductReady: Bool { premiumProduct != nil }
  var premiumPriceText: String {
    premiumProduct?.displayPrice ?? "$4.99"
  }

  private init() {
    transactionListener = Task { await listenForTransactionUpdates() }
    Task { await refreshAccess() }
  }

  func presentPaywall() {
    showingPaywall = true
  }

  func preparePaywall() async {
    await fetchProducts()
  }

  func fetchProducts() async {
    isLoadingProducts = true
    defer { isLoadingProducts = false }

    do {
      let products = try await Product.products(for: [StoreConfiguration.premiumProductID])
      premiumProduct = products.first
      if premiumProduct == nil {
        statusMessage = "Premium is not available right now. Try again in a moment."
      }
    } catch {
      premiumProduct = nil
      statusMessage = "Could not load Premium from the App Store."
    }
  }

  @discardableResult
  func purchasePremium() async -> Bool {
    statusMessage = nil
    if premiumProduct == nil { await fetchProducts() }
    guard let premiumProduct else {
      statusMessage = "Premium is not available right now. Try again in a moment."
      return false
    }

    isPurchasing = true
    defer { isPurchasing = false }

    do {
      let result = try await premiumProduct.purchase()
      switch result {
      case .success(let verification):
        let transaction = try checkVerified(verification)
        await refreshAccess()
        await transaction.finish()
        if isPremium {
          statusMessage = "Premium unlocked. Enjoy unlimited play!"
          SoundManager.playSuccess()
          showingPaywall = false
          return true
        }
        statusMessage = "Purchase completed, but Premium access is still syncing."
        return false
      case .userCancelled:
        return false
      case .pending:
        statusMessage = "Purchase is pending approval."
        return false
      @unknown default:
        return false
      }
    } catch {
      statusMessage = "Purchase failed. Please try again."
      return false
    }
  }

  @discardableResult
  func restorePurchases() async -> Bool {
    statusMessage = nil
    isRestoring = true
    defer { isRestoring = false }

    do {
      try await AppStore.sync()
      await refreshAccess()
      if isPremium {
        statusMessage = "Premium restored."
        SoundManager.playSuccess()
        showingPaywall = false
        return true
      }
      statusMessage = "No previous Premium purchase was found for this Apple ID."
      return false
    } catch {
      statusMessage = "Restore failed. Please try again."
      return false
    }
  }

  func canAccess(game: GameType) -> Bool {
    !game.isPremium || isPremium
  }

  @discardableResult
  func requireAccess(to game: GameType) -> Bool {
    guard canAccess(game: game) else {
      presentPaywall()
      return false
    }
    return true
  }

  @discardableResult
  func requirePremium() -> Bool {
    guard isPremium else {
      presentPaywall()
      return false
    }
    return true
  }

  func refreshAccess() async {
    var hasAccess = false
    for await result in Transaction.currentEntitlements {
      guard let transaction = try? checkVerified(result) else { continue }
      guard transaction.productID == StoreConfiguration.premiumProductID else { continue }
      hasAccess = true
    }
    isPremium = hasAccess
    if isPremium {
      showingPaywall = false
    }
  }

  private func listenForTransactionUpdates() async {
    for await result in Transaction.updates {
      guard let transaction = try? checkVerified(result) else { continue }
      await refreshAccess()
      await transaction.finish()
    }
  }

  private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .verified(let safe):
      return safe
    case .unverified:
      throw StoreError.failedVerification
    }
  }

  private enum StoreError: Error {
    case failedVerification
  }
}

enum PremiumFeature: CaseIterable, Identifiable {
  case unlimitedSessions
  case hardMode
  case slideFusion
  case statsExport

  var id: String { title }

  var title: String {
    switch self {
    case .unlimitedSessions: "Unlimited Studio sessions"
    case .hardMode: "Hard mode on all games"
    case .slideFusion: "Premium game: Slide Fusion"
    case .statsExport: "Stats CSV export + 30-day charts"
    }
  }

  var icon: String {
    switch self {
    case .unlimitedSessions: "infinity"
    case .hardMode: "flame.fill"
    case .slideFusion: "arrow.up.and.down.and.arrow.left.and.right"
    case .statsExport: "chart.bar.doc.horizontal"
    }
  }
}
