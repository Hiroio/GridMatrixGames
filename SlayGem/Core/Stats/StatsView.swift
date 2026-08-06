//
//  StatsView.swift
//  SlayGem
//

import SwiftUI

struct StatsView: View {
  @Environment(StoreKitManager.self) private var store
  @State private var viewModel = StatsViewModel()
  @State private var segment: StatsSegment = .tests

  private let testColumns = [
    GridItem(.flexible(), spacing: AppDesign.spacingM),
    GridItem(.flexible(), spacing: AppDesign.spacingM),
  ]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: AppDesign.spacingL) {
        ScreenHeaderView(
          title: "Stats",
          subtitle: "Your matrix performance at a glance",
          icon: "chart.bar"
        )

        heroCard

        statsSegmentedControl

        switch segment {
        case .tests:
          LazyVGrid(columns: testColumns, spacing: AppDesign.spacingM) {
            ForEach(viewModel.testRows) { row in
              StatsTestMetricTile(row: row)
            }
          }
          .transition(AppTransitions.segmentContent)
        case .games:
          VStack(spacing: AppDesign.spacingM) {
            if !store.isPremium {
              statsPremiumUpsell
            }
            ForEach(viewModel.gameRows) { row in
              StatsGameChartCard(row: row)
            }
          }
          .transition(AppTransitions.segmentContent)
        }

        exportButton
      }
      .padding(.horizontal, AppDesign.screenPadding)
      .padding(.top, AppDesign.spacingM)
      .padding(.bottom, AppDesign.spacingXL)
      .animation(AppDesign.segmentAnimation, value: segment)
    }
    .gridTransparentScroll()
    .onAppear { viewModel.extendedCharts = store.isPremium }
    .onChange(of: store.isPremium) { _, isPremium in
      viewModel.extendedCharts = isPremium
    }
  }

  private var statsPremiumUpsell: some View {
    Button {
      store.presentPaywall()
    } label: {
      HStack(spacing: AppDesign.spacingM) {
        SFSymbolBadge(systemName: "chart.bar.doc.horizontal", size: 36, iconSize: 15)
        VStack(alignment: .leading, spacing: 4) {
          Text("Unlock 30-day charts")
            .font(.subheadline.weight(.bold))
            .foregroundStyle(AppDesign.primaryText)
          Text("Premium includes extended activity history")
            .font(.caption)
            .foregroundStyle(AppDesign.secondaryText)
        }
        Spacer()
        Image(systemName: "lock.fill")
          .font(.caption.weight(.bold))
          .foregroundStyle(AppDesign.accent)
      }
      .gridCard()
    }
    .contentShape(Rectangle())
    .buttonStyle(.plain)
  }

  private var heroCard: some View {
    HStack(spacing: AppDesign.spacingL) {
      ZStack {
        Circle()
          .stroke(AppDesign.timerTrack, lineWidth: 6)
          .frame(width: 72, height: 72)
        Circle()
          .trim(from: 0, to: min(1, CGFloat(viewModel.gridScore) / 500))
          .stroke(AppDesign.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
          .rotationEffect(.degrees(-90))
          .frame(width: 72, height: 72)
        Text("\(viewModel.gridScore)")
          .font(.headline.weight(.bold).monospacedDigit())
          .foregroundStyle(AppDesign.primaryText)
      }

      VStack(alignment: .leading, spacing: 6) {
        Label("GRID SCORE", systemImage: "square.grid.3x3.fill")
          .font(.caption.weight(.bold))
          .foregroundStyle(AppDesign.tertiaryText)
        Text(viewModel.gridCaption)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(AppDesign.primaryText)
        Text("Sessions this week: \(viewModel.sessionsThisWeek)")
          .font(.caption)
          .foregroundStyle(AppDesign.secondaryText)
      }

      Spacer(minLength: 0)
    }
    .gridCard()
  }

  private var statsSegmentedControl: some View {
    HStack(spacing: AppDesign.spacingS) {
      ForEach(StatsSegment.allCases) { item in
        let isSelected = segment == item
        Button {
          withAnimation(AppDesign.segmentAnimation) {
            segment = item
          }
        } label: {
          Label(item.title, systemImage: item == .tests ? "checklist" : "gamecontroller.fill")
            .font(.subheadline.weight(.bold))
            .foregroundStyle(isSelected ? AppDesign.ctaTextOnAccent : AppDesign.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
              isSelected ? AppDesign.accent : AppDesign.surface,
              in: RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous)
            )
            .overlay {
              RoundedRectangle(cornerRadius: AppDesign.chipCorner, style: .continuous)
                .stroke(AppDesign.gridLine, lineWidth: 1)
            }
            .animation(AppDesign.segmentAnimation, value: isSelected)
        }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
      }
    }
  }

  @ViewBuilder
  private var exportButton: some View {
    if store.isPremium {
      ShareLink(item: viewModel.exportCSV(), preview: SharePreview("SlayGem Stats")) {
        Label("Export CSV", systemImage: "square.and.arrow.up")
          .frame(maxWidth: .infinity)
      }
      .gridAccentButton()
    } else {
      Button {
        store.presentPaywall()
      } label: {
        Label("Export CSV — Premium", systemImage: "lock.fill")
          .frame(maxWidth: .infinity)
      }
      .font(.subheadline.weight(.semibold))
      .foregroundStyle(AppDesign.secondaryText)
      .padding(.vertical, 16)
      .overlay {
        RoundedRectangle(cornerRadius: AppDesign.buttonCorner, style: .continuous)
          .stroke(AppDesign.gridLine, lineWidth: 1)
      }
    }
  }
}
