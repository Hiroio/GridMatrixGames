//
//  ProfileView.swift
//  SpinGrid
//

import SwiftUI

struct ProfileView: View {
  @Environment(StoreKitManager.self) private var store
  @Environment(AppStorageManager.self) private var appStorage
  @Environment(\.openURL) private var openURL
  @State private var viewModel = ProfileViewModel()

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: AppDesign.spacingXL) {
        ScreenHeaderView(
          title: "Profile",
          subtitle: "Settings, Premium & legal",
          icon: "person.crop.circle"
        )

        ProfileSection(title: "Activity") {
          ProfileMetricsBar(
            testsPlayed: viewModel.testsPlayed,
            gamesPlayed: viewModel.gamesPlayed,
            todayStreak: viewModel.todayStreak
          )
        }

        ProfileSection(title: "Premium") {
          if store.isPremium {
            premiumActiveCard
          } else {
            premiumUpgradeCard
          }

          if let message = store.statusMessage, !message.isEmpty {
            Text(message)
              .font(.caption)
              .foregroundStyle(AppDesign.secondaryText)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.top, AppDesign.spacingXS)
          }
        }

        ProfileSection(title: "System") {
          VStack(spacing: 0) {
            ProfileToggleRow(
              title: "Sound",
              subtitle: "Tap and puzzle feedback",
              systemName: "speaker.wave.2.fill",
              isOn: Binding(
                get: { appStorage.isSoundEnabled },
                set: { appStorage.isSoundEnabled = $0 }
              )
            )
            divider
            ProfileToggleRow(
              title: "Haptics",
              subtitle: "Tactile cell response",
              systemName: "iphone.radiowaves.left.and.right",
              isOn: Binding(
                get: { appStorage.isHapticEnabled },
                set: { appStorage.isHapticEnabled = $0 }
              )
            )
          }
          .gridCard(padding: 0)
        }

        ProfileSection(title: "Legal") {
          VStack(spacing: 0) {
            ProfileLinkRow(
              title: "Restore Purchases",
              subtitle: "Sync Premium with your Apple ID",
              systemName: "arrow.clockwise.circle.fill",
              showsChevron: false
            ) {
              Task { await store.restorePurchases() }
            }
            divider
            ProfileLinkRow(
              title: "Privacy Policy",
              subtitle: "How we handle your data",
              systemName: "hand.raised.fill"
            ) {
              openURL(AppLinks.privacyPolicy)
            }
            divider
            ProfileLinkRow(
              title: "Terms of Service",
              subtitle: "Usage terms for SpinGrid",
              systemName: "doc.text.fill"
            ) {
              openURL(AppLinks.termsOfService)
            }
          }
          .gridCard(padding: 0)
        }

        HStack(spacing: AppDesign.spacingS) {
          SFSymbolBadge(systemName: "square.grid.3x3.fill", size: 32, iconSize: 14)
          Text("SpinGrid v1.0 · Matrix Cognition Lab")
            .font(.caption)
            .foregroundStyle(AppDesign.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, AppDesign.spacingS)
      }
      .padding(.horizontal, AppDesign.screenPadding)
      .padding(.top, AppDesign.spacingM)
      .padding(.bottom, AppDesign.spacingXL)
    }
    .gridTransparentScroll()
    .task { await store.preparePaywall() }
  }

  private var premiumUpgradeCard: some View {
    VStack(alignment: .leading, spacing: AppDesign.spacingM) {
      HStack(spacing: 10) {
        SFSymbolBadge(systemName: "crown.fill", size: 40, iconSize: 18)
        VStack(alignment: .leading, spacing: 4) {
          Text("SpinGrid Premium")
            .font(.headline.weight(.bold))
            .foregroundStyle(AppDesign.primaryText)
          Text("One-time unlock · \(store.premiumPriceText)")
            .font(.caption)
            .foregroundStyle(AppDesign.secondaryText)
        }
      }

      VStack(alignment: .leading, spacing: 8) {
        ForEach(PremiumFeature.allCases) { feature in
          Label(feature.title, systemImage: feature.icon)
            .font(.caption)
            .foregroundStyle(AppDesign.secondaryText)
        }
      }

      Button {
        store.presentPaywall()
      } label: {
        Label("Upgrade to Premium", systemImage: "sparkles")
          .frame(maxWidth: .infinity)
      }
      .gridAccentButton()
    }
    .gridCard()
  }

  private var premiumActiveCard: some View {
    HStack(spacing: AppDesign.spacingM) {
      SFSymbolBadge(systemName: "checkmark.seal.fill", size: 40, iconSize: 18)
      VStack(alignment: .leading, spacing: 4) {
        Text("Premium active")
          .font(.headline.weight(.bold))
          .foregroundStyle(AppDesign.primaryText)
        Text("All games and sessions unlocked")
          .font(.caption)
          .foregroundStyle(AppDesign.secondaryText)
      }
      Spacer()
    }
    .gridCard()
  }

  private var divider: some View {
    Rectangle()
      .fill(AppDesign.gridLine)
      .frame(height: 1)
      .padding(.leading, 60)
  }
}
