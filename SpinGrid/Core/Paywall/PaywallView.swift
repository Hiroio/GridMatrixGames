//
//  PaywallView.swift
//  SpinGrid
//

import SwiftUI

struct PaywallView: View {
  @Environment(StoreKitManager.self) private var store
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) private var openURL

  var body: some View {
    ZStack {
      AppBackgroundView(showsAmbientGrid: false)

      ScrollView {
        VStack(spacing: AppDesign.spacingL) {
          header

          featuresCard

          if let message = store.statusMessage {
            Text(message)
              .font(.caption)
              .foregroundStyle(AppDesign.secondaryText)
              .multilineTextAlignment(.center)
              .padding(.horizontal, AppDesign.spacingM)
          }

          if store.isPremium {
            premiumActiveSection
          } else {
            purchaseSection
          }

          legalFooter
        }
        .padding(.horizontal, AppDesign.screenPadding)
        .padding(.top, AppDesign.spacingM)
        .padding(.bottom, AppDesign.spacingXL)
      }
    }
    .task { await store.preparePaywall() }
  }

  private var header: some View {
    VStack(spacing: AppDesign.spacingM) {
      ZStack {
        Circle()
          .fill(AppDesign.accentMuted)
          .frame(width: 88, height: 88)
        MatrixThumbnailView(style: .slideFusion, size: 64)
      }

      VStack(spacing: 6) {
        Text("SpinGrid Premium")
          .font(.title2.weight(.bold))
          .foregroundStyle(AppDesign.primaryText)

        Text("One-time unlock · no subscription")
          .font(.subheadline.weight(.medium))
          .foregroundStyle(AppDesign.secondaryText)
      }
    }
    .frame(maxWidth: .infinity)
  }

  private var featuresCard: some View {
    VStack(alignment: .leading, spacing: AppDesign.spacingM) {
      ForEach(PremiumFeature.allCases) { feature in
        HStack(alignment: .top, spacing: 12) {
          SFSymbolBadge(systemName: feature.icon, size: 34, iconSize: 14)
          VStack(alignment: .leading, spacing: 2) {
            Text(feature.title)
              .font(.subheadline.weight(.semibold))
              .foregroundStyle(AppDesign.primaryText)
          }
          Spacer(minLength: 0)
          Image(systemName: "checkmark")
            .font(.caption.weight(.bold))
            .foregroundStyle(AppDesign.accent)
        }
      }
    }
    .gridCard()
  }

  private var premiumActiveSection: some View {
    VStack(spacing: AppDesign.spacingM) {
      Label("Premium active", systemImage: "checkmark.seal.fill")
        .font(.headline.weight(.bold))
        .foregroundStyle(AppDesign.accent)

      Button("Continue") {
        store.showingPaywall = false
        dismiss()
      }
      .gridAccentButton()
    }
  }

  private var purchaseSection: some View {
    VStack(spacing: AppDesign.spacingM) {
      Button {
        Task { await store.purchasePremium() }
      } label: {
        Group {
          if store.isPurchasing {
            ProgressView()
              .tint(AppDesign.ctaTextOnAccent)
          } else if store.isLoadingProducts {
            ProgressView()
              .tint(AppDesign.ctaTextOnAccent)
          } else {
            VStack(spacing: 2) {
              Label("Unlock Premium", systemImage: "crown.fill")
                .font(.headline.weight(.bold))
              Text(store.premiumPriceText)
                .font(.caption.weight(.semibold))
                .opacity(0.85)
            }
          }
        }
        .frame(maxWidth: .infinity)
      }
      .gridAccentButton()
      .disabled(store.isPurchasing || store.isLoadingProducts)

      Button {
        Task { await store.restorePurchases() }
      } label: {
        Group {
          if store.isRestoring {
            ProgressView()
          } else {
            Label("Restore Purchases", systemImage: "arrow.clockwise")
          }
        }
        .frame(maxWidth: .infinity)
      }
      .font(.subheadline.weight(.semibold))
      .foregroundStyle(AppDesign.primaryText)
      .padding(.vertical, 14)
      .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.buttonCorner, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: AppDesign.buttonCorner, style: .continuous)
          .stroke(AppDesign.gridLine, lineWidth: 1)
      }
      .disabled(store.isRestoring || store.isPurchasing)

      Button("Continue Free") {
        store.showingPaywall = false
        dismiss()
      }
      .font(.subheadline.weight(.medium))
      .foregroundStyle(AppDesign.tertiaryText)
    }
  }

  private var legalFooter: some View {
    VStack(spacing: 6) {
      Text("Payment is charged to your Apple ID. Premium is a one-time purchase tied to your account.")
        .font(.caption2)
        .foregroundStyle(AppDesign.tertiaryText)
        .multilineTextAlignment(.center)

      HStack(spacing: AppDesign.spacingM) {
        Button("Privacy") { openURL(AppLinks.privacyPolicy) }
        Text("·").foregroundStyle(AppDesign.tertiaryText)
        Button("Terms") { openURL(AppLinks.termsOfService) }
      }
      .font(.caption.weight(.semibold))
      .foregroundStyle(AppDesign.secondaryText)
    }
    .padding(.top, AppDesign.spacingS)
  }
}
