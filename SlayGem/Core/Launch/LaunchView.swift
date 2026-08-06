//
//  LaunchView.swift
//  SlayGem
//

import SwiftUI

struct LaunchView: View {
  @Environment(StoreKitManager.self) private var store

  let onFinish: () -> Void

  @State private var viewModel = LaunchViewModel()
  @State private var pulse = false
  @State private var contentOpacity = 0.0

  var body: some View {
    ZStack {
      AppBackgroundView(showsAmbientGrid: true)

      VStack(spacing: AppDesign.spacingXL) {
        LaunchBrandMark(pulseScale: pulse ? 1.06 : 1)

        VStack(spacing: AppDesign.spacingS) {
          SlayGemTitleText(size: 34)
          Text(AppDesign.tagline)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppDesign.secondaryText)
        }

        VStack(spacing: AppDesign.spacingS) {
          LaunchLoadingBar(progress: viewModel.progress)
          Text(viewModel.statusText)
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppDesign.tertiaryText)
            .contentTransition(.numericText())
            .animation(AppDesign.smoothAnimation, value: viewModel.statusText)
        }
      }
      .opacity(contentOpacity)
      .padding(.horizontal, AppDesign.screenPadding)
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.55)) {
        contentOpacity = 1
      }
      withAnimation(.easeInOut(duration: 0.95).repeatForever(autoreverses: true)) {
        pulse = true
      }
      Task {
        await viewModel.bootstrap(store: store)
        withAnimation(AppDesign.phaseAnimation) {
          onFinish()
        }
      }
    }
  }
}
