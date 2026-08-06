//
//  OnBoardingView.swift
//  SlayGem
//

import SwiftUI

private struct OnboardingPage: Identifiable {
  let id: Int
  let title: String
  let body: String
}

struct OnBoardingView: View {
  @Environment(AppStorageManager.self) private var appStorage
  let onFinish: () -> Void

  @State private var page = 0

  private let pages: [OnboardingPage] = [
    OnboardingPage(
      id: 0,
      title: "Train your eye on the grid",
      body: "Quick matrix tests measure speed, memory, and spatial judgment."
    ),
    OnboardingPage(
      id: 1,
      title: "Quick tests. Deep puzzles.",
      body: "Tests are one fast round each. Games let you pick Easy, Medium, or Hard."
    ),
    OnboardingPage(
      id: 2,
      title: "Go further with Premium",
      body: "Unlock Hard mode on every game, Slide Fusion, unlimited sessions, and Stats export."
    ),
  ]

  var body: some View {
    ZStack {
      AppBackgroundView()

      VStack(spacing: 0) {
        header

        Spacer(minLength: AppDesign.spacingM)

        pageVisual
          .frame(height: 168)
          .id(page)
          .transition(AppTransitions.segmentContent)

        VStack(spacing: AppDesign.spacingM) {
          Text(pages[page].title)
            .font(.title2.weight(.bold))
            .foregroundStyle(AppDesign.primaryText)
            .multilineTextAlignment(.center)

          Text(pages[page].body)
            .font(.body)
            .foregroundStyle(AppDesign.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, AppDesign.spacingXL)
        }
        .padding(.top, AppDesign.spacingXL)
        .id("copy-\(page)")
        .transition(AppTransitions.segmentContent)

        OnboardingPageIndicator(count: pages.count, current: page)
          .padding(.top, AppDesign.spacingL)

        Spacer(minLength: AppDesign.spacingM)

        VStack(spacing: AppDesign.spacingM) {
          Button(page == pages.count - 1 ? "Get started" : "Continue") {
            advance()
          }
          .gridAccentButton()

          if page < pages.count - 1 {
            Button("Skip") {
              complete()
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppDesign.tertiaryText)
          }
        }
        .padding(.horizontal, AppDesign.screenPadding)
        .padding(.bottom, AppDesign.spacingXL)
      }
    }
    .animation(AppDesign.phaseAnimation, value: page)
  }

  private var header: some View {
    HStack {
      HStack(spacing: 8) {
		  LaunchBrandMark(pulseScale: 1, size: 28)
          .frame(width: 36, height: 36)
        SlayGemTitleText(size: 16)
      }
      Spacer()
    }
    .padding(.horizontal, AppDesign.screenPadding)
    .padding(.top, AppDesign.spacingM)
  }

  @ViewBuilder
  private var pageVisual: some View {
    switch page {
    case 0:
      OnboardingAnimatedGrid()
    case 1:
      HStack(alignment: .top, spacing: AppDesign.spacingXL) {
        onboardingTile(style: .gridSearch, title: "Tests", icon: "checklist")
        onboardingTile(style: .flipMatrix, title: "Games", icon: "gamecontroller.fill")
      }
      .fixedSize(horizontal: false, vertical: true)
    default:
      ZStack(alignment: .topTrailing) {
        MatrixThumbnailView(style: .slideFusion, size: 120)
        Image(systemName: "lock.fill")
          .font(.caption.weight(.bold))
          .foregroundStyle(AppDesign.ctaTextOnAccent)
          .padding(7)
          .background(AppDesign.accent, in: Circle())
          .offset(x: 8, y: -8)
      }
    }
  }

  private func onboardingTile(
    style: MatrixThumbnailStyle,
    title: String,
    icon: String
  ) -> some View {
    VStack(spacing: AppDesign.spacingS) {
      MatrixThumbnailView(style: style, size: 72)
      Label(title, systemImage: icon)
        .font(.caption.weight(.bold))
        .foregroundStyle(AppDesign.secondaryText)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }

  private func advance() {
    if page < pages.count - 1 {
      withAnimation(AppDesign.phaseAnimation) {
        page += 1
      }
    } else {
      complete()
    }
  }

  private func complete() {
    appStorage.hasCompletedOnboarding = true
    withAnimation(AppDesign.phaseAnimation) {
      onFinish()
    }
  }
}
